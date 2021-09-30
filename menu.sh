# 字体彩色
red(){
	echo -e "\033[31m\033[01m$1\033[0m"
    }
green(){
	echo -e "\033[32m\033[01m$1\033[0m"
    }
yellow(){
	echo -e "\033[33m\033[01m$1\033[0m"
}

# 判断是否大陆 VPS，如连不通 CloudFlare 的 IP，则 WARP 项目不可用
ping -4 -c1 -W1 162.159.192.1 >/dev/null 2>&1 && ipv4=1 || ipv4=0
ping -6 -c1 -W1 2606:4700:d0::a29f:c001 >/dev/null 2>&1 && ipv6=1 || ipv6=0
[[ $ipv4$ipv6 = 00 ]] && red " 与 WARP 的服务器连接不上，安装中止，或许是大陆 VPS ，问题反馈:https://github.com/fscarmen/warp/issues " && rm -f menu.sh && exit 0

# 判断操作系统，只支持 Debian、Ubuntu 或 Centos,如非上述操作系统，删除临时文件，退出脚本
[[ $(hostnamectl | tr A-Z a-z) =~ debian ]] && system=debian
[[ $(hostnamectl | tr A-Z a-z) =~ ubuntu ]] && system=ubuntu
[[ $(hostnamectl | tr A-Z a-z) =~ centos ]] && system=centos
[[ -z $system ]] && red " 本脚本只支持 Debian、Ubuntu 或 CentOS 系统,问题反馈:https://github.com/fscarmen/warp/issues  " && rm -f menu.sh && exit 0

# 必须以root运行脚本
[[ $(id -u) != 0 ]] && red " 必须以root方式运行脚本，可以输入 sudo -i 后重新下载运行，问题反馈:https://github.com/fscarmen/warp/issues  " && rm -f menu.sh && exit 0

green " 检查环境中…… "

# 判断处理器架构
[[ $(hostnamectl | tr A-Z a-z | grep architecture) =~ arm ]] && architecture=arm64 || architecture=amd64

# 判断虚拟化，选择 wireguard内核模块 还是 wireguard-go
[[ $(hostnamectl | tr A-Z a-z | grep virtualization) =~ openvz|lxc ]] && lxc=1

