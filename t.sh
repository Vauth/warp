# 退格键处理
$stty erase ^?

# 字体彩色
red(){
            echo -e "\033[31m\033[01m$1\033[0m"
    }
green(){
            echo -e "\033[32m\033[01m$1\033[0m"
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

# 判断虚拟化，选择 wireguard内核模块 还是 wireguard-go
if [[ $(hostnamectl | grep -i virtual | awk -F ': ' '{print $2}') =~ openvz|lxc ]]
	then virtual=1
	else virtual=0
fi
# 判断当前 IPv4 状态
if [[ -z $(wget -qO- -4 ip.gs) ]]
        then ipv4=0
        else ipv4=1
fi

# 判断当前 IPv6 状态
if [[ -z $(wget -qO- -6 ip.gs) ]]
        then ipv6=0
        else ipv6=1
fi

# 变量 plan 含义：001=KVM+IPv6,	010=KVM+IPv4,	011=KVM+IPv4+IPv6,	101=LXC+IPv6,	110=LXC+IPv4,	111=LXC+IPv4+IPv6,	2=WARP已开启
if [[ $wgcf == WARP已开启 ]]
	then plan=2 
	else plan=$virtual$ipv4$ipv6
fi

# 判断系统，安装差异部分，安装依赖
function dependence(){
	green " (1/3) 安装系统依赖和 wireguard 内核模块 "
	
	# 先删除之前安装，可能导致失败的文件
	rm -f /usr/local/bin/wgcf /etc/wireguard/wgcf.conf /usr/bin/wireguard-go  wgcf-account.toml  wgcf-profile.conf
	
	# Debian 运行以下脚本
	if grep -q -E -i "debian" /etc/issue; then
	
		# 更新源
		apt -y update

		# 添加 backports 源,之后才能安装 wireguard-tools 
		apt -y install lsb-release
		echo "deb http://deb.debian.org/debian $(lsb_release -sc)-backports main" | tee /etc/apt/sources.list.d/backports.list

		# 再次更新源
		apt -y update

		# 安装一些必要的网络工具包和wireguard-tools (Wire-Guard 配置工具：wg、wg-quick)
		apt -y --no-install-recommends install net-tools iproute2 openresolv dnsutils wireguard-tools
		
		# 如是kvm，则安装 wireguard 内核模块
		if [[ $virtual == 0 ]]; then apt -y --no-install-recommends install linux-headers-$(uname -r);apt -y --no-install-recommends install wireguard-dkms; fi

	
	# Ubuntu 运行以下脚本
	     elif grep -q -E -i "ubuntu" /etc/issue; then

		# 更新源
		apt -y update

		# 安装一些必要的网络工具包和 wireguard-tools (Wire-Guard 配置工具：wg、wg-quick)
		apt -y --no-install-recommends install net-tools iproute2 openresolv dnsutils wireguard-tools

	# CentOS 运行以下脚本
	     elif grep -q -E -i "kernel" /etc/issue; then

		# 安装一些必要的网络工具包和wireguard-tools (Wire-Guard 配置工具：wg、wg-quick)
		yum -y install epel-release
		yum -y install net-tools wireguard-tools

		# 如是kvm，安装 wireguard 内核模块
		if [[ $virtual == 0 ]]; then curl -Lo /etc/yum.repos.d/wireguard.repo https://copr.fedorainfracloud.org/coprs/jdoss/wireguard/repo/epel-7/jdoss-wireguard-epel-7.repo; yum -y install epel-release wireguard-dkms; fi

		# 升级所有包同时也升级软件和系统内核
		yum -y update

		# 添加执行文件环境变量
		if [[ $PATH =~ /usr/local/sbin ]]; then export PATH=$PATH; else export PATH=$PATH:/usr/local/bin; fi

	# 如都不符合，提示,删除临时文件并中止脚本
	     else 
		# 提示找不到相应操作系统
		green " 抱歉，我不认识此系统！ "

		# 删除临时目录和文件，退出脚本
		rm -f menu.sh
		exit 0
	fi
		}

# 安装并认证 WGCF
function register(){
	green " (2/3) 安装 WGCF "
	# 判断系统架构是 AMD 还是 ARM
	if [[ $(hostnamectl) =~ .*arm.* ]]; then architecture=arm64; else architecture=amd64; fi

	# 判断 wgcf 的最新版本
	latest=$(wget -qO- -t1 -T2 "https://api.github.com/repos/ViRb3/wgcf/releases/latest" | grep "tag_name" | head -n 1 | awk -F ":" '{print $2}' | sed 's/\"//g;s/v//g;s/,//g;s/ //g')

	# 安装 wgcf
	wget -N -O /usr/local/bin/wgcf https://github.com/ViRb3/wgcf/releases/download/v$latest/wgcf_${latest}_linux_$architecture

	# 添加执行权限
	chmod +x /usr/local/bin/wgcf
	
	# 如是 lXC，安装 wireguard-go
	if [[ $virtual == 1 ]]; then
 	wget -N -P /usr/bin https://cdn.jsdelivr.net/gh/fscarmen/warp/wireguard-go
	chmod +x /usr/bin/wireguard-go
	fi
	
	# 注册 WARP 账户 (将生成 wgcf-account.toml 文件保存账户信息，为避免文件已存在导致出错，先尝试删掉原文件)
	rm -f wgcf-account.toml
	green " wgcf 注册中…… "
	until [[ -a wgcf-account.toml ]]
	  do
	   echo | wgcf register >/dev/null 2>&1
	done

	# 生成 Wire-Guard 配置文件 (wgcf-profile.conf)
	wgcf generate >/dev/null 2>&1
		}

# 运行 warp
function run(){
	# 把 wgcf-profile.conf 复制到/etc/wireguard/ 并命名为 wgcf.conf
	cp wgcf-profile.conf /etc/wireguard/wgcf.conf

	# 自动刷直至成功（ warp bug，有时候获取不了ip地址）
	green " (3/3) 运行 WGCF "
	green " 后台获取 warp IP 中，有时候需10分钟，请耐心等待。"
	wg-quick up wgcf >/dev/null 2>&1
	until [[ -n $(wget -qO- -6 ip.gs) ]]
	  do
	   wg-quick down wgcf >/dev/null 2>&1
	   wg-quick up wgcf >/dev/null 2>&1
	done

	# 设置开机启动
	systemctl enable wg-quick@wgcf >/dev/null 2>&1

	# 优先使用 IPv4 网络
	if [[ -e /etc/gai.conf ]]; then grep -qE '^[ ]*precedence[ ]*::ffff:0:0/96[ ]*100' /etc/gai.conf || echo 'precedence ::ffff:0:0/96  100' | tee -a /etc/gai.conf >/dev/null 2>&1; fi

	# 结果提示
	green " 恭喜！WARP已开启，IPv4地址为:$(wget -qO- -4 ip.gs)，IPv6地址为:$(wget -qO- -6 ip.gs) "
	
	# 删除临时文件
	rm -f menu.sh
		}

# VPS 当前状态
function status(){
	clear
	green " 本项目专为 VPS 添加 wgcf 网络接口，详细说明：https://github.com/fscarmen/warp "
	green " 当前操作系统：$(hostnamectl | grep -i operat | awk -F ':' '{print $2}')，内核：$(uname -r)， 处理器架构：$architecture， 虚拟化：$(hostnamectl | grep -i virtual | awk -F ': ' '{print $2}') "
	green " IPv4：$(wget -qO- -4 ip.gs)		IPv6：$(wget -qO- -6 ip.gs)		$wgcf "
	red " ====================================================================================================================== " 
		}    

# 一键删除 wgcf
function uninstall(){
        wg-quick down wgcf > /dev/null
#	systemctl stop wg-quick@wgcf > /dev/null
        systemctl disable wg-quick@wgcf > /dev/null
	apt -y autoremove net-tools wireguard-tools wireguard-dkms 2>/dev/null
	yum -y autoremove net-tools wireguard-tools wireguard-dkms 2>/dev/null
        rm -f /usr/local/bin/wgcf /etc/wireguard/wgcf.conf /usr/bin/wireguard-go  wgcf-account.toml  wgcf-profile.conf
        if [[ -e /etc/gai.conf ]]; then sed -i '/^precedence[ ]*::ffff:0:0\/96[ ]*100/d' /etc/gai.conf; fi
        green " wgcf已彻底删除 "
		}

# KVM+IPv6
function menu001(){
	status
	green " 1. 为 IPv6 only 添加 IPv4 网络接口 "	
	green " 2. 为 IPv6 only 添加双栈网络接口 "	
	green " 3. 一键删除 wgcf "	
	green " 0. 退出脚本 "
	read -p "请输入数字:" choose001
		case "$choose001" in
		1 ) 	dependence
			register
			sed -i '/\:\:\/0/d' wgcf-profile.conf && sed -i 's/engage.cloudflareclient.com/[2606:4700:d0::a29f:c001]/g' wgcf-profile.conf
			run;;
		2 )	dependence
			register
			sed -i "7 s/^/PostUp = ip -6 rule add from $(ip route get 2400:3200::1 | grep -oP 'src \K\S+') lookup main\n/" wgcf-profile.conf && sed -i "8 s/^/PostDown = ip -6 rule delete from $(ip route get 2400:3200::1 | grep -oP 'src \K\S+') lookup main\n/" wgcf-profile.conf && sed -i 's/engage.cloudflareclient.com/[2606:4700:d0::a29f:c001]/g' wgcf-profile.conf && sed -i 's/1.1.1.1/1.1.1.1,9.9.9.9,8.8.8.8/g' wgcf-profile.conf
			run;;
		3 ) 	uninstall;;
		0 ) 	exit 1;; 
		* ) 	red "请输入正确数字 [0-3]"
			sleep 1
			menu001;;
		esac
		}

