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
T[E4]="WARP have been completely deleted!"
T[C4]="WARP 已彻底删除!"
T[E5]="The script supports macOS only. Feedback: [https://github.com/fscarmen/warp/issues]"
T[C5]="本脚本只支持 macOS, 问题反馈:[https://github.com/fscarmen/warp/issues]"
T[E6]="If there is a WARP+ License, please enter it, otherwise press Enter to continue:"
T[C6]="如有 WARP+ License 请输入，没有可回车继续:"
T[E7]="Input errors up to 5 times.The script is aborted."
T[C7]="输入错误达5次，脚本退出"
T[E8]="License should be 26 characters, please re-enter WARP+ License. Otherwise press Enter to continue. \(\${i} times remaining\):"
T[C8]="License 应为26位字符，请重新输入 WARP+ License，没有可回车继续\(剩余\${i}次\):"
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
T[E20]="warp h (help)\n warp o (WARP on-off)\n warp u (Turn off and uninstall WARP interface)\n warp a (Upgrade to WARP+ or Teams account)\n warp e (Install WARP in English)\n warp c (Install WARP in Chinese)\n warp v (Sync the latest version)"
T[C20]="warp h (帮助菜单）\n warp o (临时warp开关)\n warp u (卸载 WARP )\n warp a (免费 WARP 账户升级 WARP+ 或 Teams)\n warp e (英文安装 WARP )\n warp c (中文安装 WARP )\n warp v (同步脚本至最新版本)"
T[E21]="WGCF WARP has not been installed yet."
T[C21]="WGCF WARP 还未安装"
T[E22]="WARP is turned off. It could be turned on again by [warp o]"
T[C22]="已暂停 WARP，再次开启可以用 warp o"
T[E23]="WireGuard tools are not installed or the configuration file wgcf.conf cannot be found, please reinstall."
T[C23]="没有安装 WireGuard tools 或者找不到配置文件 wgcf.conf，请重新安装。"
T[E24]="Maximum \${j} attempts to get WARP IP..."
T[C24]="后台获取 WARP IP 中,最大尝试\${j}次……"
T[E25]="Try \${i}"
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
T[E31]="WARP+ or Teams account is working now. No need to upgrade."
T[C31]="已经是 WARP+ 或者 Teams 账户，不需要升级"
T[E32]="Cannot find the account file: /etc/wireguard/wgcf-account.toml, you can reinstall with the WARP+ License"
T[C32]="找不到账户文件：/etc/wireguard/wgcf-account.toml，可以卸载后重装，输入 WARP+ License"
T[E33]="Cannot find the configuration file: /etc/wireguard/wgcf.conf, you can reinstall with the WARP+ License"
T[C33]="找不到配置文件： /etc/wireguard/wgcf.conf，可以卸载后重装，输入 WARP+ Licens"
T[E34]="\n 1.Update with WARP+ license\n 2.Update with Teams (You need upload the Teams file to a private storage space before. For example: gist.github.com)\n"
T[C34]="\n 1.使用 WARP+ license 升级\n 2.使用 Teams 升级 (你须事前把 Teams 文件上传到私密存储空间，比如：gist.github.com )\n"
T[E35]="Successfully upgraded to a WARP+ account"
T[C35]="已升级为 WARP+ 账户"
T[E36]="Device name"
T[C36]="设备名"
T[E37]="WARP+ quota"
T[C37]="剩余流量"
T[E38]="The upgrade failed, WARP+ account error or more than 5 devices have been activated. Free WARP account to continu."
T[C38]="升级失败，WARP+ 账户错误或者已激活超过5台设备，自动更换免费 WARP 账户继续"
T[E39]="Successfully upgraded to a WARP Teams account"
T[C39]="已升级为 WARP Teams 账户"
T[E40]="Please enter the correct number"
T[C40]="请输入正确数字"
T[E41]="Please Input WARP+ license:"
T[C41]="请输入WARP+ License:"
T[E42]="License should be 26 characters, please re-enter WARP+ License. Otherwise press Enter to continue. \(\${i} times remaining\): "
T[C42]="License 应为26位字符,请重新输入 WARP+ License \(剩余\${i}次\): "
T[E43]="Please customize the WARP+ device name (Default is [WARP] if left blank):"
T[C43]="请自定义 WARP+ 设备名 (如果不输入，默认为 [WARP]):"
T[E44]="Please input Teams file URL (To use the one provided by the script if left blank):" 
T[C44]="请输入 Teams 文件 URL (如果留空，则使用脚本提供的):"
T[E45]="( match √ )"
T[C45]="( 符合 √ )"
T[E46]="( mismatch X )"
T[C46]="( 不符合 X )"
T[E47]="\\\n Please confirm\\\n Private key\\\t: \$PRIVATEKEY \$MATCH1\\\n Public key\\\t: \$PUBLICKEY \$MATCH2\\\n Address IPv4\\\t: \$ADDRESS4/32 \$MATCH3\\\n Address IPv6\\\t: \$ADDRESS6/128 \$MATCH4\\\n"
T[C47]="\\\n 请确认Teams 信息\\\n Private key\\\t: \$PRIVATEKEY \$MATCH1\\\n Public key\\\t: \$PUBLICKEY \$MATCH2\\\n Address IPv4\\\t: \$ADDRESS4/32 \$MATCH3\\\n Address IPv6\\\t: \$ADDRESS6/128 \$MATCH4\\\n"
T[E48]="comfirm please enter [y] , and other keys to use free account:"
T[C48]="确认请按 y ，其他按键则使用免费账户:"
T[E49]="\n Is there a WARP+ or Teams account?\n 1. WARP+\n 2. Teams\n 3. use free account (default)\n"
T[C49]="\n 如有 WARP+ 或 Teams 账户请选择\n 1. WARP+\n 2. Teams\n 3. 使用免费账户 (默认)\n"
T[E50]="If there is a WARP+ License, please enter it, otherwise press Enter to continue:"
T[C50]="如有 WARP+ License 请输入，没有可回车继续:"
T[E51]="License should be 26 characters, please re-enter WARP+ License. Otherwise press Enter to continue. \(\${i} times remaining\):"
T[C51]="License 应为26位字符，请重新输入 WARP+ License，没有可回车继续\(剩余\${i}次\):"
T[E52]="There have been more than \${j} failures. The script is aborted. Feedback: [https://github.com/fscarmen/warp/issues]"
T[C52]="失败已超过\${j}次，脚本中止，问题反馈:[https://github.com/fscarmen/warp/issues]"

