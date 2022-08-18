#!/usr/bin/env bash
export LANG=en_US.UTF-8

# 当前脚本版本号和新增功能
VERSION=1.02
CONTENT="1.在原来全局的基础上，新增 WARP IPv4 非全局方案(bash warp-go.sh n)，配置 v2ray/xray 配置文件来分流，参数项目主页的 Client WARP 模式的模版; 2.输出 wgcf 配置文件(warp-go e)"

# 自定义字体彩色，read 函数，友道翻译函数
red(){ echo -e "\033[31m\033[01m$@\033[0m"; }
green(){ echo -e "\033[32m\033[01m$@\033[0m"; }
yellow(){ echo -e "\033[33m\033[01m$@\033[0m"; }
reading(){ read -rp "$(green "$1")" "$2"; }
translate(){ [[ -n "$1" ]] && curl -ksm8 "http://fanyi.youdao.com/translate?&doctype=json&type=AUTO&i=${1//[[:space:]]/}" | cut -d \" -f18 2>/dev/null; }

# 脚本当天及累计运行次数统计
statistics_of_run-times(){
  COUNT=$(curl -ksm1 "https://hits.seeyoufarm.com/api/count/incr/badge.svg?url=https%3A%2F%2Fraw.githubusercontent.com%2Ffscarmen%2Fwarp%2Fmain%2Fwarp-go.sh&count_bg=%2379C83D&title_bg=%23555555&icon=&icon_color=%23E7E7E7&title=hits&edge_flat=false" 2>&1) &&
  TODAY=$(expr "$COUNT" : '.*\s\([0-9]\{1,\}\)\s/.*') && TOTAL=$(expr "$COUNT" : '.*/\s\([0-9]\{1,\}\)\s.*')
  }

# 必须以root运行脚本
check_root_virt(){
  [[ $(id -u) != 0 ]] && red " 必须以root方式运行脚本，可以输入 sudo -i 后重新下载运行，问题反馈:[https://github.com/fscarmen/warp/issues] " && exit 1
  }

# 多方式判断操作系统，试到有值为止。只支持 Debian 9/10/11、Ubuntu 18.04/20.04/22.04 或 CentOS 7/8 ,如非上述操作系统，退出脚本
check_operating_system(){
  CMD=(	"$(grep -i pretty_name /etc/os-release 2>/dev/null | cut -d \" -f2)"
        "$(hostnamectl 2>/dev/null | grep -i system | cut -d : -f2)"
        "$(lsb_release -sd 2>/dev/null)"
        "$(grep -i description /etc/lsb-release 2>/dev/null | cut -d \" -f2)"
        "$(grep . /etc/redhat-release 2>/dev/null)"
        "$(grep . /etc/issue 2>/dev/null | cut -d \\ -f1 | sed '/^[ ]*$/d')"
      )

  for i in "${CMD[@]}"; do
    SYS="$i" && [[ -n $SYS ]] && break
  done

  # 自定义 Alpine 系统若干函数
  alpine_warp_restart(){ kill -15 $(pgrep warp-go); /opt/warp-go/warp-go --config=/opt/warp-go/warp.conf; }
  alpine_wgcf_enable(){ echo 'nohup /opt/warp-go/warp-go --config=/opt/warp-go/warp-go/warp.conf &' > /etc/local.d/warp-go.start; chmod +x /etc/local.d/warp-go.start; rc-update add local; }

  REGEX=("debian" "ubuntu" "centos|red hat|kernel|oracle linux|alma|rocky|amazon linux" "alpine" "arch linux")
  RELEASE=("Debian" "Ubuntu" "CentOS" "Alpine" "Arch")
  EXCLUDE=("bookworm")
  MAJOR=("9" "16" "7" "3" "")
  PACKAGE_UPDATE=("apt -y update" "apt -y update" "yum -y update" "apk update -f" "pacman -Sy")
  PACKAGE_INSTALL=("apt -y install" "apt -y install" "yum -y install" "apk add -f" "pacman -S --noconfirm")
  PACKAGE_UNINSTALL=("apt -y autoremove" "apt -y autoremove" "yum -y autoremove" "apk del -f" "pacman -Rcnsu --noconfirm")
  SYSTEMCTL_START=("systemctl start warp-go" "systemctl start warp-go" "systemctl start warp-go" "/opt/warp-go/warp-go --config=/opt/warp-go/warp.conf" "systemctl start warp-go")
  SYSTEMCTL_STOP=("systemctl stop warp-go" "systemctl stop warp-go" "systemctl stop warp-go" "kill -15 \$(pgrep warp-go)" "systemctl stop warp-go")
  SYSTEMCTL_RESTART=("systemctl restart warp-go" "systemctl restart warp-go" "systemctl restart warp-go" "alpine_warp_restart" "systemctl restart wg-quick@wgcf")
  SYSTEMCTL_ENABLE=("systemctl enable --now warp-go" "systemctl enable --now warp-go" "systemctl enable --now warp-go" "alpine_wgcf_enable" "systemctl enable --now warp-go")

  for ((int=0; int<${#REGEX[@]}; int++)); do
    [[ $(echo "$SYS" | tr '[:upper:]' '[:lower:]') =~ ${REGEX[int]} ]] && SYSTEM="${RELEASE[int]}" && COMPANY="${COMPANY[int]}" && [[ -n $SYSTEM ]] && break
  done
  [[ -z $SYSTEM ]] && red " 本脚本只支持 Debian、Ubuntu、CentOS、Arch 或 Alpine 系统,问题反馈:[https://github.com/fscarmen/warp/issues] " && exit 1

  # 先排除 EXCLUDE 里包括的特定系统，其他系统需要作大发行版本的比较
  for ex in "${EXCLUDE[@]}"; do [[ ! $(echo "$SYS" | tr '[:upper:]' '[:lower:]')  =~ $ex ]]; done &&
  [[ $(echo $SYS | sed "s/[^0-9.]//g" | cut -d. -f1) -lt "${MAJOR[int]}" ]] && red " $(eval echo "${T[${L}26]}") " && exit 1
  }

# 安装 curl
check_dependencies(){
  type -P curl >/dev/null 2>&1 || (yellow " 安装curl中…… " && ${PACKAGE_INSTALL[int]} curl) || (yellow " 先升级软件库才能继续安装 curl，时间较长，请耐心等待…… " && ${PACKAGE_UPDATE[int]} && ${PACKAGE_INSTALL[int]} curl)
  ! type -P curl >/dev/null 2>&1 && red " 安装 curl 失败，脚本中止，问题反馈:[https://github.com/fscarmen/warp/issues] " && exit 1
  [[ $SYSTEM = Alpine ]] && ! type -P curl >/dev/null 2>&1 && ${PACKAGE_UPDATE[int]} && ${PACKAGE_INSTALL[int]} curl wget grep
  }

# 检测 IPv4 IPv6 信息，WARP Ineterface 开启，普通还是 Plus账户 和 IP 信息
ip4_info(){
  unset IP4 LAN4 COUNTRY4 ASNORG4 TRACE4 PLUS4 WARPSTATUS4
  IP4=$(curl -ks4m8 https://ip.gs/json $INTERFACE)
  LAN4=$(ip route get 162.159.193.10 2>/dev/null | grep -oP 'src \K\S+')
  WAN4=$(expr "$IP4" : '.*ip\":\"\([^"]*\).*')
  COUNTRY4=$(expr "$IP4" : '.*country\":\"\([^"]*\).*')
  ASNORG4=$(expr "$IP4" : '.*asn_org\":\"\([^"]*\).*')
  TRACE4=$(curl -ks4m8 https://www.cloudflare.com/cdn-cgi/trace $INTERFACE | grep warp | sed "s/warp=//g")
  }

ip6_info(){
  unset IP6 LAN6 COUNTRY6 ASNORG6 TRACE6 PLUS6 WARPSTATUS6
  IP6=$(curl -ks6m8 https://ip.gs/json)
  LAN6=$(ip route get 2606:4700:d0::a29f:c001 2>/dev/null | grep -oP 'src \K\S+')
  WAN6=$(expr "$IP6" : '.*ip\":\"\([^"]*\).*')
  COUNTRY6=$(expr "$IP6" : '.*country\":\"\([^"]*\).*')
  ASNORG6=$(expr "$IP6" : '.*asn_org\":\"\([^"]*\).*')
  TRACE6=$(curl -ks6m8 https://www.cloudflare.com/cdn-cgi/trace | grep warp | sed "s/warp=//g")
  }

# 帮助说明
help(){	yellow " warp-go h (帮助菜单）\n warp-go o (临时 warp-go 开关)\n warp-go u (卸载 WARP 网络接口和 warp-go)\n warp-go v (同步脚本至最新版本)\n warp-go i (更换支持 Netflix 的IP)\n warp-go 4/6 (WARP IPv4/IPv6 单栈)\n warp-go d (WARP 双栈)\n warp-go n (WARP IPv4 非全局)\n warp-go s [OPTION](WARP 单双栈相互切换，如 [warp s 4]、[warp s 6]、[warp s d])\n warp-go g (WARP 全局 / 非全局相互切换)\n warp-go e (输出 wireguard 配置文件) "; }

# IPv4 / IPv6 优先
stack_priority(){
  [[ -e /etc/gai.conf ]] && sed -i '/^precedence \:\:ffff\:0\:0/d;/^label 2002\:\:\/16/d' /etc/gai.conf
  case "$PRIORITY" in
    2 )	echo "label 2002::/16   2" >> /etc/gai.conf;;
    3 )	;;
    * )	echo "precedence ::ffff:0:0/96  100" >> /etc/gai.conf;;
  esac
  }

# 更换支持 Netflix WARP IP 改编自 [luoxue-bot] 的成熟作品，地址[https://github.com/luoxue-bot/warp_auto_change_ip]
change_ip(){
  warp_restart(){ red " $(eval echo "\$(date +'%F %T') 尝试第\${i}次，解锁失败，IPv\$NF: \$WAN  \$COUNTRY  \$ASNORG，\${j}秒后重新测试，刷 IP 运行时长: \$DAY 天 \$HOUR 时 \$MIN 分 \$SEC 秒") " && ${SYSTEMCTL_RESTART[int]}; sleep $j; }

  # 设置时区，让时间戳时间准确，显示脚本运行时长，中文为 GMT+8，英文为 UTC; 设置 UA
  ip_start=$(date +%s)
  [[ $SYSTEM != Alpine ]] && ( [[ $L = C ]] && timedatectl set-timezone Asia/Shanghai || timedatectl set-timezone UTC )
  UA_Browser="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.87 Safari/537.36"

  # 根据 lmc999 脚本检测 Netflix Title，如获取不到，使用兜底默认值
  LMC999=$(curl -sSLm4 https://raw.githubusercontent.com/lmc999/RegionRestrictionCheck/main/check.sh)
  RESULT_TITLE=$(echo "$LMC999" | grep "result.*netflix.com/title/" | sed "s/.*title\/\([^\"]*\).*/\1/")
  REGION_TITLE=$(echo "$LMC999" | grep "region.*netflix.com/title/" | sed "s/.*title\/\([^\"]*\).*/\1/")
  RESULT_TITLE=${RESULT_TITLE:-'81215567'}; REGION_TITLE=${REGION_TITLE:-'80018499'}

  # 检测 WARP 单双栈服务
  unset T4 T6
  if grep -q "#AllowedIPs" /opt/warp-go/warp.conf; then
    T4=1; T6=0
  else
    grep -q "0\.\0\/0" /opt/warp-go/warp.conf && T4=1 || T4=0
    grep -q "\:\:\/0" /opt/warp-go/warp.conf && T6=1 || T6=0
  fi
  case "$T4$T6" in
    01 ) NF='6';;
    10 ) NF='4';;
    11 ) yellow "\n 1. 刷 WARP IPv4 (默认)\n 2. 刷 WARP IPv6\n " && reading " 请选择: " NETFLIX
         NF='4' && [[ $NETFLIX = 2 ]] && NF='6';;
  esac

  # 输入解锁区域
  if [[ -z "$EXPECT" ]]; then
    [[ -n "$NF" ]] && REGION=$(tr '[:lower:]' '[:upper:]' <<< $(curl --user-agent "${UA_Browser}" --interface WARP -$NF -fs --max-time 10 --write-out %{redirect_url} --output /dev/null "https://www.netflix.com/title/$REGION_TITLE" | sed 's/.*com\/\([^-/]\{1,\}\).*/\1/g'))
    REGION=${REGION:-'US'}
    reading " $(eval echo "当前 Netflix 地区是:\$REGION，需要解锁当前地区请按 y , 如需其他地址请输入两位地区简写 \(如 hk ,sg，默认:\$REGION\):") " EXPECT
    until [[ -z $EXPECT || $EXPECT = [Yy] || $EXPECT =~ ^[A-Za-z]{2}$ ]]; do
      reading " $(eval echo "${T[${L}56]}") " EXPECT
    done
    [[ -z $EXPECT || $EXPECT = [Yy] ]] && EXPECT="$REGION"
  fi

  # 解锁检测程序
  i=0; j=5
  while true; do
    (( i++ )) || true
    ip_now=$(date +%s); RUNTIME=$((ip_now - ip_start)); DAY=$(( RUNTIME / 86400 )); HOUR=$(( (RUNTIME % 86400 ) / 3600 )); MIN=$(( (RUNTIME % 86400 % 3600) / 60 )); SEC=$(( RUNTIME % 86400 % 3600 % 60 ))
    ip${NF}_info
    WAN=$(eval echo \$WAN$NF) && ASNORG=$(eval echo \$ASNORG$NF)
    COUNTRY=$(translate "$(eval echo \$COUNTRY$NF)") || COUNTRY=$(eval echo \$COUNTRY$NF)
    RESULT=$(curl --user-agent "${UA_Browser}" --interface WARP -$NF -fsL --write-out %{http_code} --output /dev/null --max-time 10 "https://www.netflix.com/title/$RESULT_TITLE" 2>&1)
    if [[ $RESULT = 200 ]]; then
      REGION=$(tr '[:lower:]' '[:upper:]' <<< $(curl --user-agent "${UA_Browser}" --interface WARP -$NF -fs --max-time 10 --write-out %{redirect_url} --output /dev/null "https://www.netflix.com/title/$REGION_TITLE" | sed 's/.*com\/\([^-/]\{1,\}\).*/\1/g'))
      REGION=${REGION:-'US'}
      echo "$REGION" | grep -qi "$EXPECT" && green " $(eval echo "\$(date +'%F %T') 区域 \$REGION 解锁成功，IPv\$NF: \$WAN  \$COUNTRY  \$ASNORG，1 小时后重新测试，刷 IP 运行时长: \$DAY 天 \$HOUR 时 \$MIN 分 \$SEC 秒") " && i=0 && sleep 1h || warp_restart
    else warp_restart
    fi
  done
  }

# 关闭 WARP 网络接口，并删除 warp-go
uninstall(){
  unset IP4 IP6 WAN4 WAN6 COUNTRY4 COUNTRY6 ASNORG4 ASNORG6
  # 卸载
  systemctl disable --now warp-go >/dev/null 2>&1
  kill -15 $(pgrep warp-go) >/dev/null 2>&1
  rule_del >/dev/null 2>&1
  /opt/warp-go/warp-go --config=/opt/warp-go/warp.conf --remove >/dev/null 2>&1
  rm -rf /opt/warp-go /lib/systemd/system/warp-go.service /usr/bin/warp-go
  [[ -e /opt/warp-go/tun.sh ]] && rm -f /opt/warp-go/tun.sh && sed -i '/tun.sh/d' /etc/crontab

  # 显示卸载结果
  ip4_info; [[ -n "$COUNTRY4" ]] && COUNTRY4=$(translate "$COUNTRY4")
  ip6_info; [[ -n "$COUNTRY6" ]] && COUNTRY6=$(translate "$COUNTRY6")
  green " WARP 网络接口及 warp-go 已彻底删除!\n IPv4: $WAN4 $COUNTRY4 $ASNORG4\n IPv6: $WAN6 $COUNTRY6 $ASNORG6 "
  }

# 同步脚本至最新版本
ver(){
  wget -N -P /opt/warp-go/ https://raw.githubusercontent.com/fscarmen/warp/main/warp-go.sh
  chmod +x /opt/warp-go/warp-go.sh
  ln -sf /opt/warp-go/warp-go.sh /usr/bin/warp-go
  green " 成功！已同步最新脚本，版本号:$(grep ^VERSION /opt/warp-go/warp-go.sh | sed "s/.*=//g")  功能新增: $(grep -m1 "CONTENT" /opt/warp-go/warp-go.sh | cut -d \" -f2)" || red " 升级失败，问题反馈:[https://github.com/fscarmen/warp/issues] "
  exit
  }

# i=当前尝试次数，j=要尝试的次数
net(){
  unset IP4 IP6 WAN4 WAN6 COUNTRY4 COUNTRY6 ASNORG4 ASNORG6 WARPSTATUS4 WARPSTATUS6
  i=1;j=5;INTERFACE='--interface WARP'
  yellow " $(eval echo "后台获取 WARP IP 中,最大尝试\${j}次……")\n $(eval echo "第\${i}次尝试") "
  ${SYSTEMCTL_RESTART[int]}
  sleep 5
  ip4_info; ip6_info
  until [[ $TRACE4$TRACE6 =~ on|plus ]]; do
    (( i++ )) || true
    yellow " $(eval echo "第\${i}次尝试") "
    ${SYSTEMCTL_RESTART[int]}
    sleep 5
    ip4_info; ip6_info
      if [[ $i = "$j" ]]; then
        if [[ -e /opt/warp-go/warp.conf.tmp1 ]]; then 
          i=0 && green " 当前 Teams 账户不可用，自动切换回免费账户 " &&
          mv -f /opt/warp-go/warp.conf.tmp1 /opt/warp-go/warp.conf
      else
          ${SYSTEMCTL_STOP[int]} >/dev/null 2>&1
          red " $(eval echo "失败已超过\${j}次，脚本中止，问题反馈:[https://github.com/fscarmen/warp/issues]") " && exit 1
        fi
      fi
  done

  ACCOUNT_TYPE=$(grep "Type" /opt/warp-go/warp.conf | cut -d= -f2 | sed "s# ##g")
  [[ $ACCOUNT_TYPE = 'plus' ]] && check_quota
  [[ $WARP_STACK = 4 ]] || grep -q '#AllowedIPs' /opt/warp-go/warp.conf && GLOBAL_TYPE='非'

  green " 已成功获取 WARP $ACCOUNT_TYPE 网络\n 运行在 $GLOBAL_TYPE全局 模式 "
  COUNTRY4=$(translate "$COUNTRY4")
  COUNTRY6=$(translate "$COUNTRY6")
  [[ $OPTION = o ]] && green " IPv4: $WAN4 $WARPSTATUS4 $COUNTRY4 $ASNORG4\n IPv6: $WAN6 $WARPSTATUS6 $COUNTRY6 $ASNORG6 "
  [[ -n "$QUOTA" ]] && green " 剩余流量: $QUOTA "
  }

# WARP 开关，先检查是否已安装，再根据当前状态转向相反状态
onoff(){ 
  ! type -P warp-go >/dev/null 2>&1 && red " warp-go 还未安装 " && exit 1
  [[ $(ip a) =~ ": WARP:" ]] && (${SYSTEMCTL_STOP[int]}; green " 已暂停 WARP，再次开启可以用 warp-go o ") || net
  }

# 检查系统 WARP 单双栈情况。为了速度，先检查 warp-go 配置文件里的情况，再判断 trace
check_stack(){
  if [[ -e /opt/warp-go/warp.conf ]]; then
    grep -q ".*0\.\0\/0" /opt/warp-go/warp.conf && T4=1 || T4=0 
    grep -q ".*\:\:\/0" /opt/warp-go/warp.conf && T6=1 || T6=0
  else
    case "$TRACE4" in off ) T4='0';; 'on'|'plus' ) T4='1';; esac
    case "$TRACE6" in off ) T6='0';; 'on'|'plus' ) T6='1';; esac
  fi
  CASE=("@0" "0@" "0@0" "@1" "0@1" "1@" "1@0" "1@1")
  for ((m=0;m<${#CASE[@]};m++)); do [[ $T4@$T6 = ${CASE[m]} ]] && break; done
  WARP_BEFORE=("" "" "" "WARP IPv6 only" "WARP IPv6" "WARP IPv4 only" "WARP IPv4" "WARP 双栈")
  WARP_AFTER1=("" "" "" "WARP IPv4" "WARP IPv4" "WARP IPv6" "WARP IPv6" "WARP IPv4")
  WARP_AFTER2=("" "" "" "WARP 双栈" "WARP 双栈" "WARP 双栈" "WARP 双栈" "WARP IPv6")
  TO1=("" "" "" "014" "014" "106" "106" "114")
  TO2=("" "" "" "01D" "01D" "10D" "10D" "116")
  CONF1=("014" "104" "114")
  CONF2=("016" "106" "116")
  CONF3=("01D" "10D" "11D")
  }

# 检查全局状态
check_global(){
  [[ -e /opt/warp-go/warp.conf ]] && grep -q '#AllowedIPs' /opt/warp-go/warp.conf && NON_GLOBAL=1
  }

# 单双栈在线互换。先看菜单是否有选择，再看传参数值，再没有显示2个可选项
stack_switch(){
  check_global
  if [[ $NON_GLOBAL = 1 ]]; then
    red " WARP 非全局模式下不能切换单双栈 " && reading " 如需更换为全局模式，请按[y]，其他键退出: " TO_GLOBAL
    [[ $TO_GLOBAL != [Yy] ]] && exit 0 || global_switch
  fi

  # WARP 单双栈切换选项
  SWITCH014='sed -i "s#AllowedIPs.*#AllowedIPs = 0.0.0.0/0#g" /opt/warp-go/warp.conf'
  SWITCH01D='sed -i "s#AllowedIPs.*#AllowedIPs = 0.0.0.0/0,::/0#g" /opt/warp-go/warp.conf'
  SWITCH106='sed -i "s#AllowedIPs.*#AllowedIPs = ::/0#g" /opt/warp-go/warp.conf'
  SWITCH10D='sed -i "s#AllowedIPs.*#AllowedIPs = 0.0.0.0/0,::/0#g" /opt/warp-go/warp.conf'
  SWITCH114='sed -i "s#AllowedIPs.*#AllowedIPs = 0.0.0.0/0#g" /opt/warp-go/warp.conf'
  SWITCH116='sed -i "s#AllowedIPs.*#AllowedIPs = ::/0#g" /opt/warp-go/warp.conf'

  check_stack
  if [[ $SWITCHCHOOSE = [46D] ]]; then
    if [[ $TO_GLOBAL = [Yy] ]]; then
      if [[ "$T4@$T6@$SWITCHCHOOSE" =~ '1@0@4'|'0@1@6'|'1@1@D' ]]; then
        OPTION=o && net
        exit 0
      else
        TO="$T4$T6$SWITCHCHOOSE"
      fi
    else
      [[ "$T4@$T6@$SWITCHCHOOSE" =~ '1@0@4'|'0@1@6'|'1@1@D' ]] && red " 不能切换为当前一样的形态 " && exit 1 || TO="$T4$T6$SWITCHCHOOSE"
    fi
  else
    OPTION1="$(eval echo "\${WARP_BEFORE[m]} 转为 \${WARP_AFTER1[m]}")"; OPTION2="$(eval echo "\${WARP_BEFORE[m]} 转为 \${WARP_AFTER2[m]}")"
    yellow " $(eval echo "\\\n WARP 网络接口可以切换为以下方式:\\\n 1. \$OPTION1\\\n 2. \$OPTION2\\\n 0. 退出脚本\\\n") " && reading " 请选择: " SWITCHTO
    case "$SWITCHTO" in
      1 ) TO=${TO1[m]};;	2 ) TO=${TO2[m]};;	0 ) exit;;
      * ) red " 请输入正确数字 [0-2] "; sleep 1; stack_switch;;
    esac
  fi
  sh -c "$(eval echo "\$SWITCH$TO")"
  ${SYSTEMCTL_RESTART[int]}
  OPTION=o && net
  }

