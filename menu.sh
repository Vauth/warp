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

# 判断当前 WARP 状态
if [[ $(ip a) =~ wgcf ]]
	then wgcf=WARP已开启
	else wgcf=WARP未开启
fi

# 判断处理器架构
if [[ $(hostnamectl) =~ .*arm.* ]]
	then architecture=arm64
	else architecture=amd64
fi

# 判断虚拟化，选择 wireguard内核模块 还是 wireguard-go，	1=KVM,		2=openvz或者lxc
if [[ $(hostnamectl | grep -i Virtualization | awk -F ': ' '{print $2}') =~ openvz|lxc ]]
	then virtualization=1
	else virtualization=0
fi

# 判断当前 IPv4 状态
if ping -4 -c1 -W1 114.114.114.114 >/dev/null 2>&1
        then ipv4=1
        else ipv4=0
fi

# 判断当前 IPv6 状态
if ping -6 -c1 -W1 2400:3200::1 >/dev/null 2>&1
        then ipv6=1
        else ipv6=0
fi

# 在KVM的前提下，判断 Linux 版本是否小于 5.6，如是则安装 wireguard 内核模块，变量 wg=1。由于 linux 不能直接用小数作比较，所以用 （主版本号 * 100 + 次版本号 ）与 506 作比较
if  [[ $virtualization -eq 0 && $(($(uname  -r | awk -F . '{print $1 }') * 100 +  $(uname  -r | awk -F . '{print $2 }'))) -lt 506 ]]; then wg=1; fi

# 变量 plan 含义：01=IPv6,	10=IPv4,	11=IPv4+IPv6,	2=WARP已开启
if [[ $wgcf == WARP已开启 ]]
	then plan=2
	else plan=$ipv4$ipv6
fi

# WGCF 配置修改
modify1="sed -i '/\:\:\/0/d' wgcf-profile.conf && sed -i 's/engage.cloudflareclient.com/[2606:4700:d0::a29f:c001]/g' wgcf-profile.conf"
modify2='sed -i "7 s/^/PostUp = ip -6 rule add from $(ip route get 2400:3200::1 | grep -oP '"'src \K\S+') lookup main\n/"'" wgcf-profile.conf && sed -i "8 s/^/PostDown = ip -6 rule delete from $(ip route get 2400:3200::1 | grep -oP '"'src \K\S+') lookup main\n/"'" wgcf-profile.conf && sed -i '"'s/engage.cloudflareclient.com/[2606:4700:d0::a29f:c001]/g' wgcf-profile.conf && sed -i 's/1.1.1.1/1.1.1.1,9.9.9.9,8.8.8.8/g' wgcf-profile.conf"
modify3="sed -i '/0\.\0\/0/d' wgcf-profile.conf && sed -i 's/engage.cloudflareclient.com/162.159.192.1/g' wgcf-profile.conf && sed -i 's/1.1.1.1/9.9.9.9,8.8.8.8,1.1.1.1/g' wgcf-profile.conf"
modify4='sed -i "7 s/^/PostUp = ip -4 rule add from $(ip route get 114.114.114.114 | grep -oP '"'src \K\S+') lookup main\n/"'" wgcf-profile.conf && sed -i "8 s/^/PostDown = ip -4 rule delete from $(ip route get 114.114.114.114 | grep -oP '"'src \K\S+') lookup main\n/"'" wgcf-profile.conf && sed -i '"'s/engage.cloudflareclient.com/162.159.192.1/g' wgcf-profile.conf && sed -i 's/1.1.1.1/9.9.9.9,8.8.8.8,1.1.1.1/g' wgcf-profile.conf"
modify5='sed -i "7 s/^/PostUp = ip -4 rule add from $(ip route get 114.114.114.114 | grep -oP '"'src \K\S+') lookup main\n/"'" wgcf-profile.conf && sed -i "8 s/^/PostDown = ip -4 rule delete from $(ip route get 114.114.114.114 | grep -oP '"'src \K\S+') lookup main\n/"'" wgcf-profile.conf && sed -i "9 s/^/PostUp = ip -6 rule add from $(ip route get 2400:3200::1 | grep -oP '"'src \K\S+') lookup main\n/"'" wgcf-profile.conf && sed -i "10 s/^/PostDown = ip -6 rule delete from $(ip route get 2400:3200::1 | grep -oP '"'src \K\S+') lookup main\n/"'" wgcf-profile.conf && sed -i '"'s/engage.cloudflareclient.com/162.159.192.1/g' wgcf-profile.conf && sed -i 's/1.1.1.1/9.9.9.9,8.8.8.8,1.1.1.1/g' wgcf-profile.conf"

