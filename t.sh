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

# 变量 plan 含义：001=KVM+IPv6,	010=KVM+IPv4,	011=KVM+IPv4+IPv6,	101=LXC+IPv6,	110=LXC+IPv4,	111=LXC+IPv4+IPv6,	2=WARP已开启,
if [[ $wgcf == WARP已开启 ]]
	then plan=2 
	else plan=$virtual$ipv4$ipv6
fi

# VPS 当前状态
function status(){
	clear
	green " 本项目专为 VPS 添加 wgcf 网络接口，详细说明：https://github.com/fscarmen/warp "
	green " 当前操作系统：$(hostnamectl | grep -i operat | awk -F ':' '{print $2}')，内核：$(uname -r)， 处理器架构：$architecture， 虚拟化：$(hostnamectl | grep -i virtual | awk -F ': ' '{print $2}') "
	green " IPv4：$(wget -qO- -4 ip.gs)		IPv6：$(wget -qO- -6 ip.gs)		$wgcf $plan "
	red " ====================================================================================================================== " 
		}    

# 一键删除 wgcf
function uninstall(){
        wg-quick down wgcf > /dev/null
        systemctl disable wg-quick@wgcf > /dev/null
        rm -f /usr/local/bin/wgcf /etc/wireguard/wgcf.conf /usr/bin/wireguard-go  wgcf-account.toml  wgcf-profile.conf
        sed -i '/^precedence[ ]*::ffff:0:0\/96[ ]*100/d' /etc/gai.conf
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
		1 ) 	rm -f /usr/local/bin/wgcf /etc/wireguard/wgcf.conf /usr/bin/wireguard-go  wgcf-account.toml  wgcf-profile.conf
			echo -e nameserver 2a00:1098:2b::1 > /etc/resolv.conf
			wget -N -6 --no-check-cert
			icate "https://cdn.jsdelivr.net/gh/fscarmen/warp/warp4.sh" && chmod +x warp4.sh && ./warp4.sh;;
		2 )	rm -f /usr/local/bin/wgcf /etc/wireguard/wgcf.conf /usr/bin/wireguard-go  wgcf-account.toml  wgcf-profile.conf
			echo -e nameserver 2a00:1098:2b::1 > /etc/resolv.conf
			wget -N -6 --no-check-certificate "https://cdn.jsdelivr.net/gh/fscarmen/warp/dualstack46.sh" && chmod +x dualstack46.sh && ./dualstack46.sh;;
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
		1 ) 	rm -f /usr/local/bin/wgcf /etc/wireguard/wgcf.conf /usr/bin/wireguard-go  wgcf-account.toml  wgcf-profile.conf
			wget -N --no-check-certificate "https://cdn.jsdelivr.net/gh/fscarmen/warp/warp6.sh" && chmod +x warp6.sh && ./warp6.sh;;
		2 )	rm -f /usr/local/bin/wgcf /etc/wireguard/wgcf.conf /usr/bin/wireguard-go  wgcf-account.toml  wgcf-profile.conf
			wget -N --no-check-certificate "https://cdn.jsdelivr.net/gh/fscarmen/warp/dualstack6.sh" && chmod +x dualstack6.sh && ./dualstack6.sh;;
		3 ) 	uninstall;;
		0 ) 	exit 1;; 
		* ) 	red "请输入正确数字 [0-3]"
			sleep 1
			menu010;;
		esac
		}

# KVM+IPv4+IPv6
function menu011(){ 
                echo kvm+ipv4+ipv6
	status
	green " 1. 为 原生双栈 添加 WARP双栈 网络接口 "	
	green " 2. 一键删除 wgcf "	
	green " 0. 退出脚本 "
	read -p "请输入数字:" choose011
		case "$choose011" in
		1 )	rm -f /usr/local/bin/wgcf /etc/wireguard/wgcf.conf /usr/bin/wireguard-go  wgcf-account.toml  wgcf-profile.conf
			wget -N --no-check-certificate "https://cdn.jsdelivr.net/gh/fscarmen/warp/dualstack6.sh" && chmod +x dualstack6.sh && ./dualstack6.sh;;
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
		1 ) 	rm -f /usr/local/bin/wgcf /etc/wireguard/wgcf.conf /usr/bin/wireguard-go  wgcf-account.toml  wgcf-profile.conf
			echo -e nameserver 2a00:1098:2b::1 > /etc/resolv.conf
			wget -N -6 --no-check-certificate "https://cdn.jsdelivr.net/gh/fscarmen/warp/warp.sh" && chmod +x warp.sh && ./warp.sh;;
		2 ) 	rm -f /usr/local/bin/wgcf /etc/wireguard/wgcf.conf /usr/bin/wireguard-go  wgcf-account.toml  wgcf-profile.conf
			echo -e nameserver 2a00:1098:2b::1 > /etc/resolv.conf
			wget -N -6 --no-check-certificate "https://cdn.jsdelivr.net/gh/fscarmen/warp/dualstack.sh" && chmod +x dualstack.sh && ./dualstack.sh;;
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