rule_add(){
  IP_ROUTE=$(ip -4 rule 2>/dev/null)
  [[ ! $(echo $IP_ROUTE) =~ 'from 172.16.0.2 lookup 60000' ]] && ip -4 rule add from 172.16.0.2 lookup 60000
  [[ ! $(echo $IP_ROUTE) =~ 'from all lookup main suppress_prefixlength 0' ]] && ip -4 rule add table main suppress_prefixlength 0
  sleep 1
  }

rule_del(){
  IP_ROUTE=$(ip -4 rule 2>/dev/null)
  [[ $(echo $IP_ROUTE) =~ 'from 172.16.0.2 lookup 60000' ]] && ip -4 rule delete from 172.16.0.2 lookup 60000
  [[ $(echo $IP_ROUTE) =~ 'from all lookup main suppress_prefixlength 0' ]] && ip -4 rule delete table main suppress_prefixlength 0
  }

route_add(){
  [[ $(ip -4 route list table 60000 2>/dev/null) =~ 'default dev WARP scope link' ]] || ip -4 route add default dev WARP table 60000
  }

# 全局 / 非全局在线互换
global_switch(){
  if grep -q "^Allowed" /opt/warp-go/warp.conf; then
    sed -i "s/^AllowedIPs.*/#&/g" /opt/warp-go/warp.conf
    rule_add
  else
    sed -i "s/#AllowedIPs/AllowedIPs/g" /opt/warp-go/warp.conf
    rule_del
  fi

  [[ $TO_GLOBAL != [Yy] ]] && OPTION=o && net
  grep -q "#Allowed" /opt/warp-go/warp.conf && route_add
  }

