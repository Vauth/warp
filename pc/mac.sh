#!/usr/bin/env bash

##### 为 macOS 添加 WGCF，IPv4走 warp #####
# 当前脚本版本号和新增功能
VERSION=1.00

declare -A T

T[E0]="\n Language:\n  1.English (default) \n  2.简体中文\n"
T[C0]="${T[E0]}"
T[E1]="First publication on a global scale: WARP one-click script on macOS. A VPN that fast,modern,secure by WireGuard tunnel and WARP service"
T[C1]="全网首发: macOS 一键脚本， 一个为免费、快速、安全的基于 WireGuard 隧道，WARP 服务的 VPN"
T[E2]="The script must be run as root, you can enter sudo -i and then download and run again. Feedback: [https://github.com/fscarmen/warp/issues]"
T[C2]="必须以root方式运行脚本，可以输入 sudo -i 后重新下载运行，问题反馈:[https://github.com/fscarmen/warp/issues]"
T[E3]="Choose:"
T[C3]="请选择:"
T[E4]="WARP interface, Linux Client and WirePorxy have been completely deleted!"
T[C4]="WARP 网络接口、 Linux Client 和 WirePorxy 已彻底删除!"
T[E5]="The script supports macOS only. Feedback: [https://github.com/fscarmen/warp/issues]"
T[C5]="本脚本只支持 macOS, 问题反馈:[https://github.com/fscarmen/warp/issues]"
T[E6]="If there is a WARP+ License, please enter it, otherwise press Enter to continue:"
T[C6]="如有 WARP+ License 请输入，没有可回车继续:"
T[E7]="Input errors up to 5 times.The script is aborted."
T[C7]="输入错误达5次，脚本退出"
T[E8]="License should be 26 characters, please re-enter WARP+ License. Otherwise press Enter to continue. \(\$i times remaining\):"
T[C8]="License 应为26位字符，请重新输入 WARP+ License，没有可回车继续\(剩余\$i次\):"
T[E9]="Please customize the WARP+ device name (Default is [WARP] if left blank):"
T[C9]="请自定义 WARP+ 设备名 (如果不输入，默认为 [WARP]):"
T[E10]="Step 1/3: Install brew and wireguard-tools"
T[C10]="进度 1/3：安装 brew 和 wireguard-tools"
T[E11]="Step 2/3: Install WGCF and wireguard-go"
T[C11]="进度 2/3：安装 WGCF 和 wireguard-go"
T[E12]="Step 3/3: Running WARP"
T[C12]="进度 3/3：运行 WARP"
T[E13]="Update WARP+ account..."
T[C13]="升级 WARP+ 账户中……"
T[E14]="The upgrade failed, WARP+ account error or more than 5 devices have been activated. Free WARP account to continu."
T[C14]="升级失败，WARP+ 账户错误或者已激活超过5台设备，自动更换免费 WARP 账户继续"
T[E15]="Congratulations! WARP\$TYPE is turned on. Spend time:\$(( end - start )) seconds.\\\n The script runs today: \$TODAY. Total:\$TOTAL"
T[C15]="恭喜！WARP\$TYPE 已开启，总耗时:\$(( end - start ))秒， 脚本当天运行次数:\$TODAY，累计运行次数：\$TOTAL"
T[E16]="Congratulations! WARP is turned on. Spend time:\$(( end - start )) seconds.\\\n The script runs on today: \$TODAY. Total:\$TOTAL"
T[C16]="恭喜！WARP 已开启，总耗时:\$(( end - start ))秒， 脚本当天运行次数:\$TODAY，累计运行次数：\$TOTAL"
T[E17]="Device name：\$(grep -s 'Device name' /etc/wireguard/info.log | awk '{ print \$NF }')\\\n Quota：\$(grep -s Quota /etc/wireguard/info.log | awk '{ print \$(NF-1), \$NF }')"
T[C17]="设备名:\$(grep -s 'Device name' /etc/wireguard/info.log | awk '{ print \$NF }')\\\n 剩余流量:\$(grep -s Quota /etc/wireguard/info.log | awk '{ print \$(NF-1), \$NF }')"
T[E18]="Run again with warp [option] [lisence], such as"
T[C18]="再次运行用 warp [option] [lisence]，如"
T[E19]="WARP installation failed. Feedback: [https://github.com/fscarmen/warp/issues]"
T[C19]="WARP 安装失败，问题反馈:[https://github.com/fscarmen/warp/issues]"
T[E20]="warp h (help)\n warp o (WARP on-off)\n warp u (Turn off and uninstall WARP interface)\n warp a (Upgrade to WARP+ account)\n warp e (Install WARP in English)\n warp c (Install WARP in Chinese)\n warp v (Sync the latest version)"
T[C20]="warp h (帮助菜单）\n warp o (临时warp开关)\n warp u (卸载 WARP )\n warp a (免费 WARP 账户升级 WARP+)\n warp e (英文安装 WARP )\n bash warp c (中文安装 WARP )\n warp v (同步脚本至最新版本)"
T[E21]="WGCF WARP has not been installed yet."
T[C21]="WGCF WARP 还未安装"
T[E22]="WARP is turned off. It could be turned on again by [warp o]"
T[C22]="已暂停 WARP，再次开启可以用 warp o"
T[E23]="WireGuard tools are not installed or the configuration file wgcf.conf cannot be found, please reinstall."
T[C23]="没有安装 WireGuard tools 或者找不到配置文件 wgcf.conf，请重新安装。"
T[E24]="Maximum \$j attempts to get WARP IP..."
T[C24]="后台获取 WARP IP 中,最大尝试\${j}次……"
T[E25]="Try \$i"
T[C25]="第\${i}次尝试"
T[E26]="Got the WARP IP successfully."
T[C26]="已成功获取 WARP 网络"
T[E27]="Create shortcut [bash warp] successfully"
T[C27]="创建快捷 bash warp 指令成功"
T[E28]="Successfully synchronized the latest version"
T[C28]="成功！已同步最新脚本，版本号"
T[E29]="New features"
T[C29]="功能新增"
T[E30]="Upgrade failed. Feedback:[https://github.com/fscarmen/warp/issues]"
T[C30]="升级失败，问题反馈:[https://github.com/fscarmen/warp/issues]"