# 自定义字体彩色，read 函数，友道翻译函数
red(){ echo -e "\033[31m\033[01m$1\033[0m"; }
green(){ echo -e "\033[32m\033[01m$1\033[0m"; }
yellow(){ echo -e "\033[33m\033[01m$1\033[0m"; }
reading(){ read -rp "$(green "$1")" "$2"; }
translate(){ [[ -n "$1" ]] && curl -ksm8 "http://fanyi.youdao.com/translate?&doctype=json&type=AUTO&i=${1//[[:space:]]/}" | cut -d \" -f18 2>/dev/null; }

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
	ARCHITECTURE=$(uname -m | sed s/x86_64/amd64/)
}

# 检测 IPv4 IPv6 信息，WARP Ineterface 开启，普通还是 Plus账户 和 IP 信息
ip4_info(){
	unset IP4 LAN4 COUNTRY4 ASNORG4 TRACE4 PLUS4 WARPSTATUS4
	IP4=$(curl -ks4m10 https://ip.gs/json)
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
	IP6=$(curl -ks6m10 https://ip.gs/json)
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
				red " $(eval echo "${T[${L}52]}") " && exit 1
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
	! type -p wg-quick >/dev/null 2>&1 && red " ${T[${L}21]} " && exit 1
	[[ -n $(sudo wg 2>/dev/null) ]] && (wg-quick down wgcf >/dev/null 2>&1; green " ${T[${L}22]} ") || net
}

# 同步脚本至最新版本
ver(){
	sudo wget -N -P /etc/wireguard https://raw.githubusercontents.com/fscarmen/warp/main/pc/mac.sh
	sudo chmod +x /etc/wireguard/mac.sh
	sudo ln -sf /etc/wireguard/mac.sh /usr/local/bin/warp
	green " ${T[${L}28]}:$(grep ^VERSION /etc/wireguard/mac.sh | sed "s/.*=//g")  ${T[${L}29]}：$(grep "T\[${L}1]" /etc/wireguard/mac.sh | cut -d \" -f2) " || red " ${T[${L}30]} "
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
	# 进入工作目录，先删除之前安装，可能导致失败的文件
	cd /usr/local/bin || exit
	sudo rm -rf wgcf wireguard-go wgcf-account.toml wgcf-profile.conf /etc/wireguard
	sudo mkdir -p /etc/wireguard/ >/dev/null 2>&1

	# 询问是否有 WARP+ 或 Teams 账户
	[[ -z $LICENSETYPE ]] && yellow " ${T[${L}49]}" && reading " ${T[${L}3]} " LICENSETYPE
	case $LICENSETYPE in
	1 ) input_license;;	
	2 ) input_url;;
	esac

	[[ -n $LICENSE && -z $NAME ]] && reading " ${T[${L}9]} " NAME
	[[ -n $NAME ]] && NAME="${NAME//[[:space:]]/_}" || NAME=${NAME:-'WARP'}

	# 脚本开始时间
	start=$(date +%s)

	# 安装 brew 和 wireguard-tools
	green "\n ${T[${L}10]}\n "
	! type -p brew >/dev/null 2>&1 && /bin/zsh -c "$(curl -fsSL https://gitee.com/cunkai/HomebrewCN/raw/master/Homebrew.sh)"
	! type -p wg >/dev/null 2>&1 && brew install wireguard-tools

	# 判断 wgcf 的最新版本并安装
	green "\n ${T[${L}11]}\n "
	latest=$(curl -fsSL "https://api.github.com/repos/ViRb3/wgcf/releases/latest" | grep "tag_name" | head -n 1 | cut -d : -f2 | sed 's/[ \"v,]//g')
	latest=${latest:-'2.2.13'}
	[[ ! -e /usr/local/bin/wgcf ]] && curl -o /usr/local/bin/wgcf https://raw.githubusercontents.com/fscarmen/warp/main/wgcf/wgcf_"$latest"_darwin_"$ARCHITECTURE"

	# 安装 wireguard-go
	[[ ! -e /usr/local/bin/wireguard-go ]] && curl -o /usr/local/bin/wireguard-go_darwin_"$ARCHITECTURE".tar.gz https://raw.githubusercontents.com/fscarmen/warp/main/wireguard-go/wireguard-go_darwin_"$ARCHITECTURE".tar.gz &&
	tar xzf /usr/local/bin/wireguard-go_darwin_"$ARCHITECTURE".tar.gz -C /usr/local/bin/ && rm -f /usr/local/bin/wireguard-go_darwin_"$ARCHITECTURE".tar.gz

	# 添加执行权限
	sudo chmod +x /usr/local/bin/wireguard-go /usr/local/bin/wgcf

	# 注册 WARP 账户 (将生成 wgcf-account.toml 文件保存账户信息，为避免文件已存在导致出错，先尝试删掉原文件)
	rm -f wgcf-account.toml
	until [[ -e wgcf-account.toml ]] >/dev/null 2>&1; do
		wgcf register --accept-tos >/dev/null 2>&1 && break
	done

	# 如有 WARP+ 账户，修改 license 并升级
	[[ -n $LICENSE ]] && yellow " \n${T[${L}13]}\n " && sudo sed -i '' "s/license_key.*/license_key = \"$LICENSE\"/g" wgcf-account.toml &&
	( wgcf update --name "$NAME" | sudo tee /etc/wireguard/info.log >/dev/null 2>&1 || red " \n${T[${L}14]}\n " )

	# 生成 Wire-Guard 配置文件 (wgcf-profile.conf)
	wgcf generate >/dev/null 2>&1

	# 如有 Teams，改为 Teams 账户信息
	[[ $CONFIRM = [Yy] ]] && echo "$TEAMS" | sudo tee /etc/wireguard/info.log >/dev/null 2>&1
	sudo sed -i '' "s#PrivateKey.*#PrivateKey = $PRIVATEKEY#g;s#Address.*32#Address = ${ADDRESS4}/32#g;s#Address.*128#Address = ${ADDRESS6}/128#g;s#PublicKey.*#PublicKey = $PUBLICKEY#g" wgcf-profile.conf
  
	# 修改配置文件 wgcf-profile.conf 的内容, 更换 Endpoint 和 DNS
	sudo sed -i '' 's/engage.cloudflareclient.com/162.159.193.10/g;s/1.1.1.1/8.8.8.8,&/g' wgcf-profile.conf

	# 把 wgcf-profile.conf 复制到/etc/wireguard/ 并命名为 wgcf.conf
	sudo cp -f wgcf-profile.conf /etc/wireguard/wgcf.conf
	sudo mv -f wgcf-account.toml wgcf-profile.conf mac.sh /etc/wireguard >/dev/null 2>&1
	ln -sf /etc/wireguard/mac.sh /usr/local/bin/warp && green " ${T[${L}27]} "
	sudo chmod +x /usr/local/bin/warp
	echo "$L" | sudo tee /etc/wireguard/language >/dev/null 2>&1

	# 自动刷直至成功（ warp bug，有时候获取不了ip地址）
	green "\n ${T[${L}12]}\n "
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

# 输入 WARP+ 账户（如有），限制位数为空或者26位以防输入错误
input_license(){
	[[ -z $LICENSE ]] && reading " ${T[${L}50]} " LICENSE
	i=5
	until [[ -z $LICENSE || $LICENSE =~ ^[A-Z0-9a-z]{8}-[A-Z0-9a-z]{8}-[A-Z0-9a-z]{8}$ ]]
		do	(( i-- )) || true
			[[ $i = 0 ]] && red " ${T[${L}29]} " && exit 1 || reading " $(eval echo "${T[${L}51]}") " LICENSE
	done
	[[ -n $LICENSE && -z $NAME ]] && reading " ${T[${L}43]} " NAME
	[[ -n $NAME ]] && NAME="${NAME//[[:space:]]/_}" || NAME=${NAME:-'WARP'}
}

# 升级 WARP+ 账户（如有），限制位数为空或者26位以防输入错误，WARP interface 可以自定义设备名(不允许字符串间有空格，如遇到将会以_代替)
update_license(){
	[[ -z $LICENSE ]] && reading " ${T[${L}41]} " LICENSE
	i=5
	until [[ $LICENSE =~ ^[A-Z0-9a-z]{8}-[A-Z0-9a-z]{8}-[A-Z0-9a-z]{8}$ ]]
		do	(( i-- )) || true
			[[ $i = 0 ]] && red " ${T[${L}7]} " && exit 1 || reading " $(eval echo "${T[${L}42]}") " LICENSE
	done
	[[ -n $LICENSE && -z $NAME ]] && reading " ${T[${L}43]} " NAME
	[[ -n $NAME ]] && NAME="${NAME//[[:space:]]/_}" || NAME=${NAME:-'WARP'}
}

# 输入 Teams 账户 URL（如有）
input_url(){
	[[ -z $URL ]] && reading " ${T[${L}44]} " URL
	URL=${URL:-'https://gist.githubusercontent.com/fscarmen/56aaf02d743551737c9973b8be7a3496/raw/61bf63e68e4e91152545679b8f11c72cac215128/2021.12.21'}
	TEAMS=$(curl -sSL "$URL" | sed "s/\"/\&quot;/g")
	PRIVATEKEY=$(expr "$TEAMS" : '.*private_key&quot;>\([^<]*\).*')
	PUBLICKEY=$(expr "$TEAMS" : '.*public_key&quot;:&quot;\([^&]*\).*')
	ADDRESS4=$(expr "$TEAMS" : '.*v4&quot;:&quot;\(172[^&]*\).*')
	ADDRESS6=$(expr "$TEAMS" : '.*v6&quot;:&quot;\([^[&]*\).*')
	[[ $PRIVATEKEY =~ ^[A-Z0-9a-z/+]{43}=$ ]] && MATCH1=${T[${L}45]} || MATCH1=${T[${L}46]}
	[[ $PUBLICKEY =~ ^[A-Z0-9a-z/+]{43}=$ ]] && MATCH2=${T[${L}45]} || MATCH2=${T[${L}46]}
	[[ $ADDRESS4 =~ ^172.16.[01].[0-9]{1,3}$ ]] && MATCH3=${T[${L}45]} || MATCH3=${T[${L}46]}
	[[ $ADDRESS6 =~ ^fd01(:[0-9a-f]{0,4}){7}$ ]] && MATCH4=${T[${L}45]} || MATCH4=${T[${L}46]}
	yellow " $(eval echo "${T[${L}47]}") " && reading " ${T[${L}48]} " CONFIRM
}

update(){
	# 不符合条件的脚本退出
	! type -p wg-quick >/dev/null 2>&1 && red " ${T[${L}21]} " && exit 1
	[[ ! -e /etc/wireguard/wgcf-account.toml ]] && red " ${T[${L}32]} " && exit 1
	[[ ! -e /etc/wireguard/wgcf.conf ]] && red " ${T[${L}33]} " && exit 1
	ip4_info; [[ $TRACE4 =~ plus ]] && red " ${T[${L}31]} " && exit 1
	ip6_info; [[ $TRACE6 =~ plus ]] && red " ${T[${L}31]} " && exit 1

	# 选择账户升级的类型
	[[ -z $LICENSETYPE ]] && yellow " ${T[${L}34]}" && reading " ${T[${L}3]} " LICENSETYPE
	case $LICENSETYPE in
	1 ) update_license
	cd /etc/wireguard || exit
	sudo sed -i '' "s#license_key.*#license_key = \"$LICENSE\"#g" wgcf-account.toml &&
	wgcf update --name "$NAME" | sudo tee /etc/wireguard/info.log >/dev/null 2>&1 &&
	(wgcf generate >/dev/null 2>&1
	sudo sed -i '' "2s#.*#$(sed -ne 2p wgcf-profile.conf)#;3s#.*#$(sed -ne 3p wgcf-profile.conf)#;4s#.*#$(sed -ne 4p wgcf-profile.conf)#" wgcf.conf
	wg-quick down wgcf >/dev/null 2>&1
	net
	[[ $(curl -ks4 https://www.cloudflare.com/cdn-cgi/trace | grep warp | sed "s/warp=//g") = plus || $(curl -ks6 https://www.cloudflare.com/cdn-cgi/trace | grep warp | sed "s/warp=//g") = plus ]] &&
	green " ${T[${L}35]}\n ${T[${L}36]}：$(grep 'Device name' /etc/wireguard/info.log | awk '{ print $NF }')\n ${T[${L}37]}：$(grep Quota /etc/wireguard/info.log | awk '{ print $(NF-1), $NF }')" ) || red " ${T[${L}38]} ";;

	2 ) input_url
	[[ $CONFIRM = [Yy] ]] && (echo "$TEAMS" | sudo tee /etc/wireguard/info.log >/dev/null 2>&1
	sudo sed -i '' "s#PrivateKey.*#PrivateKey = $PRIVATEKEY#g;s#Address.*32#Address = ${ADDRESS4}/32#g;s#Address.*128#Address = ${ADDRESS6}/128#g;s#PublicKey.*#PublicKey = $PUBLICKEY#g" /etc/wireguard/wgcf.conf
	wg-quick down wgcf >/dev/null 2>&1; net
	[[ $(curl -ks4 https://www.cloudflare.com/cdn-cgi/trace | grep warp | sed "s/warp=//g") = plus || $(curl -ks6 https://www.cloudflare.com/cdn-cgi/trace | grep warp | sed "s/warp=//g") = plus ]] && green " ${T[${L}39]} ");;

	* ) red " ${T[${L}40]} [1-2] "; sleep 1; update
	esac
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
a ) update;;
n ) net;;
o ) onoff;;
* ) help;;
esac