# 检测系统信息
check_system_info(){
  green " 检查环境中…… "

  # 必须加载 TUN 模块，先尝试在线打开 TUN。尝试成功放到启动项，失败作提示并退出脚本
  TUN=$(cat /dev/net/tun 2>&1 | tr '[:upper:]' '[:lower:]')
  if [[ ! $TUN =~ 'in bad state' ]] && [[ ! $TUN =~ '处于错误状态' ]] && [[ ! $TUN =~ 'Die Dateizugriffsnummer ist in schlechter Verfassung' ]]; then
    mkdir -p /opt/warp-go/ >/dev/null 2>&1
    cat >/opt/warp-go/tun.sh << EOF
#!/usr/bin/env bash
mkdir -p /dev/net
mknod /dev/net/tun c 10 200
chmod 0666 /dev/net/tun
EOF
    bash /opt/warp-go/tun.sh
    TUN=$(cat /dev/net/tun 2>&1 | tr '[:upper:]' '[:lower:]')
    if [[ ! $TUN =~ 'in bad state' ]] && [[ ! $TUN =~ '处于错误状态' ]] && [[ ! $TUN =~ 'Die Dateizugriffsnummer ist in schlechter Verfassung' ]]; then
      rm -f /usr/bin//tun.sh && red " 没有加载 TUN 模块，请在管理后台开启或联系供应商了解如何开启，问题反馈:[https://github.com/fscarmen/warp/issues] " && exit 1
    else 
      echo "@reboot root bash //opt/warp-go/tun.sh" >> /etc/crontab
    fi
  fi

  # 判断是否大陆 VPS。先尝试连接 CloudFlare WARP 服务的 Endpoint IP，如遇到 WARP 断网则先关闭、杀进程后重试一次，仍然不通则 WARP 项目不可用。
  ping6 -c2 -w8 2606:4700:d0::a29f:c001 >/dev/null 2>&1 && IPV6=1 && CDN=-6 || IPV6=0
  ping -c2 -W8 162.159.193.10 >/dev/null 2>&1 && IPV4=1 && CDN=-4 || IPV4=0
  if [[ $IPV4$IPV6 = 00 && $(ip a) =~ ": WARP:" ]]; then
    ${SYSTEMCTL_STOP[int]}
    ping6 -c2 -w10 2606:4700:d0::a29f:c001 >/dev/null 2>&1 && IPV6=1 && CDN=-6
    ping -c2 -W10 162.159.193.10 >/dev/null 2>&1 && IPV4=1 && CDN=-4
  fi

  # 判断处理器架构
  case $(uname -m) in
    aarch64 ) ARCHITECTURE=arm64;;
    x86)      ARCHITECTURE=386;;
    x86_64 )  CPU_FLAGS=$(cat /proc/cpuinfo | grep flags | head -n 1 | cut -d: -f2)
              case "$CPU_FLAGS" in
                *avx512* ) ARCHITECTURE=amd64v4;;
                *avx2* )   ARCHITECTURE=amd64v3;;
                *sse3* )   ARCHITECTURE=amd64v2;;
                * )        ARCHITECTURE=amd64;;
              esac;;
    s390x )   ARCHITECTURE=s390x;;
    * ) red " $(eval echo "当前架构 \$(uname -m) 暂不支持,问题反馈:[https://github.com/fscarmen/warp/issues]") " && exit 1;;
  esac

  # 判断当前 IPv4 与 IPv6 ，IP归属 及 WARP 方案, Linux Client 是否开启
  [[ $IPV4 = 1 ]] && ip4_info
  [[ $IPV6 = 1 ]] && ip6_info
  [[ -n "$COUNTRY4" ]] && COUNTRY4=$(translate "$COUNTRY4")
  [[ -n "$COUNTRY6" ]] && COUNTRY6=$(translate "$COUNTRY6")
  }

