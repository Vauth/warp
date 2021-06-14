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

function warp6(){
wget -N --no-check-certificate "https://cdn.jsdelivr.net/gh/fscarmen/warp/warp6.sh" && chmod +x warp6.sh && ./warp6.sh
}

function dualstack6(){
wget -N --no-check-certificate "https://cdn.jsdelivr.net/gh/fscarmen/warp/dualstack6.sh" && chmod +x dualstack6.sh && ./dualstack6.sh
}

function warp4(){
wget -N -6 --no-check-certificate "https://cdn.jsdelivr.net/gh/fscarmen/warp/warp4.sh" && chmod +x warp4.sh && ./war4.sh
}

function dualstack46(){
wget -N -6 --no-check-certificate "https://cdn.jsdelivr.net/gh/fscarmen/warp/dualstack46.sh" && chmod +x dualstack46.sh && ./dualstack46.sh
}

function warp(){
wget -N -6 --no-check-certificate "https://cdn.jsdelivr.net/gh/fscarmen/warp/warp.sh" && chmod +x warp.sh && ./warp.sh
}

function dualstack(){
wget -N -6 --no-check-certificate "https://cdn.jsdelivr.net/gh/fscarmen/warp/dualstack.sh" && chmod +x dualstack.sh && ./dualstack.sh
}

#主菜单
function start_menu(){
    clear

    green " 本项目专为甲骨文、谷歌云和EUserv添加 wgcf 网络接口，详细说明：https://github.com/fscarmen/warp "

    green " 当前操作系统：$(hostnamectl | grep -i operat | awk -F ':' '{print $2}'), 内核：$(uname -r)，处理器架构：$(arch) ，虚拟化：$(hostnamectl | grep -i virtual | awk -F ':' '{print $2}')"  
   
    red " ======================================================================================================== " 
    
    green " 1. 为甲骨文、谷歌云等 IPv4 添加 IPv6 网络接口方法 "
    
    green " 2. 为甲骨文、谷歌云等 IPv4 添加双栈网络接口方法 "
    
    green " 3. 为甲骨文等 IPv6 only 添加 IPv4 网络接口方法 "
    
    green " 4. 为甲骨文等 IPv6 only 添加双栈网络接口方法 "
    
    green " 5. 为 EUserv 添加 IPv4 网络接口方法" 
    
    green " 6. 为 EUserv 添加双栈网络接口方法"
    
    green " 0. 退出脚本 "

    read -p "请输入数字:" choose
    case "$choose" in
	1 ) warp6;;

	2 ) dualstack6;;

 	3 ) warp4;;

	4 ) dualstack46;;    

	5 ) warp;;
           
	6 ) dualstack;;
          
	0 ) exit 1;; 
	
	* ) red "请输入正确数字 [0-6]"
		sleep 1
                start_menu;;

    esac
}

start_menu "first"

rm -f menu*
