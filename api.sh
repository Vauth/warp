#!/usr/bin/env bash

# 只允许root运行
[[ "$EUID" -ne '0' ]] && echo "Error:This script must be run as root!" && exit 1;

# 帮助
help() {
  echo -ne " Usage:\n\tbash api.sh\t-h/--help\t\thelp\n\t\t\t-f/--file string\tConfiguration file (default "warp-account.conf")\n\t\t\t-r/--registe\t\tRegiste an account\n\t\t\t-t/--token\t\tRegiste with a team token\n\t\t\t-d/--device\t\tGet the devices information and plus traffic quota\n\t\t\t-a/--app\t\tFetch App information\n\t\t\t-b/--bind\t\tGet the account blinding devices\n\t\t\t-n/--name\t\tChange the device name\n\t\t\t-l/--license\t\tChange the license\n\t\t\t-u/--unbind\t\tUnbine a device from the account\n\t\t\t-c/--cancle\t\tCancle the account (There will be no display back for successful cancel)\n\t\t\t-i/--id\t\t\tShow the client id and reserved\n\n"
}

# 获取账户信息
fetch_account_information() {
  registe_path=${registe_path:-warp-account.conf}
  [ ! -e "$registe_path" ] && echo "Error:$registe_path: No such file!" && exit 1
  id=$(grep -m1 '"id' "$registe_path" | cut -d\" -f4)
  token=$(grep '"token' "$registe_path" | cut -d\" -f4)
  client_id=$(grep 'client_id' "$registe_path" | cut -d\" -f4)
}

# 注册warp账户
registe_account() {
  # 生成 wireguard 公私钥
  if [ $(type -p wg) ]; then
    private_key=$(wg genkey)
    public_key=$(wg pubkey <<< "$private_key")
  else
    wg_api=$(curl -sSL https://wg.cloudflare.now.cc)
    private_key=$(echo "$wg_api" | awk 'NR==2 {print $2}')
    public_key=$(echo "$wg_api" | awk 'NR==1 {print $2}')
  fi

  registe_path=${registe_path:-warp-account.conf}
  [[ "$(dirname "$registe_path")" != '.' ]] && mkdir -p $(dirname "$registe_path")
  install_id=$(tr -dc 'A-Za-z0-9' </dev/urandom | head -c 22)
  fcm_token="${install_id}:APA91b$(tr -dc 'A-Za-z0-9' </dev/urandom | head -c 134)"
  
  curl --request POST 'https://api.cloudflareclient.com/v0a2158/reg' \
  --silent \
  --location \
  --tlsv1.3 \
  --header 'User-Agent: okhttp/3.12.1' \
  --header 'CF-Client-Version: a-6.10-2158' \
  --header 'Content-Type: application/json' \
  --header "Cf-Access-Jwt-Assertion: ${team_token}" \
  --data '{"key":"'${public_key}'","install_id":"'${install_id}'","fcm_token":"'${fcm_token}'","tos":"'$(date +"%Y-%m-%dT%H:%M:%S.%3NZ")'","model":"PC","serial_number":"'${install_id}'","locale":"zh_CN"}' \
  | python3 -m json.tool > $registe_path

  # 补上 private key
  sed -i "/\"account_type\"/i\        \"private_key\": \"$private_key\"" $registe_path
  [ -e $registe_path ] && cat $registe_path && grep -q 'error code' $registe_path && rm -f $registe_path
}

# 获取设备信息
device_information() {
  fetch_account_information

  curl --request GET "https://api.cloudflareclient.com/v0a2158/reg/${id}" \
  --silent \
  --location \
  --header 'User-Agent: okhttp/3.12.1' \
  --header 'CF-Client-Version: a-6.10-2158' \
  --header 'Content-Type: application/json' \
  --header "Authorization: Bearer ${token}" \
  | python3 -m json.tool
}

# 获取账户APP信息
app_information() {
  fetch_account_information

  curl --request GET "https://api.cloudflareclient.com/v0a2158/client_config" \
  --silent \
  --location \
  --header 'User-Agent: okhttp/3.12.1' \
  --header 'CF-Client-Version: a-6.10-2158' \
  --header 'Content-Type: application/json' \
  --header "Authorization: Bearer ${token}" \
  | python3 -m json.tool
}

# 查看账户绑定设备
account_binding_devices() {
  fetch_account_information

  curl --request GET "https://api.cloudflareclient.com/v0a2158/reg/${id}/account/devices" \
  --silent \
  --location \
  --header 'User-Agent: okhttp/3.12.1' \
  --header 'CF-Client-Version: a-6.10-2158' \
  --header 'Content-Type: application/json' \
  --header "Authorization: Bearer ${token}" \
  | python3 -m json.tool
}

# 添加或者更改设备名
change_device_name() {
  fetch_account_information
  
  curl --request PATCH "https://api.cloudflareclient.com/v0a2158/reg/${id}/account/reg/${id}" \
  --silent \
  --location \
  --header 'User-Agent: okhttp/3.12.1' \
  --header 'CF-Client-Version: a-6.10-2158' \
  --header 'Content-Type: application/json' \
  --header "Authorization: Bearer ${token}" \
  --data '{"name":"'$device_name'"}' \
  | python3 -m json.tool
}

# 更换 license
change_license() {
  fetch_account_information

  curl --request PUT "https://api.cloudflareclient.com/v0a2158/reg/${id}/account" \
  --silent \
  --location \
  --header 'User-Agent: okhttp/3.12.1' \
  --header 'CF-Client-Version: a-6.10-2158' \
  --header 'Content-Type: application/json' \
  --header "Authorization: Bearer ${token}" \
  --data '{"license": "'$license'"}' \
  | python3 -m json.tool
}

# 删除绑定设备
unbind_devide() {
  fetch_account_information

  curl --request PATCH "https://api.cloudflareclient.com/v0a2158/reg/${id}/account/reg/${id}" \
  --silent \
  --location \
  --header 'User-Agent: okhttp/3.12.1' \
  --header 'CF-Client-Version: a-6.10-2158' \
  --header 'Content-Type: application/json' \
  --header "Authorization: Bearer ${token}" \
  --data '{"active":false}' \
  | python3 -m json.tool
}

# 删除账户
cancle_account() {
  fetch_account_information

  curl --request DELETE "https://api.cloudflareclient.com/v0a2158/reg/${id}" \
  --silent \
  --location \
  --header 'User-Agent: okhttp/3.12.1' \
  --header 'CF-Client-Version: a-6.10-2158' \
  --header 'Content-Type: application/json' \
  --header "Authorization: Bearer ${token}"
}

# reserved 解码
decode_reserved() {
  fetch_account_information
  reserved=$(echo "$client_id" | base64 -d | xxd -p | fold -w2 | while read HEX; do printf '%d ' "0x${HEX}"; done | awk '{print "["$1", "$2", "$3"]"}')
  echo -e "client id: $client_id\nreserved : $reserved"
}

[[ "$#" -eq '0' ]] && help && exit;

while [[ $# -ge 1 ]]; do
  case $1 in
    -f|--file)
      shift
      registe_path="$1"
      shift
      ;;
    -r|--registe)
      run=registe_account
      shift
      ;;
    -d|--device)
      run=device_information
      shift
      ;;
    -a|--app)
      run=app_information
      shift
      ;;
    -b|--bind)
      run=account_binding_devices
      shift
      ;;
    -n|--name)
      shift
      device_name="$1"
      run=change_device_name
      shift
      ;;
    -l|--license)
      shift
      license="$1"
      run=change_license
      shift
      ;;
    -u|--unbind)
      run=unbind_devide
      shift
      ;;
    -c|--cancle)
      run=cancle_account
      shift
      ;;
    -i|--id)
      run=decode_reserved
      shift
      ;;
    -t|--token)
      shift
      team_token="$1"
      shift
      ;;
    -h|--help)
      help
      exit
      ;;
    *) 
      help
      exit
      ;;
  esac
done

# 根据参数运行
$run