# 输入 WARP+ 账户（如有），限制位数为空或者26位以防输入错误
input_license(){
  [[ -z $LICENSE ]] && reading " 如有 WARP+ License 请输入，没有可回车继续: " LICENSE
  i=5
  until [[ -z $LICENSE || $LICENSE =~ ^[A-Z0-9a-z]{8}-[A-Z0-9a-z]{8}-[A-Z0-9a-z]{8}$ ]]; do
    (( i-- )) || true
    [[ $i = 0 ]] && red " 输入错误达5次，脚本退出 " && exit 1 || reading " $(eval echo "License 应为26位字符，请重新输入 WARP+ License，没有可回车继续\(剩余\${i}次\):") " LICENSE
  done
  [[ -n $LICENSE && -z $NAME ]] && reading " 请自定义 WARP+ 设备名 (如果不输入，默认为 [warp-go]): " NAME
  [[ -n $NAME ]] && NAME="${NAME//[[:space:]]/_}" || NAME=${NAME:-'warp-go'}
  }

# 升级 WARP+ 账户（如有），限制位数为空或者26位以防输入错误，WARP interface 可以自定义设备名(不允许字符串间有空格，如遇到将会以_代替)
update_license(){
  [[ -z $LICENSE ]] && reading " 请输入WARP+ License: " LICENSE
  i=5
  until [[ $LICENSE =~ ^[A-Z0-9a-z]{8}-[A-Z0-9a-z]{8}-[A-Z0-9a-z]{8}$ ]]; do
  (( i-- )) || true
    [[ $i = 0 ]] && red " 输入错误达5次，脚本退出 " && exit 1 || reading " $(eval echo "License 应为26位字符,请重新输入 WARP+ License \(剩余\${i}次\):") " LICENSE
  done
  [[ -n $LICENSE && -z $NAME ]] && reading " 请自定义 WARP+ 设备名 (如果不输入，默认为 [warp-go]): " NAME
  [[ -n $NAME ]] && NAME="${NAME//[[:space:]]/_}" || NAME=${NAME:-'warp-go'}
  }