# VPS 当前状态
function status(){
	clear
	yellow " 本项目专为 VPS 添加 wgcf 网络接口，详细说明：https://github.com/fscarmen/warp "
        yellow " 脚本特点: "
        yellow "        * 根据不同系统综合情况显示不同的菜单，避免出错 "
        yellow "        * 结合 Linux 版本和虚拟化方式，自动优选三个 WireGuard 方案。网络性能方面：内核集成 WireGuard＞安装内核模块＞wireguard-go "
        yellow "        * 智能判断 WGCF 作者 github库的最新版本 （Latest release） "
        yellow "        * 智能判断vps操作系统：Ubuntu 18.04、Ubuntu 20.04、Debian 10、Debian 11、CentOS 7、CentOS 8，请务必选择 LTS 系统 "
        yellow "        * 智能判断硬件结构类型：Architecture 为 AMD 或者 ARM "
        yellow "        * 智能分析内网和公网IP生成 WGCF 配置文件 "
        yellow "        * 结束后会有结果提示，并自动清理安装时的临时文件 "
        red "  "
	red " ====================================================================================================================== " 
	green " 本项目专为 VPS 添加 wgcf 网络接口，详细说明：https://github.com/fscarmen/warp "
	green " 当前操作系统：$(hostnamectl | grep -i operating | awk -F ':' '{print $2}')，内核：$(uname -r)， 处理器架构：$architecture， 虚拟化：$(hostnamectl | grep -i virtualization | awk -F ': ' '{print $2}') "
	green " IPv4：$(wget -T1 -t1 -qO- -4 ip.gs)		IPv6：$(wget -T1 -t1 -qO- -6 ip.gs)		$wgcf "
	red " ====================================================================================================================== " 
	red "  "
		}    

