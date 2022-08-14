#!/usr/bin/env bash
export LANG=en_US.UTF-8

# 当前脚本版本号和新增功能
VERSION=1.00

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
  alpine_wgcf_restart(){ kill -15 $(pgrep warp-go); /opt/warp-go/warp-go --config=/opt/warp-go/warp.conf; }
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
  SYSTEMCTL_RESTART=("systemctl restart warp-go" "systemctl restart warp-go" "systemctl restart warp-go" "alpine_wgcf_restart" "systemctl restart wg-quick@wgcf")
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
  IP4=$(curl -ks4m8 https://ip.gs/json)
  LAN4=$(ip route get 162.159.193.10 2>/dev/null | grep -oP 'src \K\S+')
  WAN4=$(expr "$IP4" : '.*ip\":\"\([^"]*\).*')
  COUNTRY4=$(expr "$IP4" : '.*country\":\"\([^"]*\).*')
  ASNORG4=$(expr "$IP4" : '.*asn_org\":\"\([^"]*\).*')
  TRACE4=$(curl -ks4m8 https://www.cloudflare.com/cdn-cgi/trace | grep warp | sed "s/warp=//g")
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
help(){	yellow " warp-go h (帮助菜单）\n warp-go o (临时 warp-go 开关)\n warp-go u (卸载 WARP 网络接口和 warp-go)\n warp-go v (同步脚本至最新版本)\n warp-go 4/6 (WARP IPv4/IPv6 单栈)\n warp-go d (WARP 双栈)\n warp-go s [OPTION](WARP 单双栈相互切换，如 [warp s 4]、[warp s 6]、[warp s d])\n "; }

# 关闭 WARP 网络接口，并删除 warp-go
uninstall(){
  unset IP4 IP6 WAN4 WAN6 COUNTRY4 COUNTRY6 ASNORG4 ASNORG6
  # 卸载
  systemctl disable --now warp-go >/dev/null 2>&1
  kill -15 $(pgrep warp-go) >/dev/null 2>&1
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
	green " 成功！已同步最新脚本，版本号:$(grep ^VERSION /opt/warp-go/warp-go.sh | sed "s/.*=//g")  功能新增: " || red " 升级失败，问题反馈:[https://github.com/fscarmen/warp/issues] "
	exit
  }

# 由于warp bug，有时候获取不了ip地址，加入刷网络脚本手动运行，并在定时任务加设置 VPS 重启后自动运行,i=当前尝试次数，j=要尝试的次数
net(){
  unset IP4 IP6 WAN4 WAN6 COUNTRY4 COUNTRY6 ASNORG4 ASNORG6 WARPSTATUS4 WARPSTATUS6
  i=1;j=5
  yellow " $(eval echo "后台获取 WARP IP 中,最大尝试\${j}次……")\n $(eval echo "第\${i}次尝试") "
  ${SYSTEMCTL_START[int]}
  sleep 5
  ip4_info; ip6_info
  until [[ $TRACE4$TRACE6 =~ on|plus ]]; do
      (( i++ )) || true
      yellow " $(eval echo "第\${i}次尝试") "
      ${SYSTEMCTL_RESTART[int]}
      sleep 5
	  ip4_info; ip6_info
      [[ $i = "$j" ]] && red " $(eval echo "失败已超过\${j}次，脚本中止，问题反馈:[https://github.com/fscarmen/warp/issues]") " && exit 1
  done
  [[ -e /opt/warp-go/license ]] && AC='+' && check_quota
	green " 已成功获取 WARP$AC 网络 "
	COUNTRY4=$(translate "$COUNTRY4")
	COUNTRY6=$(translate "$COUNTRY6")
	[[ $OPTION = [on] ]] && green " IPv4: $WAN4 $WARPSTATUS4 $COUNTRY4 $ASNORG4\n IPv6: $WAN6 $WARPSTATUS6 $COUNTRY6 $ASNORG6 "
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

# 单双栈在线互换。先看菜单是否有选择，再看传参数值，再没有显示2个可选项
stack_switch(){
  # WARP 单双栈切换选项
  SWITCH014='sed -i "s#AllowedIPs.*#AllowedIPs = 0.0.0.0/0#g" /opt/warp-go/warp.conf'
  SWITCH01D='sed -i "s#AllowedIPs.*#AllowedIPs = 0.0.0.0/0,::/0#g" /opt/warp-go/warp.conf'
  SWITCH106='sed -i "s#AllowedIPs.*#AllowedIPs = ::/0#g" /opt/warp-go/warp.conf'
  SWITCH10D='sed -i "s#AllowedIPs.*#AllowedIPs = 0.0.0.0/0,::/0#g" /opt/warp-go/warp.conf'
  SWITCH114='sed -i "s#AllowedIPs.*#AllowedIPs = 0.0.0.0/0#g" /opt/warp-go/warp.conf'
  SWITCH116='sed -i "s#AllowedIPs.*#AllowedIPs = ::/0#g" /opt/warp-go/warp.conf'
	
  check_stack
  if [[ $SWITCHCHOOSE = [46D] ]]; then
    [[ "$T4@$T6@$SWITCHCHOOSE" =~ '1@0@4'|'0@1@6'|'1@1@D' ]] && red " 不能切换为当前一样的形态 " && exit 1 || TO="$T4$T6$SWITCHCHOOSE"
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
  OPTION=n && net
  }

# 检测系统信息
check_system_info(){
  green " 检查环境中…… "

  # 必须加载 TUN 模块，先尝试在线打开 TUN。尝试成功放到启动项，失败作提示并退出脚本
  TUN=$(cat /dev/net/tun 2>&1 | tr '[:upper:]' '[:lower:]')
  if [[ ! $TUN =~ 'in bad state' ]] && [[ ! $TUN =~ '处于错误状态' ]] && [[ ! $TUN =~ 'Die Dateizugriffsnummer ist in schlechter Verfassung' ]]; then
	cat >/opt/warp-go/tun.sh << EOF
#!/usr/bin/env bash
mkdir -p /dev/net
mknod /dev/net/tun c 10 200
chmod 0666 /dev/net/tun
EOF
    bash /usr/bin/tun.sh
    TUN=$(cat /dev/net/tun 2>&1 | tr '[:upper:]' '[:lower:]')
    if [[ ! $TUN =~ 'in bad state' ]] && [[ ! $TUN =~ '处于错误状态' ]] && [[ ! $TUN =~ 'Die Dateizugriffsnummer ist in schlechter Verfassung' ]]; then
	  rm -f /usr/bin//tun.sh && red " 没有加载 TUN 模块，请在管理后台开启或联系供应商了解如何开启，问题反馈:[https://github.com/fscarmen/warp/issues] " && exit 1
    else echo "@reboot root bash /usr/bin/tun.sh" >> /etc/crontab
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
	x86_64 ) ARCHITECTURE=amd64;;
	s390x ) ARCHITECTURE=s390x;;
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
	  [[ $i = 0 ]] && red " ${T[${L}29]} " && exit 1 || reading " $(eval echo "License 应为26位字符，请重新输入 WARP+ License，没有可回车继续\(剩余\${i}次\):") " LICENSE
  done
  }

# 升级 WARP+ 账户（如有），限制位数为空或者26位以防输入错误，WARP interface 可以自定义设备名(不允许字符串间有空格，如遇到将会以_代替)
update_license(){
	[[ -z $LICENSE ]] && reading " 请输入WARP+ License: " LICENSE
	i=5
	until [[ $LICENSE =~ ^[A-Z0-9a-z]{8}-[A-Z0-9a-z]{8}-[A-Z0-9a-z]{8}$ ]]
		do	(( i-- )) || true
			[[ $i = 0 ]] && red " 输入错误达5次，脚本退出 " && exit 1 || reading " $(eval echo "License 应为26位字符,请重新输入 WARP+ License \(剩余\${i}次\):") " LICENSE
	done
  }

# warp-go 安装
install(){
  # 先删除之前安装，可能导致失败的文件
  rm -rf /opt/warp-go/warp-go /opt/warp-go/warp.conf
	
  # 询问是否有 WARP+
  input_license

  # 脚本开始时间
  start=$(date +%s)

  # 注册 WARP 账户 (将生成 warp 文件保存账户信息)
  # 判断 wgcf 的最新版本,如因 gitlab 接口问题未能获取，默认 v1.0.2
  {	
  latest=$(wget -qO- https://gitlab.com/api/v4/projects/ProjectWARP%2Fwarp-go/releases | grep -oP '"tag_name":"v\K[^\"]+' | head -n 1)
  latest=${latest:-'1.0.2'}

  # 安装 warp-go，尽量下载官方的最新版本，如官方 warp-go 下载不成功，将使用 githubusercontents 的 CDN，以更好的支持双栈。并添加执行权限
  mkdir -p /opt/warp-go/ >/dev/null 2>&1
  wget --no-check-certificate -T1 -t1 $CDN -O /opt/warp-go/warp-go_"$latest"_linux_"$ARCHITECTURE".tar.gz https://gitlab.com/ProjectWARP/warp-go/-/releases/v"$latest"/downloads/warp-go_"$latest"_linux_"$ARCHITECTURE".tar.gz
  tar xzf /opt/warp-go/warp-go_"$latest"_linux_"$ARCHITECTURE".tar.gz -C /opt/warp-go/ warp-go 
  chmod +x /opt/warp-go/warp-go
  rm -f /opt/warp-go/warp-go_"$latest"_linux_"$ARCHITECTURE".tar.gz
	
  # 注册 WARP 账户
  until [[ -e /opt/warp-go/warp.conf ]]; do
    /opt/warp-go/warp-go --register --config=/opt/warp-go/warp.conf --license=$LICENSE >/dev/null 2>&1
    sleep 1
  done
  green "\n 进度 2/3: 已安装 warp-go\n "
  [[ -n "$LICENSE" ]] && echo "$LICENSE" > /opt/warp-go/license
  }&

  # 对于 IPv4 only VPS 开启 IPv6 支持
  {
  [[ $IPV4$IPV6 = 10 ]] && [[ $(sysctl -a 2>/dev/null | grep 'disable_ipv6.*=.*1') || $(grep -s "disable_ipv6.*=.*1" /etc/sysctl.{conf,d/*} ) ]] &&
  (sed -i '/disable_ipv6/d' /etc/sysctl.{conf,d/*}
  echo 'net.ipv6.conf.all.disable_ipv6 = 0' >/etc/sysctl.d/ipv6.conf
  sysctl -w net.ipv6.conf.all.disable_ipv6=0)
  }&
	
  # 根据系统选择需要安装的依赖, 安装一些必要的网络工具包
  green "\n 进度 1/3: 安装系统依赖……\n "

  Debian(){
	${PACKAGE_UPDATE[int]}
	${PACKAGE_INSTALL[int]} --no-install-recommends net-tools iproute2
	}

  Ubuntu(){
	${PACKAGE_UPDATE[int]}
	${PACKAGE_INSTALL[int]} --no-install-recommends net-tools iproute2
	}
		
  CentOS(){
    ${PACKAGE_INSTALL[int]} net-tools
	}

  Alpine(){
	${PACKAGE_INSTALL[int]} net-tools iproute2 openrc
	}

  Arch(){
	${PACKAGE_INSTALL[int]} openresolv
	}

  $SYSTEM

  wait

  # WGCF 配置修改，其中用到的 162.159.193.10 和 2606:4700:d0::a29f:c001 均是 engage.cloudflareclient.com 的 IP
  MODIFY014='sed -i "/Endpoint6/d;/PreUp/d;s/162.159.*/[2606:4700:d0::a29f:c003]:1701/g;s#.*AllowedIPs.*#AllowedIPs   = 0.0.0.0/0#g;s#.*PostUp.*#PostUp   = ip -6 rule add from '$LAN6' lookup main#g;s#.*PostDown.*#PostDown = ip -6 rule delete from '$LAN6' lookup main#g" /opt/warp-go/warp.conf'
  MODIFY016='sed -i "/Endpoint6/d;/PreUp/d;s/162.159.*/[2606:4700:d0::a29f:c003]:1701/g;s#.*AllowedIPs.*#AllowedIPs   = ::/0#g;s#.*PostUp.*#PostUp   = ip -6 rule add from '$LAN6' lookup main#g;s#.*PostDown.*#PostDown = ip -6 rule delete from '$LAN6' lookup main#g" /opt/warp-go/warp.conf'
  MODIFY01D='sed -i "/Endpoint6/d;/PreUp/d;s/162.159.*/[2606:4700:d0::a29f:c003]:1701/g;s#.*AllowedIPs.*#AllowedIPs   = 0.0.0.0/0,::/0#g;s#.*PostUp.*#PostUp   = ip -6 rule add from '$LAN6' lookup main#g;s#.*PostDown.*#PostDown = ip -6 rule delete from '$LAN6' lookup main#g" /opt/warp-go/warp.conf'
  MODIFY104='sed -i "/Endpoint6/d;/PreUp/d;s/162.159.192.*/162.159.193.10:1701/g;s#.*AllowedIPs.*#AllowedIPs   = 0.0.0.0/0#g;s#.*PostUp.*#PostUp   = ip -4 rule add from '$LAN4' lookup main#g;s#.*PostDown.*#PostDown = ip -4 rule delete from '$LAN4' lookup main#g" /opt/warp-go/warp.conf'
  MODIFY106='sed -i "/Endpoint6/d;/PreUp/d;s/162.159.192.*/162.159.193.10:1701/g;s#.*AllowedIPs.*#AllowedIPs   = ::/0#g;s#.*PostUp.*#PostUp   = ip -4 rule add from '$LAN4' lookup main#g;s#.*PostDown.*#PostDown = ip -4 rule delete from '$LAN4' lookup main#g" /opt/warp-go/warp.conf'
  MODIFY10D='sed -i "/Endpoint6/d;/PreUp/d;s/162.159.192.*/162.159.193.10:1701/g;s#.*AllowedIPs.*#AllowedIPs   = 0.0.0.0/0,::/0#g;s#.*PostUp.*#PostUp   = ip -4 rule add from '$LAN4' lookup main#g;s#.*PostDown.*#PostDown = ip -4 rule delete from '$LAN4' lookup main#g" /opt/warp-go/warp.conf'
  MODIFY114='sed -i "/Endpoint6/d;/PreUp/d;s/162.159.192.*/162.159.193.10:1701/g;s#.*AllowedIPs.*#AllowedIPs   = 0.0.0.0/0#g;s#.*PostUp.*#PostUp   = ip -4 rule add from '$LAN4' lookup main; ip -6 rule add from '$LAN6' lookup main#g;s#.*PostDown.*#PostDown = ip -4 rule delete from '$LAN4' lookup main; ip -6 rule delete from '$LAN6' lookup main#g" /opt/warp-go/warp.conf'
  MODIFY116='sed -i "/Endpoint6/d;/PreUp/d;s/162.159.192.*/162.159.193.10:1701/g;s#.*AllowedIPs.*#AllowedIPs   = ::/0#g;s#.*PostUp.*#PostUp   = ip -4 rule add from '$LAN4' lookup main; ip -6 rule add from '$LAN6' lookup main#g;s#.*PostDown.*#PostDown = ip -4 rule delete from '$LAN4' lookup main; ip -6 rule delete from '$LAN6' lookup main#g" /opt/warp-go/warp.conf'
  MODIFY11D='sed -i "/Endpoint6/d;/PreUp/d;s/162.159.192.*/162.159.193.10:1701/g;s#.*AllowedIPs.*#AllowedIPs   = 0.0.0.0/0,::/0#g;s#.*PostUp.*#PostUp   = ip -4 rule add from '$LAN4' lookup main; ip -6 rule add from '$LAN6' lookup main#g;s#.*PostDown.*#PostDown = ip -4 rule delete from '$LAN4' lookup main; ip -6 rule delete from '$LAN6' lookup main#g" /opt/warp-go/warp.conf'

  sh -c "$(eval echo "\$MODIFY$CONF")"

  # 创建 warp-go systemd 进程守护
  cat > /lib/systemd/system/warp-go.service << EOF
[Unit]
Description=warp-go service
After=network.target
Documentation=https://github.com/fscarmen/warp
Documentation=https://gitlab.com/ProjectWARP/warp-go

[Service]
ExecStart=/opt/warp-go/warp-go --config=/opt/warp-go/warp.conf --foreground
RemainAfterExit=yes
Restart=always

[Install]
WantedBy=multi-user.target
EOF

  # 运行 warp-go
  net

  # 设置开机启动
  ${SYSTEMCTL_ENABLE[int]} >/dev/null 2>&1

  # 创建软链接快捷方式
  mv $0 /opt/warp-go/
  chmod +x /opt/warp-go/warp-go.sh
  ln -sf /opt/warp-go/warp-go.sh /usr/bin/warp-go

  # 结果提示，脚本运行时间，次数统计
  end=$(date +%s)
  red "\n==============================================================\n"
  green " IPv4: $WAN4 $WARPSTATUS4 $COUNTRY4  $ASNORG4 "
  green " IPv6: $WAN6 $WARPSTATUS6 $COUNTRY6  $ASNORG6 "
  [[ $TRACE4$TRACE6 =~ on|plus ]] && green " $(eval echo "恭喜！WARP\$AC 已开启，总耗时:\$(( end - start ))秒， 脚本当天运行次数:\$TODAY，累计运行次数：\$TOTAL") "
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
	else 	[[ $QUOTA -gt 10000000000000 ]] && QUOTA="$((QUOTA/1000000000000)) TB" ||  QUOTA="$((QUOTA/1000000000)) GB"
	fi
	}

# 传参选项 OPTION：1=为 IPv4 或者 IPv6 补全另一栈WARP; 2=安装双栈 WARP; u=卸载 WARP
[[ $1 != '[option]' ]] && OPTION=$(tr '[:upper:]' '[:lower:]' <<< "$1")

# 参数选项 URL 或 License 或转换 WARP 单双栈
if [[ $2 != '[lisence]' ]]; then
	if [[ $2 = [46Dd] ]]; then SWITCHCHOOSE=$(tr '[:lower:]' '[:upper:]' <<< "$2")
	elif [[ $2 =~ ^[A-Z0-9a-z]{8}-[A-Z0-9a-z]{8}-[A-Z0-9a-z]{8}$ ]]; then LICENSE=$2
	elif [[ $2 =~ ^[A-Za-z]{2}$ ]]; then EXPECT=$2
	fi
fi

# 主程序运行 1/3
statistics_of_run-times
check_operating_system

# 设置部分后缀 1/3
case "$OPTION" in
h ) help; exit 0;;
esac

# 主程序运行 2/3
check_root_virt

# 设置部分后缀 2/3
case "$OPTION" in
  u ) uninstall; exit 0;;
  v ) ver; exit 0;;
  o ) onoff; exit 0;;
  s ) stack_switch; exit 0;;
esac

# 主程序运行 3/3
check_dependencies
check_system_info
check_stack

# 设置部分后缀 3/3
case "$OPTION" in
# 在已运行 Linux Client 前提下，不能安装 WARP IPv4 或者双栈网络接口。如已经运行 WARP ，参数 4,6,d 从原来的安装改为切换
[46d] )	
  if [[ $(ip a) =~ ": WARP:" ]]; then
    SWITCHCHOOSE="$(tr '[:lower:]' '[:upper:]' <<< "$OPTION")"; OPTION='s'
    yellow " warp-go 已经运行，将改为单双栈相互切换模式 " && stack_switch
  else

	  case "$OPTION" in
	    4 ) CONF=${CONF1[m]};; 
	    6 ) CONF=${CONF2[m]};;
	    d ) CONF=${CONF3[m]};;
	  esac
    install
  fi;;
* )
  if [[ -e /opt/warp-go/warp-go.sh ]]; then
    help
  else
    yellow " 安装类型:\n 1. WARP IPv4 only\n 2. WARP IPv6 only\n 3. WARP 双栈\n 0. 退出\n " && reading " 请选择: " WARP_STACK
    case "$WARP_STACK" in
	    1 ) CONF=${CONF1[m]};; 
	    2 ) CONF=${CONF2[m]};;
	    3 ) CONF=${CONF3[m]};;
      * ) exit 0
	  esac
    install
  fi;;
esac
