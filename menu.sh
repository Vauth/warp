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

#主菜单
function start_menu(){
    clear

    green " 本项目专为甲骨文、谷歌云和EUserv添加 wgcf 网络接口，详细说明：https://github.com/fscarmen/warp "

    green " 当前操作系统和内核版本是：$(hostnamectl | grep -i operat | awk -F ':' '{print $2}'), 架构是：$(uname -m) "  
   
    red " ==============================================================================================" 
    
    green " 1. 为甲骨文、谷歌云等 IPv4 添加 IPv6 网络接口方法 "
    
    green " 2. 为甲骨文、谷歌云等 IPv4 添加双栈网络接口方法 "
    
    green " 3. 为甲骨文等 IPv6 only 添加 IPv4 网络接口方法 "
    
    green " 4. 为甲骨文等 IPv6 only 添加双栈网络接口方法 "
    
    green " 5. 为 EUserv 添加 IPv4 网络接口方法" 
    
    green " 6. 为 EUserv 添加双栈网络接口方法"
    
    green " 0. 退出脚本 "

    echo
    read -p "请输入数字:" menuNumberInput
    case "$menuNumberInput" in
        1 )
           file=warp6
	;;
	2 )
           file=dualstack6
	;;
        3 )
           file=warp4
	;;
	4 )
           file=dualstack46
	;;    
        5 )
           file=warp
	;;
        6 )
           file=dualstack
	;;
        0 )
            exit 1
        ;;
    esac
}


start_menu "first"  

wget -N --no-check-certificate "https://raw.githubusercontent.com/fscarmen/warp/main/$file.sh" && chmod +x $file.sh && ./$file.sh

rm -f menu*