# KVM+IPv4
function menu010(){
	status
	green " 1. 为 IPv4 only 添加 IPv6 网络接口 "	
	green " 2. 为 IPv4 only 添加双栈网络接口 "	
	green " 3. 一键删除 wgcf "	
	green " 0. 退出脚本 "
	read -p "请输入数字:" choose010
		case "$choose010" in
		1 ) 	dependence
			register
			sed -i '/0\.\0\/0/d' wgcf-profile.conf | sed -i 's/engage.cloudflareclient.com/162.159.192.1/g' wgcf-profile.conf |sed -i 's/1.1.1.1/9.9.9.9,8.8.8.8,1.1.1.1/g' wgcf-profile.conf 
			run;;
		2 )	dependence
			register
			sed -i "7 s/^/PostUp = ip -4 rule add from $(ip route get 114.114.114.114 | grep -oP 'src \K\S+') lookup main\n/" wgcf-profile.conf && sed -i "8 s/^/PostDown = ip -4 rule delete from $(ip route get 114.114.114.114 | grep -oP 'src \K\S+') lookup main\n/" wgcf-profile.conf && sed -i 's/engage.cloudflareclient.com/162.159.192.1/g' wgcf-profile.conf && sed -i 's/1.1.1.1/9.9.9.9,8.8.8.8,1.1.1.1/g' wgcf-profile.conf
			run;;
		3 ) 	uninstall;;
		0 ) 	exit 1;; 
		* ) 	red "请输入正确数字 [0-3]"
			sleep 1
			menu010;;
		esac
		}