# WGCF 安装
function install(){
	startTime_s=`date +%s`
	green " 进度  1/3： 安装系统依赖 "

	# 先删除之前安装，可能导致失败的文件
	rm -f /usr/local/bin/wgcf /etc/wireguard/wgcf.conf /usr/bin/wireguard-go  wgcf-account.toml  wgcf-profile.conf
	
	# 判断系统，安装差异部分，安装依赖
	# Debian 运行以下脚本
	if [[ $(hostnamectl | tr A-Z a-z ) =~ debian ]]; then
	
		# 更新源
		apt -y update

		# 添加 backports 源,之后才能安装 wireguard-tools 
		apt -y install lsb-release
		echo "deb http://deb.debian.org/debian $(lsb_release -sc)-backports main" | tee /etc/apt/sources.list.d/backports.list

		# 再次更新源
		apt -y update

		# 安装一些必要的网络工具包和wireguard-tools (Wire-Guard 配置工具：wg、wg-quick)
		apt -y --no-install-recommends install net-tools iproute2 openresolv dnsutils wireguard-tools

		# 如 Linux 版本低于5.6并且是 kvm，则安装 wireguard 内核模块
		if [[ $wg == 1 ]]; then apt -y --no-install-recommends install linux-headers-$(uname -r);apt -y --no-install-recommends install wireguard-dkms; fi

	# Ubuntu 运行以下脚本
	     elif [[ $(hostnamectl | tr A-Z a-z ) =~ ubuntu ]]; then

		# 更新源
		apt -y update

		# 安装一些必要的网络工具包和 wireguard-tools (Wire-Guard 配置工具：wg、wg-quick)
		apt -y --no-install-recommends install net-tools iproute2 openresolv dnsutils wireguard-tools

	# CentOS 运行以下脚本
	     elif [[ $(hostnamectl | tr A-Z a-z ) =~ centos ]]; then

		# 安装一些必要的网络工具包和wireguard-tools (Wire-Guard 配置工具：wg、wg-quick)
		yum -y install epel-release
		yum -y install net-tools wireguard-tools

		# 如 Linux 版本低于5.6并且是 kvm，则安装 wireguard 内核模块
		if [[ $wg == 1 ]]; then curl -Lo /etc/yum.repos.d/wireguard.repo https://copr.fedorainfracloud.org/coprs/jdoss/wireguard/repo/epel-7/jdoss-wireguard-epel-7.repo
		yum -y install epel-release wireguard-dkms; fi

		# 升级所有包同时也升级软件和系统内核
		yum -y update

		# 添加执行文件环境变量
		if [[ $PATH =~ /usr/local/bin ]]; then export PATH=$PATH; else export PATH=$PATH:/usr/local/bin; fi

	# 如都不符合，提示,删除临时文件并中止脚本
	     else 
		# 提示找不到相应操作系统
		green " 本脚本只支持 Debian、Ubuntu 和 CentOS 系统 "

		# 删除临时目录和文件，退出脚本
		rm -f menu.sh
		exit 0
	fi

	# 安装并认证 WGCF
	green " 进度  2/3： 安装 WGCF "
	# 判断系统架构是 AMD 还是 ARM
	if [[ $(hostnamectl) =~ .*arm.* ]]; then architecture=arm64; else architecture=amd64; fi

	# 判断 wgcf 的最新版本
	latest=$(wget --no-check-certificate -qO- -t1 -T2 "https://api.github.com/repos/ViRb3/wgcf/releases/latest" | grep "tag_name" | head -n 1 | awk -F ":" '{print $2}' | sed 's/\"//g;s/v//g;s/,//g;s/ //g')

	# 安装 wgcf
	wget -N --no-check-certificate -O /usr/local/bin/wgcf https://github.com/ViRb3/wgcf/releases/download/v$latest/wgcf_${latest}_linux_$architecture

	# 添加执行权限
	chmod +x /usr/local/bin/wgcf
	
	# 如是 lXC，安装 wireguard-go
	if [[ $virtualization == 1 ]]; then
 	wget -N --no-check-certificate -P /usr/bin https://cdn.jsdelivr.net/gh/fscarmen/warp/wireguard-go
	chmod +x /usr/bin/wireguard-go
	fi
	
	# 注册 WARP 账户 (将生成 wgcf-account.toml 文件保存账户信息，为避免文件已存在导致出错，先尝试删掉原文件)
	rm -f wgcf-account.toml
	green " WGCF 注册中…… "
	until [[ -a wgcf-account.toml ]]
	  do
	   echo | wgcf register >/dev/null 2>&1
	done

	# 生成 Wire-Guard 配置文件 (wgcf-profile.conf)
	wgcf generate >/dev/null 2>&1

	# 修改配置文件
	echo $modify | sh

	# 把 wgcf-profile.conf 复制到/etc/wireguard/ 并命名为 wgcf.conf
	cp -f wgcf-profile.conf /etc/wireguard/wgcf.conf

	# 自动刷直至成功（ warp bug，有时候获取不了ip地址）
	green " 进度  3/3： 运行 WGCF "
	green " 后台获取 warp IP 中，有时候长达10分钟，请耐心等待。"
	wg-quick up wgcf >/dev/null 2>&1
	until [[ -n $(wget -T1 -t1 -qO- -6 ip.gs) ]]
	  do
	   wg-quick down wgcf >/dev/null 2>&1
	   wg-quick up wgcf >/dev/null 2>&1
	done

	# 设置开机启动
	systemctl enable wg-quick@wgcf >/dev/null 2>&1

	# 优先使用 IPv4 网络
	if [[ -e /etc/gai.conf ]]; then grep -qE '^[ ]*precedence[ ]*::ffff:0:0/96[ ]*100' /etc/gai.conf || echo 'precedence ::ffff:0:0/96  100' | tee -a /etc/gai.conf >/dev/null 2>&1; fi

	# 结果提示
	endTime_s=`date +%s`
	green " 恭喜！WARP已开启，总耗时:$(( $endTime_s - $startTime_s ))秒，IPv4地址为:$(wget -qO- -4 ip.gs)，IPv6地址为:$(wget -qO- -6 ip.gs) "
	
	# 删除临时文件
	rm -f wgcf-account.toml  wgcf-profile.conf menu.sh
		}