# 判断当前 IPv4 与 IPv6 ，归属 及 WARP 是否开启
[[ $ipv4 = 1 ]] && lan4=$(ip route get 162.159.192.1 2>/dev/null | grep -oP 'src \K\S+') &&
		wan4=$(wget -qO- -4 ip.gs) &&
		country4=$(wget -qO- -4 https://ip.gs/country) &&
		[[ $(wget -qO- -4 https://www.cloudflare.com/cdn-cgi/trace | grep warp=on) ]] && warp4=1
[[ $ipv6 = 1 ]] && lan6=$(ip route get 2606:4700:d0::a29f:c001 2>/dev/null | grep -oP 'src \K\S+') &&
		wan6=$(wget -qO- -6 ip.gs) &&
		country6=$(wget -qO- -6 https://ip.gs/country) &&
		[[ $(wget -qO- -6 https://www.cloudflare.com/cdn-cgi/trace | grep warp=on) ]] && warp6=1

# 判断当前 WARP 状态，决定变量 plan，变量 plan 含义：01=IPv6,	10=IPv4,	11=IPv4+IPv6,	2=WARP已开启
[[ $warp4 = 1 || $warp6 = 1 ]] && plan=2 || plan=$ipv4$ipv6

# 在KVM的前提下，判断 Linux 版本是否小于 5.6，如是则安装 wireguard 内核模块，变量 wg=1。由于 linux 不能直接用小数作比较，所以用 （主版本号 * 100 + 次版本号 ）与 506 作比较
[[ $lxc != 1 && $(($(uname  -r | cut -d . -f1) * 100 +  $(uname  -r | cut -d . -f2))) -lt 506 ]] && wg=1

# WGCF 配置修改，其中用到的 162.159.192.1 和 2606:4700:d0::a29f:c001 均是 engage.cloudflareclient.com 的IP
modify1='sed -i "/\:\:\/0/d" wgcf-profile.conf && sed -i "s/engage.cloudflareclient.com/[2606:4700:d0::a29f:c001]/g" wgcf-profile.conf'
modify2='sed -i "7 s/^/PostUp = ip -6 rule add from '$lan6' lookup main\n/" wgcf-profile.conf && sed -i "8 s/^/PostDown = ip -6 rule delete from '$lan6' lookup main\n/" wgcf-profile.conf && sed -i "s/engage.cloudflareclient.com/[2606:4700:d0::a29f:c001]/g" wgcf-profile.conf && sed -i "s/1.1.1.1/1.1.1.1,9.9.9.9,8.8.8.8/g" wgcf-profile.conf'
modify3='sed -i "/0\.\0\/0/d" wgcf-profile.conf && sed -i "s/engage.cloudflareclient.com/162.159.192.1/g" wgcf-profile.conf && sed -i "s/1.1.1.1/9.9.9.9,8.8.8.8,1.1.1.1/g" wgcf-profile.conf'
modify4='sed -i "7 s/^/PostUp = ip -4 rule add from '$lan4' lookup main\n/" wgcf-profile.conf && sed -i "8 s/^/PostDown = ip -4 rule delete from '$lan4' lookup main\n/" wgcf-profile.conf && sed -i "s/engage.cloudflareclient.com/162.159.192.1/g" wgcf-profile.conf && sed -i "s/1.1.1.1/9.9.9.9,8.8.8.8,1.1.1.1/g" wgcf-profile.conf'
modify5='sed -i "7 s/^/PostUp = ip -4 rule add from '$lan4' lookup main\n/" wgcf-profile.conf && sed -i "8 s/^/PostDown = ip -4 rule delete from '$lan4' lookup main\n/" wgcf-profile.conf && sed -i "9 s/^/PostUp = ip -6 rule add from '$lan6' lookup main\n/" wgcf-profile.conf && sed -i "10 s/^/PostDown = ip -6 rule delete from '$lan6' lookup main\n/" wgcf-profile.conf && sed -i "s/engage.cloudflareclient.com/162.159.192.1/g" wgcf-profile.conf && sed -i "s/1.1.1.1/9.9.9.9,8.8.8.8,1.1.1.1/g" wgcf-profile.conf'

# VPS 当前状态
status(){
	clear
	yellow "本项目专为 VPS 添加 wgcf 网络接口，详细说明：https://github.com/fscarmen/warp\n脚本特点:\n	* 根据不同系统综合情况显示不同的菜单，避免出错\n	* 结合 Linux 版本和虚拟化方式，自动优选三个 WireGuard 方案。网络性能方面：内核集成 WireGuard＞安装内核模块＞wireguard-go\n	* 智能判断 WGCF 作者 github库的最新版本 （Latest release\n	* 智能判断vps操作系统：Ubuntu 18.04、Ubuntu 20.04、Debian 10、Debian 11、CentOS 7、CentOS 8，请务必选择 LTS 系统\n	* 智能判断硬件结构类型：Architecture 为 AMD 或者 ARM\n	* 智能分析内网和公网IP生成 WGCF 配置文件\n	* 输出执行结果，提示是否使用 WARP IP ，IP 归属地\n"
	red "======================================================================================================================\n"
	green " 系统信息：\n	当前操作系统：$(hostnamectl | grep -i operating | cut -d : -f2)\n	内核：$(uname -r)\n	处理器架构：$architecture\n	虚拟化：$(hostnamectl | grep -i virtualization | cut -d : -f2) "
	[[ $warp4 = 1 ]] && green "	IPv4：$wan4 ( WARP IPv4 ) $country4 " || green "	IPv4：$wan4 $country4 "
	[[ $warp6 = 1 ]] && green "	IPv6：$wan6 ( WARP IPv6 ) $country6 " || green "	IPv6：$wan6 $country6 "
	[[ $plan = 2 ]] && green "	WARP 已开启" || green "	WARP 未开启 "
 	red "\n======================================================================================================================\n"
		}

# WGCF 安装
install(){
	# 脚本开始时间
	start=$(date +%s)
	
	green " 进度  1/3： 安装系统依赖 "

	# 先删除之前安装，可能导致失败的文件，添加环境变量
	rm -f /usr/local/bin/wgcf /etc/wireguard/wgcf.conf /usr/bin/wireguard-go  wgcf-account.toml  wgcf-profile.conf
	[[ $PATH =~ /usr/local/bin ]] || export PATH=$PATH:/usr/local/bin
	
        # 根据系统选择需要安装的依赖
	debian(){
		# 更新源
		apt -y update

		# 添加 backports 源,之后才能安装 wireguard-tools 
		apt -y install lsb-release
		echo "deb http://deb.debian.org/debian $(lsb_release -sc)-backports main" > /etc/apt/sources.list.d/backports.list

		# 再次更新源
		apt -y update

		# 安装一些必要的网络工具包和wireguard-tools (Wire-Guard 配置工具：wg、wg-quick)
		apt -y --no-install-recommends install net-tools iproute2 openresolv dnsutils wireguard-tools

		# 如 Linux 版本低于5.6并且是 kvm，则安装 wireguard 内核模块
		[[ $wg = 1 ]] && apt -y --no-install-recommends install linux-headers-$(uname -r) && apt -y --no-install-recommends install wireguard-dkms
		}
		
	ubuntu(){
		# 更新源
		apt -y update

		# 安装一些必要的网络工具包和 wireguard-tools (Wire-Guard 配置工具：wg、wg-quick)
		apt -y --no-install-recommends install net-tools iproute2 openresolv dnsutils wireguard-tools
		}
		
	centos(){
		# 安装一些必要的网络工具包和wireguard-tools (Wire-Guard 配置工具：wg、wg-quick)
		yum -y install epel-release
		yum -y install curl net-tools wireguard-tools

		# 如 Linux 版本低于5.6并且是 kvm，则安装 wireguard 内核模块
		[[ $wg = 1 ]] && curl -Lo /etc/yum.repos.d/wireguard.repo https://copr.fedorainfracloud.org/coprs/jdoss/wireguard/repo/epel-7/jdoss-wireguard-epel-7.repo &&
		yum -y install epel-release wireguard-dkms

		# 升级所有包同时也升级软件和系统内核
		yum -y update
		}

	$system

	# 安装并认证 WGCF
	green " 进度  2/3： 安装 WGCF "

	# 判断 wgcf 的最新版本,如因 github 接口问题未能获取，默认 v2.2.8
	latest=$(wget --no-check-certificate -qO- -t1 -T1 "https://api.github.com/repos/ViRb3/wgcf/releases/latest" | grep "tag_name" | head -n 1 | cut -d : -f2 | sed 's/\"//g;s/v//g;s/,//g;s/ //g')
	[[ -z $latest ]] && latest='2.2.8'

	# 安装 wgcf，尽量下载官方的最新版本，如官方 wgcf 下载不成功，将使用 jsDelivr 的 CDN，以更好的支持双栈
	wget -t1 -T1 -N --no-check-certificate -O /usr/local/bin/wgcf https://github.com/ViRb3/wgcf/releases/download/v$latest/wgcf_${latest}_linux_$architecture
	[[ $? != 0 ]] && wget -N --no-check-certificate -O /usr/local/bin/wgcf https://cdn.jsdelivr.net/gh/fscarmen/warp/wgcf_${latest}_linux_$architecture

	# 添加执行权限
	chmod +x /usr/local/bin/wgcf

	# 如是 lXC，安装 wireguard-go
	[[ $lxc = 1 ]] && wget -N --no-check-certificate -P /usr/bin https://cdn.jsdelivr.net/gh/fscarmen/warp/wireguard-go && chmod +x /usr/bin/wireguard-go

	# 注册 WARP 账户 (将生成 wgcf-account.toml 文件保存账户信息，为避免文件已存在导致出错，先尝试删掉原文件)
	rm -f wgcf-account.toml
	yellow " WGCF 注册中…… "
	until [[ -e wgcf-account.toml ]]
	  do
	   echo | wgcf register >/dev/null 2>&1
	done

	# 生成 Wire-Guard 配置文件 (wgcf-profile.conf)
	wgcf generate >/dev/null 2>&1

	# 修改配置文件
	echo $modify | sh

	# 把 wgcf-profile.conf 复制到/etc/wireguard/ 并命名为 wgcf.conf
	cp -f wgcf-profile.conf /etc/wireguard/wgcf.conf

	# 自动刷直至成功（ warp bug，有时候获取不了ip地址），记录新的 IPv4 和 IPv6 地址和归属地
	green " 进度  3/3： 运行 WGCF "
	yellow " 后台获取 WARP IP 中…… "

	# 清空之前的相关变量值
	unset wan4 wan6 country4 country6 warp4 warp6

	wg-quick up wgcf >/dev/null 2>&1
	wan4=$(wget -T1 -t1 -qO- -4 ip.gs)
	wan6=$(wget -T1 -t1 -qO- -6 ip.gs)
	until [[ -n $wan4 && -n $wan6 ]]
	  do
	   wg-quick down wgcf >/dev/null 2>&1
	   wg-quick up wgcf >/dev/null 2>&1
	   wan4=$(wget -T1 -t1 -qO- -4 ip.gs)
	   wan6=$(wget -T1 -t1 -qO- -6 ip.gs)
	done
	country4=$(wget -qO- -4 https://ip.gs/country)
	[[ $(wget -qO- -4 https://www.cloudflare.com/cdn-cgi/trace | grep warp=on) ]] && warp4=1
	country6=$(wget -qO- -6 https://ip.gs/country)
	[[ $(wget -qO- -6 https://www.cloudflare.com/cdn-cgi/trace | grep warp=on) ]] && warp6=1
	
	# 设置开机启动，由于warp bug，有时候获取不了ip地址，在定时任务加了重启后自动刷网络
	systemctl enable wg-quick@wgcf >/dev/null 2>&1
	grep -qE '^@reboot[ ]*root[ ]*bash[ ]*/etc/wireguard/WARP_AutoUp.sh' /etc/crontab || echo '@reboot root bash /etc/wireguard/WARP_AutoUp.sh' >> /etc/crontab
	echo '[[ $(type -P wg-quick) ]] && [[ -e /etc/wireguard/wgcf.conf ]] && wg-quick up wgcf >/dev/null 2>&1' > /etc/wireguard/WARP_AutoUp.sh
	echo 'until [[ -n $(wget -T1 -t1 -qO- -4 ip.gs) && -n $(wget -T1 -t1 -qO- -6 ip.gs) ]]' >> /etc/wireguard/WARP_AutoUp.sh
	echo '	do' >> /etc/wireguard/WARP_AutoUp.sh
	echo '		wg-quick down wgcf >/dev/null 2>&1' >> /etc/wireguard/WARP_AutoUp.sh
	echo '		wg-quick up wgcf >/dev/null 2>&1' >> /etc/wireguard/WARP_AutoUp.sh
 	echo '	done' >> /etc/wireguard/WARP_AutoUp.sh

	# 优先使用 IPv4 网络
	[[ -e /etc/gai.conf ]] && [[ $(grep '^[ ]*precedence[ ]*::ffff:0:0/96[ ]*100' /etc/gai.conf) ]] || echo 'precedence ::ffff:0:0/96  100' >> /etc/gai.conf

	# 删除临时文件
	rm -f wgcf-account.toml  wgcf-profile.conf menu.sh

	# 结果提示，脚本运行时间
	[[ $warp4 = 1 ]] && green " IPv4：$wan4 ( WARP IPv4 ) $country4 " || green " IPv4：$wan4 $country4 "
	[[ $warp6 = 1 ]] && green " IPv6：$wan6 ( WARP IPv6 ) $country6 " || green " IPv6：$wan6 $country6 "
	end=$(date +%s)
	green " 恭喜！WARP已开启，总耗时:$(( $end - $start ))秒 "
		}

# 关闭 WARP 网络接口，并删除 WGCF
uninstall(){
	unset wan4 wan6 country4 country6
	systemctl disable wg-quick@$(wg | grep interface | cut -d : -f2) >/dev/null 2>&1
	wg-quick down $(wg | grep interface | cut -d : -f2) >/dev/null 2>&1
	apt -y autoremove wireguard-tools wireguard-dkms 2>/dev/null
	yum -y autoremove wireguard-tools wireguard-dkms 2>/dev/null
	rm -rf /usr/local/bin/wgcf /etc/wireguard /usr/bin/wireguard-go /etc/wireguard wgcf-account.toml wgcf-profile.conf menu.sh
	[[ -e /etc/gai.conf ]] && sed -i '/^precedence[ ]*::ffff:0:0\/96[ ]*100/d' /etc/gai.conf
	sed -i '/^@reboot.*WARP_AutoUp/d' /etc/crontab
	wan4=$(wget -T1 -t1 -qO- -4 ip.gs)
	wan6=$(wget -T1 -t1 -qO- -6 ip.gs)
	country4=$(wget -T1 -t1 -qO- -4 https://ip.gs/country)
	country6=$(wget -T1 -t1 -qO- -6 https://ip.gs/country)
	[[ -z $(wg) ]] >/dev/null 2>&1 && green " WGCF 已彻底删除!\n IPv4：$wan4 $country4\n IPv6：$wan6 $country6 " || red " 没有清除干净，请重启(reboot)后尝试再次删除 "
		}

# 安装BBR
bbrInstall() {
	red "\n=============================================================="
	green "BBR、DD脚本用的[ylx2016]的成熟作品，地址[https://github.com/ylx2016/Linux-NetSpeed]，请熟知"
	yellow "1.安装脚本【推荐原版BBR+FQ】"
	yellow "2.回退主目录"
	red "=============================================================="
	read -p "请选择：" installBBRStatus
	case "$installBBRStatus" in
		1 ) wget -N --no-check-certificate "https://raw.githubusercontent.com/ylx2016/Linux-NetSpeed/master/tcp.sh" && chmod +x tcp.sh && ./tcp.sh;;
		2 ) menu$plan;;
		* ) red "请输入正确数字 [1-2]"; sleep 1; bbrInstall;;
		esac
		}

# IPv6
menu01(){
	status
	green " 1. 为 IPv6 only 添加 IPv4 网络接口 "
	green " 2. 为 IPv6 only 添加双栈网络接口 "
	green " 3. 关闭 WARP 网络接口，并删除 WGCF "
	green " 4. 升级内核、安装BBR、DD脚本 "
	green " 0. 退出脚本 \n "
	read -p "请输入数字:" choose01
		case "$choose01" in
		1 ) 	modify=$modify1;	install;;
		2 )	modify=$modify2;	install;;
		3 ) 	uninstall;;
		4 )	bbrInstall;;
		0 ) 	exit 1;;
		* ) 	red "请输入正确数字 [0-4]"; sleep 1; menu01;;
		esac
		}

# IPv4
menu10(){
	status
	green " 1. 为 IPv4 only 添加 IPv6 网络接口 "
	green " 2. 为 IPv4 only 添加双栈网络接口 "
	green " 3. 关闭 WARP 网络接口，并删除 WGCF "
	green " 4. 升级内核、安装BBR、DD脚本 "
	green " 0. 退出脚本 \n "
	read -p "请输入数字:" choose10
		case "$choose10" in
		1 ) 	modify=$modify3;	install;;
		2 ) 	modify=$modify4;	install;;
		3 ) 	uninstall;;
		4 )	bbrInstall;;
		0 ) 	exit 1;;
		* ) 	red "请输入正确数字 [0-4]"; sleep 1; menu10;;
		esac
		}

# IPv4+IPv6
menu11(){ 
	status
	green " 1. 为 原生双栈 添加 WARP双栈 网络接口 "
	green " 2. 关闭 WARP 网络接口，并删除 WGCF "
	green " 3. 升级内核、安装BBR、DD脚本 "
	green " 0. 退出脚本 \n "
	read -p "请输入数字:" choose11
		case "$choose11" in
		1 ) 	modify=$modify5;	install;;
		2 ) 	uninstall;;
		3 )	bbrInstall;;
		0 ) 	exit 1;;
		* ) 	red "请输入正确数字 [0-3]"; sleep 1; menu11;;
		esac
		}

# 已开启 warp 网络接口
menu2(){ 
	status
	green " 1. 关闭 WARP 网络接口，并删除 WGCF "
	green " 2. 升级内核、安装BBR、DD脚本 "
	green " 0. 退出脚本 \n "
	read -p "请输入数字:" choose2
        	case "$choose2" in
		1 ) 	uninstall;;
		2 )	bbrInstall;;
		0 ) 	exit 1;;
		* ) 	red "请输入正确数字 [0-2]"; sleep 1; menu2;;
		esac
		}

menu$plan