# KVM+IPv4+IPv6
function menu011(){ 
	status
	green " 1. 为 原生双栈 添加 WARP双栈 网络接口 "	
	green " 2. 一键删除 wgcf "	
	green " 0. 退出脚本 "
	read -p "请输入数字:" choose011
		case "$choose011" in
		1 ) 	dependence
			register
			sed -i "7 s/^/PostUp = ip -4 rule add from $(ip route get 114.114.114.114 | grep -oP 'src \K\S+') lookup main\n/" wgcf-profile.conf && sed -i "8 s/^/PostDown = ip -4 rule delete from $(ip route get 114.114.114.114 | grep -oP 'src \K\S+') lookup main\n/" wgcf-profile.conf && sed -i "9 s/^/PostUp = ip -6 rule add from $(ip route get 2400:3200::1 | grep -oP 'src \K\S+') lookup main\n/" wgcf-profile.conf && sed -i "10 s/^/PostDown = ip -6 rule delete from $(ip route get 2400:3200::1 | grep -oP 'src \K\S+') lookup main\n/" wgcf-profile.conf && sed -i 's/engage.cloudflareclient.com/162.159.192.1/g' wgcf-profile.conf && sed -i 's/1.1.1.1/9.9.9.9,8.8.8.8,1.1.1.1/g' wgcf-profile.conf
			run;;
		2 ) 	uninstall;;
		0 ) 	exit 1;; 
		* ) 	red "请输入正确数字 [0-2]"
			sleep 1
			menu011;;
		esac
		}