# 输入 Teams 账户 token（如有）,如果 TOKEN 以 com.cloudflare.warp 开头，将自动删除多余部分
input_token(){
  [[ -z $TOKEN ]] && reading " 请输入 Teams Token (可通过 https://warp-team-api.herokuapp.com/ 轻松获取，如果留空，则使用脚本提供的): " TOKEN
  i=5
  until [[ -z $TOKEN || ${#TOKEN} -gt 1200 ]]; do
    (( i-- )) || true
    [[ $i = 0 ]] && red " 输入错误达5次，脚本退出 " && exit 1 || reading " $(eval echo "Token 错误,请重新输入 Teams token \(剩余\${i}次\):") " TOKEN
  done
  }

# 免费 WARP 账户升级 WARP+ 或 Teams 账户
update(){
  [[ $(grep "Type" /opt/warp-go/warp.conf) =~ plus ]] && check_quota && red " $(eval echo "已经是 WARP+ 账户，剩余流量: \$QUOTA，不需要升级") " && exit 1
  [[ $(grep "Type" /opt/warp-go/warp.conf) =~ team ]] && red " $(eval echo "已经是 Teams 账户，不需要升级") " && exit 1
  [[ ! -e /opt/warp-go/warp.conf ]] && red " 找不到账户文件：/opt/warp-go/warp.conf，可以卸载后重装 " && exit 1

  [[ -z $LICENSETYPE ]] && yellow " \n 1.使用 WARP+ license 升级\n 2.使用 Teams token 升级\n " && reading " 请选择: " LICENSETYPE
  case $LICENSETYPE in
    1 ) update_license
        if [[ -n $LICENSE ]]; then
          cp -f /opt/warp-go/warp.conf{,.tmp1}
          /opt/warp-go/warp-go --config=/opt/warp-go/warp.conf --remove >/dev/null 2>&1
          until [[ -e /opt/warp-go/warp.conf ]]; do
            /opt/warp-go/warp-go --register --config=/opt/warp-go/warp.conf --license=$LICENSE  --device-name=$NAME >/dev/null 2>&1
            sleep 1
          done
          head -n +6 /opt/warp-go/warp.conf > /opt/warp-go/warp.conf.tmp2
          tail -n +7 /opt/warp-go/warp.conf.tmp1 >> /opt/warp-go/warp.conf.tmp2
          mv -f /opt/warp-go/warp.conf.tmp2 /opt/warp-go/warp.conf
          check_quota
          OPTION=o && net
        fi;;

    2 ) input_token
        if [[ -n $TOKEN ]]; then
          i=0
          until [[ -e /opt/warp-go/warp.conf.tmp ]]; do
            ((i++)) || true
            [[ $i = 11 ]] && red " 注册 teams 账户失败，脚本中止，问题反馈:[https://github.com/fscarmen/warp/issues] " && exit 1
            /opt/warp-go/warp-go --register --config=/opt/warp-go/warp.conf.tmp --team-config "$TOKEN" >/dev/null 2>&1
            sleep 3
          done
          for a in {2..5}; do sed -i "${a}s#.*#$(sed -ne ${a}p /opt/warp-go/warp.conf.tmp)#" /opt/warp-go/warp.conf; done
          rm -f warp.conf.tmp
          OPTION=o && net

        else
        sed -i "s#.*Device.*#Device = FSCARMEN-WARP-SHARE-TEAM#g; s#.*PrivateKey.*#PrivateKey = SHVqHEGI7k2+OQ/oWMmWY2EQObbRQjRBdDPimh0h1WY=#g; s#.*Token.*#Token = SB-KKKYG-YGKKK-SB#g; s#.*Type.*#Type = team#g" /opt/warp-go/warp.conf  
        OPTION=o && net
        fi;;

    * ) red " 请输入正确数字 [1-2] "; sleep 1; update;;
  esac
  }