# 自定义字体彩色，read 函数，友道翻译函数
red(){ echo -e "\033[31m\033[01m$1\033[0m"; }
green(){ echo -e "\033[32m\033[01m$1\033[0m"; }
yellow(){ echo -e "\033[33m\033[01m$1\033[0m"; }
reading(){ read -rp "$(green "$1")" "$2"; }
translate(){ [[ -n "$1" ]] && curl -ksm8 "http://fanyi.youdao.com/translate?&doctype=json&type=AUTO&i=$1" | cut -d \" -f18 2>/dev/null; }

# 脚本当天及累计运行次数统计
statistics_of_run-times(){
COUNT=$(curl -ksm1 "https://hits.seeyoufarm.com/api/count/incr/badge.svg?url=https%3A%2F%2Fcdn.jsdelivr.net%2Fgh%2Ffscarmen%2Fwarp%2Fmenu.sh&count_bg=%2379C83D&title_bg=%23555555&icon=&icon_color=%23E7E7E7&title=&edge_flat=true" 2>&1) &&
TODAY=$(expr "$COUNT" : '.*\s\([0-9]\{1,\}\)\s/.*') && TOTAL=$(expr "$COUNT" : '.*/\s\([0-9]\{1,\}\)\s.*')
}
	
# 选择语言，先判断 /etc/wireguard/language 里的语言选择，没有的话再让用户选择，默认英语
select_language(){
	case $(cat /etc/wireguard/language 2>&1) in
	E ) L=E;;	C ) L=C;;
	* ) L=E && [[ -z $OPTION ]] && yellow " ${T[${L}0]} " && reading " ${T[${L}3]} " LANGUAGE 
	[[ $LANGUAGE = 2 ]] && L=C;;
	esac
}


# 帮助说明
help(){	yellow " ${T[${L}20]} "; }

