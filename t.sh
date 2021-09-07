#彩色
red(){
            echo -e "\033[31m\033[01m$1\033[0m"
    }
green(){
            echo -e "\033[32m\033[01m$1\033[0m"
    }
yellow(){
            echo -e "\033[33m\033[01m$1\033[0m"
    }
blue(){
            echo -e "\033[36m\033[01m$1\033[0m"
    }

if [[ $(hostnamectl) =~ .*arm.* ]]
                then architecture=arm64
                                else architecture=amd64
fi

if [[ $(hostnamectl | grep -i virtual | awk -F ': ' '{print $2}') =~ openvz|lxc ]]
                then virtualization=100
                                else virtualization=0
fi

wget -qO- -4 ip.gs > /dev/null
if [ $? -eq 0 ]
                then ipv4=10
                                else ipv4=0
fi

wget -qO- -6 ip.gs > /dev/null
if [ $? -eq 0 ]
                then ipv6=1
                                else ipv6=0
fi

plan=`expr $virtualization + $ipv4 + $ipv6`

clear


function status(){
	clear

	green " 本项目专为 VPS 添加 wgcf 网络接口，详细说明：https://github.com/fscarmen/warp "

	green " 当前操作系统：$(hostnamectl | grep -i operat | awk -F ':' '{print $2}'), 内核：$(uname -r)，处理器架构：$architecture ，虚拟化：$(hostnamectl | grep -i virtual | awk -F ':' '{print $2}') "

	green " IPv4：$(wget -qO- -4 ip.gs),		IPv6：$(wget -qO- -6 ip.gs)"

	red " ====================================================================================================================== " 
		}    

function uninstall(){
        wg-quick down wgcf > /dev/null
        systemctl disable wg-quick@wgcf > /dev/null
        rm -f /usr/local/bin/wgcf /etc/wireguard/wgcf.conf /usr/bin/wireguard-go  wgcf-account.toml  wgcf-profile.conf
        sed -i '/^precedence[ ]*::ffff:0:0\/96[ ]*100/d' /etc/gai.conf
        green " wgcf已彻底删除 "
		}


function menu001(){
	status
	green " 1. 为 IPv6 only 添加 IPv4 网络接口方法 "
	green " 2. 为 IPv6 only 添加双栈网络接口方法 "
	green " 3. 一键删除 wgcf "
	green " 0. 退出脚本 "
	read -p "请输入数字:" choose001
		case "$choose001" in
		1 ) 	rm -f /usr/local/bin/wgcf /etc/wireguard/wgcf.conf /usr/bin/wireguard-go  wgcf-account.toml  wgcf-profile.conf
			echo -e nameserver 2a00:1098:2b::1 > /etc/resolv.conf
			wget -N -6 --no-check-certificate "https://cdn.jsdelivr.net/gh/fscarmen/warp/warp4.sh" && chmod +x warp4.sh && ./warp4.sh;;
		2 )	rm -f /usr/local/bin/wgcf /etc/wireguard/wgcf.conf /usr/bin/wireguard-go  wgcf-account.toml  wgcf-profile.conf
			echo -e nameserver 2a00:1098:2b::1 > /etc/resolv.conf
			wget -N -6 --no-check-certificate "https://cdn.jsdelivr.net/gh/fscarmen/warp/dualstack46.sh" && chmod +x dualstack46.sh && ./dualstack46.sh;;
		3 ) uninstall;;
		0 ) exit 1;; 
		* ) red "请输入正确数字 [0-3]"
			sleep 1
			menu001;;
		esac
		}

function menu010(){
	status
	green " 1. 为 IPv4 only 添加 IPv6 网络接口方法 "
	green " 2. 为 IPv4 only 添加双栈网络接口方法 "
	green " 3. 一键删除 wgcf "
	green " 0. 退出脚本 "
	read -p "请输入数字:" choose010
		case "$choose010" in
		1 ) 	rm -f /usr/local/bin/wgcf /etc/wireguard/wgcf.conf /usr/bin/wireguard-go  wgcf-account.toml  wgcf-profile.conf
			wget -N --no-check-certificate "https://cdn.jsdelivr.net/gh/fscarmen/warp/warp6.sh" && chmod +x warp6.sh && ./warp6.sh;;
		2 )	rm -f /usr/local/bin/wgcf /etc/wireguard/wgcf.conf /usr/bin/wireguard-go  wgcf-account.toml  wgcf-profile.conf
			wget -N --no-check-certificate "https://cdn.jsdelivr.net/gh/fscarmen/warp/dualstack6.sh" && chmod +x dualstack6.sh && ./dualstack6.sh;;
		3 ) uninstall;;
		0 ) exit 1;; 
		* ) red "请输入正确数字 [0-3]"
			sleep 1
			menu010;;
		esac
		}
		
function menu011(){ 
                echo kvm+ipv4+ipv6 
        }

function menu101(){
	status
	green " 1. 为 IPv6 only 添加 IPv4 网络接口方法 "
	green " 2. 为 IPv6 only 添加双栈网络接口方法 "
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
		3 ) uninstall;;
		0 ) exit 1;; 
		* ) red "请输入正确数字 [0-3]"
			sleep 1
			menu101;;
		esac
                }

function menu110(){ 
                echo lxc+ipv4 

        }
function menu111(){ 
                echo lxc+ipv4+ipv6

        }

case "$plan" in
                1 ) menu001;; 10 ) menu010;; 11 ) menu011;; 101 ) menu101;; 110 ) menu110;; 111 ) menu111;;
        esac