# 输出 wgcf 配置文件
export_wireguard(){
  if [[ ! -e /opt/warp-go/wgcf.conf ]]; then
    if [[ -e /opt/warp-go/warp-go ]]; then
      if [[ -e /opt/warp-go/warp.conf ]]; then
        /opt/warp-go/warp-go --config=/opt/warp-go/warp.conf --export-wireguard=/opt/warp-go/wgcf.conf >/dev/null 2>&1
      else
        /opt/warp-go/warp-go --register --config=/opt/warp-go/warp.conf --team-config "$TOKEN" >/dev/null 2>&1
        /opt/warp-go/warp-go --config=/opt/warp-go/warp.conf --export-wireguard=/opt/warp-go/wgcf.conf >/dev/null 2>&1
      fi
    else
      red " warp-go 还没有安装，没有注册账户，脚本中止，问题反馈:[https://github.com/fscarmen/warp/issues] " && exit 1
    fi
  fi
  
  green " 该账户的 wgcf.conf 路径: /opt/warp-go/wgcf.conf\n "
  cat /opt/warp-go/wgcf.conf
  echo -e "\n\n"
  }

# warp-go 安装
install(){
  # 先删除之前安装，可能导致失败的文件
  rm -rf /opt/warp-go/warp-go /opt/warp-go/warp.conf

  # 询问是否有 WARP+ 或 Teams 账户
  [[ -z $LICENSETYPE ]] && yellow " \n 如有 WARP+ 或 Teams 账户请选择\n  1. WARP+\n  2. Teams\n  3. 使用免费账户 (默认)\n " && reading " 请选择: " LICENSETYPE
  case $LICENSETYPE in
    1 ) input_license;;
    2 ) input_token;;
  esac

  # 选择优先使用 IPv4 /IPv6 网络
  yellow " \n 请选择优先级别:\n  1.IPv4 (默认)\n  2.IPv6\n  3.使用 VPS 初始设置\n " && reading " 请选择: " PRIORITY

  # 脚本开始时间
  start=$(date +%s)

  # 注册 WARP 账户 (将生成 warp 文件保存账户信息)
  # 判断 wgcf 的最新版本,如因 gitlab 接口问题未能获取，默认 v1.0.4
  {	
  latest=$(wget -qO- -T1 -t1 https://gitlab.com/api/v4/projects/ProjectWARP%2Fwarp-go/releases | grep -oP '"tag_name":"v\K[^\"]+' | head -n 1)
  latest=${latest:-'1.0.4'}

  # 安装 warp-go，尽量下载官方的最新版本，如官方 warp-go 下载不成功，将使用 githubusercontents 的 CDN，以更好的支持双栈。并添加执行权限
  mkdir -p /opt/warp-go/ >/dev/null 2>&1
  wget --no-check-certificate $CDN -O /opt/warp-go/warp-go_"$latest"_linux_"$ARCHITECTURE".tar.gz https://gitlab.com/ProjectWARP/warp-go/-/releases/v"$latest"/downloads/warp-go_"$latest"_linux_"$ARCHITECTURE".tar.gz
  [[ ! -e /opt/warp-go/warp-go_"$latest"_linux_"$ARCHITECTURE".tar.gz ]] && red " 下载 warp-go 压缩文件不成功，脚本退出，问题反馈:[https://github.com/fscarmen/warp/issues] " && exit 1
  tar xzf /opt/warp-go/warp-go_"$latest"_linux_"$ARCHITECTURE".tar.gz -C /opt/warp-go/ warp-go
  [[ ! -e /opt/warp-go/warp-go ]] && red " warp-go 文件不存在，脚本退出，问题反馈:[https://github.com/fscarmen/warp/issues] " && exit 1 || chmod +x /opt/warp-go/warp-go
  rm -f /opt/warp-go/warp-go_"$latest"_linux_"$ARCHITECTURE".tar.gz

  # 注册用户自定义 token 的 Teams 账户
  if [[ $LICENSETYPE = 2 ]]; then
    if [[ -n $TOKEN ]]; then
      i=0
      until [[ -e /opt/warp-go/warp.conf ]]; do
        ((i++)) || true
        [[ $i = 11 ]] && red " 注册 teams 账户失败，脚本中止，问题反馈:[https://github.com/fscarmen/warp/issues] " && exit 1
        /opt/warp-go/warp-go --register --config=/opt/warp-go/warp.conf --team-config "$TOKEN" >/dev/null 2>&1
        sleep 3
      done

  # 注册公用 token 的 Teams 账户
    else
      cat > /opt/warp-go/warp.conf << EOF
[Account]
Device = FSCARMEN-WARP-SHARE-TEAM
PrivateKey = SHVqHEGI7k2+OQ/oWMmWY2EQObbRQjRBdDPimh0h1WY=
Token = SB-KKKYG-YGKKK-SB
Type = team

[Peer]
PublicKey = bmXOC+F1FxEMF9dyiK2H5/1SUtzH0JuVo51h2wPfgyo=
Endpoint = 162.159.193.10:1701
KeepAlive = 30
#AllowedIPs = 0.0.0.0/0, ::/0

[Script]
#PostUp = 
#PostDown =
EOF
    fi

# 注册免费和 Plus 账户
  else
    i=0
    until [[ -e /opt/warp-go/warp.conf ]]; do
      ((i++)) || true
      [[ $i = 11 ]] && red " 注册 warp 账户失败，脚本中止，问题反馈:[https://github.com/fscarmen/warp/issues] " && exit 1
      /opt/warp-go/warp-go --register --config=/opt/warp-go/warp.conf --license=$LICENSE --device-name=$NAME >/dev/null 2>&1
      sleep 3
    done

    # 获取连接 WARP 的内网 IPv6
    [[ -e /opt/warp-go/warp.conf ]] && /opt/warp-go/warp-go --config=/opt/warp-go/warp.conf --export-wireguard /opt/warp-go/wgcf.conf >/dev/null 2>&1
    [[ $? = 0 ]] && ADDRESS6=$(grep "2606:4700.*" /opt/warp-go/wgcf.conf | awk '{print $NF}') && rm -f /opt/warp-go/wgcf.conf
  fi

  green "\n 进度 2/3: 已安装 warp-go\n "
  }&

  # 对于 IPv4 only VPS 开启 IPv6 支持
  {
  [[ $IPV4$IPV6 = 10 ]] && [[ $(sysctl -a 2>/dev/null | grep 'disable_ipv6.*=.*1') || $(grep -s "disable_ipv6.*=.*1" /etc/sysctl.{conf,d/*} ) ]] &&
  (sed -i '/disable_ipv6/d' /etc/sysctl.{conf,d/*}
  echo 'net.ipv6.conf.all.disable_ipv6 = 0' >/etc/sysctl.d/ipv6.conf
  sysctl -w net.ipv6.conf.all.disable_ipv6=0)
  }&

  # 优先使用 IPv4 /IPv6 网络
  { stack_priority; }&

  # 根据系统选择需要安装的依赖, 安装一些必要的网络工具包
  green "\n 进度 1/3: 安装系统依赖……\n "

  Debian(){ ! type -p ip >/dev/null 2>&1 && (${PACKAGE_UPDATE[int]}; ${PACKAGE_INSTALL[int]} --no-install-recommends iproute2); }

  Ubuntu(){ ! type -p ip >/dev/null 2>&1 && (${PACKAGE_UPDATE[int]}; ${PACKAGE_INSTALL[int]} --no-install-recommends iproute2); }

  CentOS(){ :; }

  Alpine(){ ${PACKAGE_INSTALL[int]} iproute2 openrc; }

  Arch(){ ${PACKAGE_INSTALL[int]} openresolv; }

  $SYSTEM

  wait

  # warp-go 配置修改，其中用到的 162.159.193.10 和 2606:4700:d0::a29f:c001 均是 engage.cloudflareclient.com 的 IP
  MODIFY014='sed -i "/Endpoint6/d;/PreUp/d;s/162.159.*/[2606:4700:d0::a29f:c003]:1701/g;s#.*AllowedIPs.*#AllowedIPs = 0.0.0.0/0#g;s#.*PostUp.*#PostUp = ip -6 rule add from '$LAN6' lookup main#g;s#.*PostDown.*#PostDown = ip -6 rule delete from '$LAN6' lookup main#g" /opt/warp-go/warp.conf'
  MODIFY016='sed -i "/Endpoint6/d;/PreUp/d;s/162.159.*/[2606:4700:d0::a29f:c003]:1701/g;s#.*AllowedIPs.*#AllowedIPs = ::/0#g;s#.*PostUp.*#PostUp   = ip -6 rule add from '$LAN6' lookup main#g;s#.*PostDown.*#PostDown = ip -6 rule delete from '$LAN6' lookup main#g" /opt/warp-go/warp.conf'
  MODIFY01D='sed -i "/Endpoint6/d;/PreUp/d;s/162.159.*/[2606:4700:d0::a29f:c003]:1701/g;s#.*AllowedIPs.*#AllowedIPs = 0.0.0.0/0,::/0#g;s#.*PostUp.*#PostUp = ip -6 rule add from '$LAN6' lookup main#g;s#.*PostDown.*#PostDown = ip -6 rule delete from '$LAN6' lookup main#g" /opt/warp-go/warp.conf'
  MODIFY104='sed -i "/Endpoint6/d;/PreUp/d;s/162.159.*/162.159.193.10:1701/g;s#.*AllowedIPs.*#AllowedIPs = 0.0.0.0/0#g;s#.*PostUp.*#PostUp = ip -4 rule add from '$LAN4' lookup main#g;s#.*PostDown.*#PostDown = ip -4 rule delete from '$LAN4' lookup main#g" /opt/warp-go/warp.conf'
  MODIFY106='sed -i "/Endpoint6/d;/PreUp/d;s/162.159.*/162.159.193.10:1701/g;s#.*AllowedIPs.*#AllowedIPs = ::/0#g;s#.*PostUp.*#PostUp = ip -4 rule add from '$LAN4' lookup main#g;s#.*PostDown.*#PostDown = ip -4 rule delete from '$LAN4' lookup main#g" /opt/warp-go/warp.conf'
  MODIFY10D='sed -i "/Endpoint6/d;/PreUp/d;s/162.159.*/162.159.193.10:1701/g;s#.*AllowedIPs.*#AllowedIPs = 0.0.0.0/0,::/0#g;s#.*PostUp.*#PostUp = ip -4 rule add from '$LAN4' lookup main#g;s#.*PostDown.*#PostDown = ip -4 rule delete from '$LAN4' lookup main#g" /opt/warp-go/warp.conf'
  MODIFY114='sed -i "/Endpoint6/d;/PreUp/d;s/162.159.*/162.159.193.10:1701/g;s#.*AllowedIPs.*#AllowedIPs = 0.0.0.0/0#g;s#.*PostUp.*#PostUp = ip -4 rule add from '$LAN4' lookup main; ip -6 rule add from '$LAN6' lookup main#g;s#.*PostDown.*#PostDown = ip -4 rule delete from '$LAN4' lookup main; ip -6 rule delete from '$LAN6' lookup main#g" /opt/warp-go/warp.conf'
  MODIFY116='sed -i "/Endpoint6/d;/PreUp/d;s/162.159.*/162.159.193.10:1701/g;s#.*AllowedIPs.*#AllowedIPs = ::/0#g;s#.*PostUp.*#PostUp = ip -4 rule add from '$LAN4' lookup main; ip -6 rule add from '$LAN6' lookup main#g;s#.*PostDown.*#PostDown = ip -4 rule delete from '$LAN4' lookup main; ip -6 rule delete from '$LAN6' lookup main#g" /opt/warp-go/warp.conf'
  MODIFY11D='sed -i "/Endpoint6/d;/PreUp/d;s/162.159.*/162.159.193.10:1701/g;s#.*AllowedIPs.*#AllowedIPs = 0.0.0.0/0,::/0#g;s#.*PostUp.*#PostUp = ip -4 rule add from '$LAN4' lookup main; ip -6 rule add from '$LAN6' lookup main#g;s#.*PostDown.*#PostDown = ip -4 rule delete from '$LAN4' lookup main; ip -6 rule delete from '$LAN6' lookup main#g" /opt/warp-go/warp.conf'

  sh -c "$(eval echo "\$MODIFY$CONF")"

  # 如为 WARP IPv4 非全局，修改配置文件，在路由表插入规则
  [[ $WARP_STACK = 4 || $OPTION = n ]] && sed -i "s/^#//g; s/^AllowedIPs.*/#&/g" /opt/warp-go/warp.conf && rule_add

  # 创建 warp-go systemd 进程守护
  cat > /lib/systemd/system/warp-go.service << EOF
[Unit]
Description=warp-go service
After=network.target
Documentation=https://github.com/fscarmen/warp
Documentation=https://gitlab.com/ProjectWARP/warp-go

[Service]
WorkingDirectory=/opt/warp-go/
ExecStart=/opt/warp-go/warp-go --config=/opt/warp-go/warp.conf --foreground
Environment="LOG_LEVEL=verbose"
RemainAfterExit=yes
Restart=always

[Install]
WantedBy=multi-user.target
EOF

  # 运行 warp-go
  net

  # 如为 WARP IPv4 非全局，把 WARP 网络接口添加到路由表
  [[ $WARP_STACK = 4 || $OPTION = n ]] && route_add

  # 设置开机启动
  ${SYSTEMCTL_ENABLE[int]} >/dev/null 2>&1

  # 创建软链接快捷方式
  mv $0 /opt/warp-go/
  chmod +x /opt/warp-go/warp-go.sh
  ln -sf /opt/warp-go/warp-go.sh /usr/bin/warp-go

  # 结果提示，脚本运行时间，次数统计
  end=$(date +%s)
  ACCOUNT_TYPE=$(grep "Type" /opt/warp-go/warp.conf | cut -d= -f2 | sed "s# ##g")
  [[ $ACCOUNT_TYPE = 'plus' ]] && check_quota

  red "\n==============================================================\n"
  green " IPv4: $WAN4 $WARPSTATUS4 $COUNTRY4  $ASNORG4 "
  green " IPv6: $WAN6 $WARPSTATUS6 $COUNTRY6  $ASNORG6 "
  green " $(eval echo "恭喜！WARP \$ACCOUNT_TYPE 已开启，总耗时:\$(( end - start ))秒， 脚本当天运行次数:\$TODAY，累计运行次数：\$TOTAL") "
  [[ -n "$QUOTA" ]] && green " 剩余流量: $QUOTA "
  red "\n==============================================================\n"
  yellow " 再次运行用 warp-go [option] [lisence]，如\n " && help
  [[ $TRACE4$TRACE6 = offoff ]] && red " WARP 安装失败，问题反馈:[https://github.com/fscarmen/warp/issues] "
  }

# 查 WARP+ 余额流量接口
check_quota(){
  ACCESS_TOKEN=$(grep 'Token' /opt/warp-go/warp.conf | cut -d= -f2 | sed 's# ##g')
  DEVICE_ID=$(grep 'Device' /opt/warp-go/warp.conf | cut -d= -f2 | sed 's# ##g')
  API=$(curl -s "https://api.cloudflareclient.com/v0a884/reg/$DEVICE_ID" -H "User-Agent: okhttp/3.12.1" -H "Authorization: Bearer $ACCESS_TOKEN")
  QUOTA=$(grep -oP '"quota":\K\d+' <<< $API)

  if type -p bc >/dev/null 2>&1; then
    [[ $QUOTA -gt 10000000000000 ]] && QUOTA="$(echo "scale=2; $QUOTA/1000000000000" | bc) TB" ||  QUOTA="$(echo "scale=2; $QUOTA/1000000000" | bc) GB"
  else
    [[ $QUOTA -gt 10000000000000 ]] && QUOTA="$((QUOTA/1000000000000)) TB" ||  QUOTA="$((QUOTA/1000000000)) GB"
  fi
  }

# 传参选项 OPTION：1=为 IPv4 或者 IPv6 补全另一栈WARP; 2=安装双栈 WARP; u=卸载 WARP
[[ $1 != '[option]' ]] && OPTION=$(tr '[:upper:]' '[:lower:]' <<< "$1")

# 参数选项 URL 或 License 或转换 WARP 单双栈
if [[ $2 != '[lisence]' ]]; then
  if [[ $2 = [46Dd] ]]; then SWITCHCHOOSE=$(tr '[:lower:]' '[:upper:]' <<< "$2")
  elif [[ $2 =~ ^[A-Z0-9a-z]{8}-[A-Z0-9a-z]{8}-[A-Z0-9a-z]{8}$ ]]; then LICENSETYPE=1 && LICENSE=$2
  elif [[ $2 =~ [A-Z0-9a-z]{1200,} ]]; then LICENSETYPE=2 && TOKEN=$2
  elif [[ $2 =~ ^[A-Za-z]{2}$ ]]; then EXPECT=$2
  fi
fi

# 自定义 WARP+ 设备名
NAME=$3

# 主程序运行 1/3
statistics_of_run-times
check_operating_system

# 设置部分后缀 1/3
case "$OPTION" in
  h ) help; exit 0;;
  i ) change_ip; exit 0;;
  e ) export_wireguard; exit 0;;
esac

# 主程序运行 2/3
check_root_virt

# 设置部分后缀 2/3
case "$OPTION" in
  u ) uninstall; exit 0;;
  v ) ver; exit 0;;
  o ) onoff; exit 0;;
  s ) stack_switch; exit 0;;
  g ) global_switch; exit 0;;