check_operating_system(){
	sw_vesrs 2>/dev/null | grep -qvi macos && red " ${T[${L}5]} " && exit 1
}

# 检测 IPv4 IPv6 信息，WARP Ineterface 开启，普通还是 Plus账户 和 IP 信息
ip4_info(){
	unset IP4 LAN4 COUNTRY4 ASNORG4 TRACE4 PLUS4 WARPSTATUS4
	IP4=$(curl -ks4m8 https://ip.gs/json)
	WAN4=$(expr "$IP4" : '.*ip\":\"\([^"]*\).*')
	COUNTRY4=$(expr "$IP4" : '.*country\":\"\([^"]*\).*')
	ASNORG4=$(expr "$IP4" : '.*asn_org\":\"\([^"]*\).*')
	TRACE4=$(curl -ks4m8 https://www.cloudflare.com/cdn-cgi/trace | grep warp | sed "s/warp=//g")
	if [[ $TRACE4 = plus ]]; then
		grep -sq 'Device name' /etc/wireguard/info.log && PLUS4='+' || PLUS4=' Teams'
	fi
	[[ $TRACE4 =~ on|plus ]] && WARPSTATUS4="( WARP$PLUS4 IPv4 )"
}

ip6_info(){
	unset IP6 LAN6 COUNTRY6 ASNORG6 TRACE6 PLUS6 WARPSTATUS6
	IP6=$(curl -ks6m8 https://ip.gs/json)
	WAN6=$(expr "$IP6" : '.*ip\":\"\([^"]*\).*')
	COUNTRY6=$(expr "$IP6" : '.*country\":\"\([^"]*\).*')
	ASNORG6=$(expr "$IP6" : '.*asn_org\":\"\([^"]*\).*')
	TRACE6=$(curl -ks6m8 https://www.cloudflare.com/cdn-cgi/trace | grep warp | sed "s/warp=//g")
	if [[ $TRACE6 = plus ]]; then
		grep -sq 'Device name' /etc/wireguard/info.log && PLUS6='+' || PLUS6=' Teams'
	fi
	[[ $TRACE6 =~ on|plus ]] && WARPSTATUS6="( WARP$PLUS6 IPv6 )"
}

# 由于warp bug，有时候获取不了ip地址，加入刷网络脚本手动运行，并在定时任务加设置 VPS 重启后自动运行,i=当前尝试次数，j=要尝试的次数
net(){
	unset IP4 IP6 WAN4 WAN6 COUNTRY4 COUNTRY6 ASNORG4 ASNORG6 WARPSTATUS4 WARPSTATUS6
	[[ ! $(type -P wg-quick) || ! -e /etc/wireguard/wgcf.conf ]] && red " ${T[${L}23]} " && exit 1
	i=1;j=5
	yellow " $(eval echo "${T[${L}24]}")\n $(eval echo "${T[${L}25]}") "
	sudo wg-quick up wgcf >/dev/null 2>&1
	ip4_info; ip6_info
	until [[ $TRACE4$TRACE6 =~ on|plus ]]
		do	(( i++ )) || true
			yellow " $(eval echo "${T[${L}25]}") "
			sudo wg-quick down wgcf >/dev/null 2>&1
			sudo wg-quick up wgcf >/dev/null 2>&1
			ip4_info; ip6_info
			if [[ $i = "$j" ]]; then
				if [[ $LICENSETYPE = 2 ]]; then 
				unset LICENSETYPE && i=0 && green " ${T[${L}129]} " &&
				cp -f /etc/wireguard/wgcf-profile.conf /etc/wireguard/wgcf.conf
				else
				wg-quick down wgcf >/dev/null 2>&1
				red " $(eval echo "${T[${L}13]}") " && exit 1
				fi
			fi
        	done
	green " ${T[${L}26]} "
	[[ $L = C ]] && COUNTRY4=$(translate "$COUNTRY4")
	[[ $L = C ]] && COUNTRY6=$(translate "$COUNTRY6")
	[[ $OPTION = [on] ]] && green " IPv4:$WAN4 $WARPSTATUS4 $COUNTRY4 $ASNORG4\n IPv6:$WAN6 $WARPSTATUS6 $COUNTRY6 $ASNORG6 "
}

# WARP 开关，先检查是否已安装，再根据当前状态转向相反状态
onoff(){ 
	! type -P wg-quick >/dev/null 2>&1 && red " ${T[${L}21]} " && exit 1
	[[ -n $(sudo wg 2>/dev/null) ]] && (wg-quick down wgcf >/dev/null 2>&1; green " ${T[${L}22]} ") || net
}

# 同步脚本至最新版本
ver(){
	sudo wget -N -P /etc/wireguard https://raw.githubusercontents.com/fscarmen/warp/main/pc/mac.sh
	chmod +x /etc/wireguard/mac.sh
	sudo ln -sf /etc/wireguard/mac.sh /usr/local/bin/warp
	green " ${T[${L}28]}:$(grep ^VERSION /etc/wireguard/mac.sh | sed "s/.*=//g")  ${T[${L}29]}：$(grep "T\[${L}1]" /etc/wireguard/menu.sh | cut -d \" -f2) " || red " ${T[${L}30]} "
	exit
}

uninstall(){
	unset IP4 IP6 WAN4 WAN6 COUNTRY4 COUNTRY6 ASNORG4 ASNORG6
	# 卸载 WGCF
	wg-quick down wgcf >/dev/null 2>&1
	type -p wg >/dev/null 2>&1 && brew uninstall wireguard-tools
	sudo rm -rf /usr/local/bin/wgcf /etc/wireguard /usr/local/bin/wireguard-go
	# 显示卸载结果
	ip4_info; [[ $L = C && -n "$COUNTRY4" ]] && COUNTRY4=$(translate "$COUNTRY4")
	ip6_info; [[ $L = C && -n "$COUNTRY6" ]] && COUNTRY6=$(translate "$COUNTRY6")
	green " ${T[${L}4]}\n IPv4：$WAN4 $COUNTRY4 $ASNORG4\n IPv6：$WAN6 $COUNTRY6 $ASNORG6 "
}

install(){
	# 进入工作目录
	cd /usr/local/bin
	sudo mkdir -p /etc/wireguard/ >/dev/null 2>&1

	# 输入 Warp+ 账户（如有），限制位数为空或者26位以防输入错误
	[[ -z $LICENSE ]] && reading " ${T[${L}6]} " LICENSE
	i=5
	until [[ -z $LICENSE || $LICENSE =~ ^[A-Z0-9a-z]{8}-[A-Z0-9a-z]{8}-[A-Z0-9a-z]{8}$ ]]
		do	(( i-- )) || true
			[[ $i = 0 ]] && red " ${T[${L}7]} " && exit 1 || reading " $(eval echo "${T[${L}8]}") " LICENSE
	done

	[[ -n $LICENSE && -z $NAME ]] && reading " ${T[${L}9]} " NAME
	[[ -n $NAME ]] && NAME="${NAME//[[:space:]]/_}" || NAME=${NAME:-'WARP'}

	# 脚本开始时间
	start=$(date +%s)

	# 安装 brew 和 wireguard-tools
	green " \n${T[${L}10]}\n "
	! type -p brew >/dev/null 2>&1 && /bin/zsh -c "$(curl -fsSL https://gitee.com/cunkai/HomebrewCN/raw/master/Homebrew.sh)"
	! type -p wg >/dev/null 2>&1 && brew install wireguard-tools

	# 判断 wgcf 的最新版本并安装
	green " \n${T[${L}11]}\n "
	latest=$(curl -fsSL "https://api.github.com/repos/ViRb3/wgcf/releases/latest" | grep "tag_name" | head -n 1 | cut -d : -f2 | sed 's/[ \"v,]//g')
	latest=${latest:-'2.2.13'}
	curl -m8 -o /usr/local/bin/wgcf https://raw.githubusercontents.com/fscarmen/warp/main/wgcf/wgcf_"$latest"_darwin_amd64

	# 安装 wireguard-go
	curl -o /usr/local/bin/wireguard-go_darwin_amd64.tar.gz https://raw.githubusercontents.com/fscarmen/warp/main/wireguard-go/wireguard-go_darwin_amd64.tar.gz &&
	tar xzf /usr/local/bin/wireguard-go_darwin_amd64.tar.gz -C /usr/local/bin/ && rm -f /usr/local/bin/wireguard-go_darwin_amd64.tar.gz

	# 添加执行权限
	chmod +x /usr/local/bin/wireguard-go /usr/local/bin/wgcf

	# 注册 WARP 账户 (将生成 wgcf-account.toml 文件保存账户信息，为避免文件已存在导致出错，先尝试删掉原文件)
	rm -f wgcf-account.toml
	until [[ -e wgcf-account.toml ]] >/dev/null 2>&1; do
		wgcf register --accept-tos >/dev/null 2>&1 && break
	done

	# 如有 Warp+ 账户，修改 license 并升级
	[[ -n $LICENSE ]] && yellow " \n${T[${L}13]}\n " && sed -i '' "s/license_key.*/license_key = \"$LICENSE\"/g" wgcf-account.toml &&
	( wgcf update --name "$NAME" | sudo tee /etc/wireguard/info.log 2>&1 || red " \n${T[${L}14]}\n " )

	# 生成 Wire-Guard 配置文件 (wgcf-profile.conf)
	wgcf generate >/dev/null 2>&1
  
	# 修改配置文件 wgcf-profile.conf 的内容,使得 IPv4 的流量均被 WireGuard 接管
	sed -i '' 's/engage.cloudflareclient.com/162.159.193.10/g' wgcf-profile.conf


	# 把 wgcf-profile.conf 复制到/etc/wireguard/ 并命名为 wgcf.conf
	sudo cp -f wgcf-profile.conf /etc/wireguard/wgcf.conf
	sudo cp -f /usr/local/bin/t.sh /etc/wireguard/mac.sh
	ln -sf /etc/wireguard/mac.sh /usr/local/bin/warp && green " ${T[${L}27]} " && chmod +x /usr/local/bin/warp
	echo "$L" 2>&1 | sudo tee /etc/wireguard/language

	# 自动刷直至成功（ warp bug，有时候获取不了ip地址）
	green " \n${T[${L}12]}\n "
	unset IP4 IP6 WAN4 WAN6 COUNTRY4 COUNTRY6 ASNORG4 ASNORG6 TRACE4 TRACE6 PLUS4 PLUS6 WARPSTATUS4 WARPSTATUS6
	net

	# 结果提示，脚本运行时间，次数统计
	end=$(date +%s)
	red "\n==============================================================\n"
	green " IPv4：$WAN4 $WARPSTATUS4 $COUNTRY4  $ASNORG4 "
	green " IPv6：$WAN6 $WARPSTATUS6 $COUNTRY6  $ASNORG6 "
	grep -sq 'Device name' /etc/wireguard/info.log 2>/dev/null && TYPE='+' || TYPE=' Teams'
	[[ $TRACE4$TRACE6 =~ plus ]] && green " $(eval echo "${T[${L}15]}") " && grep -sq 'Device name' /etc/wireguard/info.log && green " $(eval echo "${T[${L}17]}") "
	[[ $TRACE4$TRACE6 =~ on ]] && green " $(eval echo "${T[${L}16]}") "
	red "\n==============================================================\n"
	yellow " ${T[${L}18]}\n " && help
	[[ $TRACE4$TRACE6 = offoff ]] && red " ${T[${L}19]} "

	# 删除临时文件
	rm -f mac.sh wgcf-account.toml wgcf-profile.conf
}

# 传参选项 OPTION
[[ $1 != '[option]' ]] && OPTION=$(tr '[:upper:]' '[:lower:]' <<< "$1")

statistics_of_run-times
select_language

case "$OPTION" in
e ) L=E; check_operating_system; install;;
c ) L=C; check_operating_system; install;;
u ) uninstall;;
v ) ver;;
n ) net;;
o ) onoff;;
* ) help;;
esac