# LXC+IPv6
function menu101(){
	status
	green " 1. 为 IPv6 only 添加 IPv4 网络接口 "	
	green " 2. 为 IPv6 only 添加双栈网络接口 "	
	green " 3. 一键删除 wgcf "	
	green " 0. 退出脚本 "
	read -p "请输入数字:" choose101
        	case "$choose101" in
		1 ) 	echo -e nameserver 2a00:1098:2b::1 > /etc/resolv.conf
			dependence
			register
			sed -i '/\:\:\/0/d' wgcf-profile.conf | sed -i 's/engage.cloudflareclient.com/[2606:4700:d0::a29f:c001]/g' wgcf-profile.conf
			run;;
		2 ) 	echo -e nameserver 2a00:1098:2b::1 > /etc/resolv.conf
			dependence
			register
			sed -i "7 s/^/PostUp = ip -6 rule add from $(ip route get 2400:3200::1 | grep -oP 'src \K\S+') lookup main\n/" wgcf-profile.conf && sed -i "8 s/^/PostDown = ip -6 rule delete from $(ip route get 2400:3200::1 | grep -oP 'src \K\S+') lookup main\n/" wgcf-profile.conf && sed -i 's/engage.cloudflareclient.com/[2606:4700:d0::a29f:c001]/g' wgcf-profile.conf
			run;;
		3 ) 	uninstall;;
		0 ) 	exit 1;; 
		* ) 	red "请输入正确数字 [0-3]"
			sleep 1
			menu101;;
		esac
                }

# LXC+IPv4
function menu110(){
	status
	green " 暂时没有遇到该类型系统测试，如有请提 issue : https://github.com/fscarmen/warp/issues "	
	green " 1. 一键删除 wgcf "	
	green " 0. 退出脚本 "
	read -p "请输入数字:" choose110
        	case "$choose110" in
		1 ) 	uninstall;;
		0 ) 	exit 1;; 
		* ) 	red "请输入正确数字 [0-1]"
			sleep 1
			menu110;;
		esac
        	}

# LXC+IPv4+IPv6
function menu111(){ 
	status
	green " 暂时没有遇到该类型系统测试，如有请提 issue : https://github.com/fscarmen/warp/issues "	
	green " 1. 一键删除 wgcf "	
	green " 0. 退出脚本 "
	read -p "请输入数字:" choose111
        	case "$choose111" in
		1 ) 	uninstall;;
		0 ) 	exit 1;; 
		* ) 	red "请输入正确数字 [0-1]"
			sleep 1
			menu111;;
		esac
		}
		
# 已开启 warp 网络接口
function menu2(){ 
	status
	green " 已开启 warp 网络接口 "	
	green " 1. 一键删除 wgcf "	
	green " 0. 退出脚本 "
	read -p "请输入数字:" choose111
        	case "$choose111" in
		1 ) 	uninstall;;
		0 ) 	exit 1;; 
		* ) 	red "请输入正确数字 [0-1]"
			sleep 1
			menu111;;
		esac
		}		

case "$plan" in
   001 ) menu001;; 010 ) menu010;; 011 ) menu011;; 101 ) menu101;; 110 ) menu110;; 111 ) menu111;; 2 ) menu2;;
esac