# 一键删除 wgcf
function uninstall(){
        wg-quick down wgcf 2>/dev/null
        systemctl disable wg-quick@wgcf 2>/dev/null
	apt -y autoremove wireguard-tools wireguard-dkms 2>/dev/null
	yum -y autoremove wireguard-tools wireguard-dkms 2>/dev/null
        rm -f /usr/local/bin/wgcf /etc/wireguard/wgcf.conf /usr/bin/wireguard-go  wgcf-account.toml  wgcf-profile.conf menu.sh
        if [[ -e /etc/gai.conf ]]; then sed -i '/^precedence[ ]*::ffff:0:0\/96[ ]*100/d' /etc/gai.conf; fi
        green " wgcf已彻底删除 "
		}

# IPv6
function menu01(){
	status
	green " 1. 为 IPv6 only 添加 IPv4 网络接口 "
	green " 2. 为 IPv6 only 添加双栈网络接口 "
	green " 3. 一键删除 wgcf "
	green " 0. 退出脚本 "
	read -p "请输入数字:" choose01
		case "$choose01" in
		1 ) 	modify=$modify1;	install;;
		2 )	modify=$modify2;	install;;
		3 ) 	uninstall;;
		0 ) 	exit 1;;
		* ) 	red "请输入正确数字 [0-3]"; sleep 1; menu01;;
		esac
		}

# IPv4
function menu10(){
	status
	green " 1. 为 IPv4 only 添加 IPv6 网络接口 "
	green " 2. 为 IPv4 only 添加双栈网络接口 "
	green " 3. 一键删除 wgcf "
	green " 0. 退出脚本 "
	read -p "请输入数字:" choose10
		case "$choose10" in
		1 ) 	modify=$modify3;	install;;
		2 ) 	modify=$modify4;	install;;
		3 ) 	uninstall;;
		0 ) 	exit 1;;
		* ) 	red "请输入正确数字 [0-3]"; sleep 1; menu10;;
		esac
		}

# IPv4+IPv6
function menu11(){ 
	status
	green " 1. 为 原生双栈 添加 WARP双栈 网络接口 "
	green " 2. 一键删除 wgcf "
	green " 0. 退出脚本 "
	read -p "请输入数字:" choose11
		case "$choose11" in
		1 ) 	modify=$modify5;	install;;
		2 ) 	uninstall;;
		0 ) 	exit 1;;
		* ) 	red "请输入正确数字 [0-2]"; sleep 1; menu11;;
		esac
		}

# 已开启 warp 网络接口
function menu2(){ 
	status
	green " 已开启 warp 网络接口 "
	green " 1. 一键删除 wgcf "
	green " 0. 退出脚本 "
	read -p "请输入数字:" choose2
        	case "$choose2" in
		1 ) 	uninstall;;
		0 ) 	exit 1;;
		* ) 	red "请输入正确数字 [0-1]"; sleep 1; menu2;;
		esac
		}

case "$plan" in
   01 ) menu01;; 10 ) menu10;; 11 ) menu11;; 2 ) menu2;;
esac