esac

# 主程序运行 3/3
check_dependencies
check_system_info
check_stack
check_global

# 设置部分后缀 3/3
case "$OPTION" in
  [46dn] )	
    if [[ $(ip a) =~ ": WARP:" ]]; then
      SWITCHCHOOSE="$(tr '[:lower:]' '[:upper:]' <<< "$OPTION")"; OPTION='s'
      yellow " warp-go 已经运行，将改为单双栈相互切换模式 " && stack_switch
    else
      case "$OPTION" in
        4 ) CONF=${CONF1[m]};; 
        6 ) CONF=${CONF2[m]};;
        d|n ) CONF=${CONF3[m]};;
      esac
      install
    fi;;

  a ) update;;

  * )
    if [[ -e /opt/warp-go/warp-go.sh ]]; then
      green " 已经安装了 warp-go ！ "
      help
    else
      yellow " 安装类型:\n  1. 全局 WARP IPv4 only\n  2. 全局 WARP IPv6 only\n  3. 全局 WARP 双栈\n  4. 非全局 WARP IPv4 only\n  0. 退出\n " && reading " 请选择: " WARP_STACK
      case "$WARP_STACK" in
        1 ) CONF=${CONF1[m]};; 
        2 ) CONF=${CONF2[m]};;
        3|4 ) CONF=${CONF3[m]};;
        * ) exit 0;;
      esac
      install
    fi;;
esac
