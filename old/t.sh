#!/bin/bash
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/root/bin:/sbin:/bin
export LANG=en_US.UTF-8

# 当前脚本版本号和新增功能
VERSION=2.25

# 自定义字体彩色，read 函数，友道翻译函数
red(){ echo -e "\033[31m\033[01m$1\033[0m"; }
green(){ echo -e "\033[32m\033[01m$1\033[0m"; }
yellow(){ echo -e "\033[33m\033[01m$1\033[0m"; }
reading(){ read -rp "$(green "$1")" "$2"; }
translate(){ [[ -n "$1" ]] && curl -sm8 "http://fanyi.youdao.com/translate?&doctype=json&type=AUTO&i=$1" | cut -d \" -f18 2>/dev/null; }

# 传参选项 OPTION：1=为 IPv4 或者 IPv6 补全另一栈WARP; 2=安装双栈 WARP; u=卸载 WARP; b=升级内核、开启BBR及DD; o=WARP开关；p=刷 WARP+ 流量; 其他或空值=菜单界面
[[ $1 != '[option]' ]] && OPTION=$(tr '[:upper:]' '[:lower:]' <<< "$1")
# 参数选项 URL 或 License
if [[ $2 != '[lisence]' ]]; then
	if [[ $2 =~ 'http' ]]; then
	LICENSETYPE=2 && URL=$2
	elif [[ $2 =~ ^[A-Z0-9a-z]{8}-[A-Z0-9a-z]{8}-[A-Z0-9a-z]{8}$ ]]; then
	LICENSETYPE=1 && LICENSE=$2
	fi
fi

# 自定义 WARP+ 设备名
NAME=$3

declare -A T

T[E0]="\n Language:\n  1.English (default) \n  2.简体中文\n"
T[C0]="${T[E0]}"
T[E1]="1.Important: First publication on a global scale. Support architecture s390x for IBM Linux One(Choose WARP ipv6 single stack) 2.support Alpine Linux 3.support Debian bookworm"
T[C1]="1.重要:全网首发，支持IBM Linux One 的 s390x 架构 CPU (请选用 WARP ipv6单栈) 2.支持 Alpine Linux 系统 3.支持 Debian bookworm"
T[E2]="The script must be run as root, you can enter sudo -i and then download and run again. Feedback: [https://github.com/fscarmen/warp/issues]"
T[C2]="必须以root方式运行脚本，可以输入 sudo -i 后重新下载运行，问题反馈:[https://github.com/fscarmen/warp/issues]"
T[E3]="The TUN module is not loaded. You should turn it on in the control panel. Ask the supplier for more help. Feedback: [https://github.com/fscarmen/warp/issues]"
T[C3]="没有加载 TUN 模块，请在管理后台开启或联系供应商了解如何开启，问题反馈:[https://github.com/fscarmen/warp/issues]"
T[E4]="The WARP server cannot be connected. It may be a China Mainland VPS. You can manually ping 162.159.192.1 or ping6 2606:4700:d0::a29f:c001.You can run the script again if the connect is successful. Feedback: [https://github.com/fscarmen/warp/issues]"
T[C4]="与 WARP 的服务器不能连接,可能是大陆 VPS，可手动 ping 162.159.192.1 或 ping6 2606:4700:d0::a29f:c001，如能连通可再次运行脚本，问题反馈:[https://github.com/fscarmen/warp/issues]"
T[E5]="The script supports Debian, Ubuntu, CentOS or Alpine systems only. Feedback: [https://github.com/fscarmen/warp/issues]"
T[C5]="本脚本只支持 Debian、Ubuntu、CentOS 或 Alpine 系统,问题反馈:[https://github.com/fscarmen/warp/issues]"
T[E6]="warp h (help)\n warp o (Turn off WARP temporarily)\n warp u (Turn off and uninstall WARP interface and Socks5 Linux Client)\n warp b (Upgrade kernel, turn on BBR, change Linux system)\n warp d (Upgrade to WARP+ account)\n warp d N5670ljg-sS9jD334-6o6g4M9F (Upgrade to WARP+ account with the license)\n warp d http://gist.github.com/teams.xml (Upgrade to Teams account with the URL)\n warp p (Getting WARP+ quota by scripts)\n warp v (Sync the latest version)\n warp r (Connect/Disconnect WARP Linux Client)\n warp 1 (Add WARP IPv6 interface to native IPv4 VPS or WARP IPv4 interface to native IPv6 VPS)\n warp 1 N5670ljg-sS9jD334-6o6g4M9F Goodluck (Add IPv4 or IPV6 WARP+ interface with the license and named Goodluck)\n warp 2 (Add WARP dualstack interface IPv4 + IPv6)\n warp 2 N5670ljg-sS9jD334-6o6g4M9F Goodluck (Add WARP+ dualstack interface with the license and named Goodluck)\n warp c (Install WARP Linux Client)\n warp c N5670ljg-sS9jD334-6o6g4M9F(Install WARP+ Linux Client with the license)\n warp i (Change the WARP IP to support Netflix)"
T[C6]="warp h (帮助菜单）\n warp o (临时warp开关)\n warp u (卸载 WARP 网络接口和 Socks5 Client)\n warp b (升级内核、开启BBR及DD)\n warp d (免费 WARP 账户升级 WARP+)\n warp d N5670ljg-sS9jD334-6o6g4M9F (指定 License 升级 WARP+)\n warp d http://gist.github.com/teams.xml (指定 URL 升级 Teams)\n warp p (刷WARP+流量)\n warp v (同步脚本至最新版本)\n warp r (WARP Linux Client 开关)\n warp 1 (Warp单栈)\n warp 1 N5670ljg-sS9jD334-6o6g4M9F Goodluck (指定 WARP+ License Warp 单栈，设备名为 Goodluck)\n warp 2 (WARP 双栈)\n warp 2 N5670ljg-sS9jD334-6o6g4M9F Goodluck (指定 WARP+ License 双栈，设备名为 Goodluck)\n warp c (安装 WARP Linux Client，开启 Socks5 代理模式)\n warp c N5670ljg-sS9jD334-6o6g4M9F (指定 Warp+ License 安装 WARP Linux Client，开启 Socks5 代理模式)\n warp i (更换支持 Netflix 的IP)"
T[E7]="Installing curl..."
T[C7]="安装curl中……"
T[E8]="It is necessary to upgrade the latest package library before install curl.It will take a little time,please be patiently..."
T[C8]="先升级软件库才能继续安装 curl，时间较长，请耐心等待……"
T[E9]="Failed to install curl. The script is aborted. Feedback: [https://github.com/fscarmen/warp/issues]"
T[C9]="安装 curl 失败，脚本中止，问题反馈:[https://github.com/fscarmen/warp/issues]"
T[E10]="WireGuard tools are not installed or the configuration file wgcf.conf cannot be found, please reinstall."
T[C10]="没有安装 WireGuard tools 或者找不到配置文件 wgcf.conf，请重新安装。"
T[E11]="Maximum \$j attempts to get WARP IP..."
T[C11]="后台获取 WARP IP 中,最大尝试\$j次……"
T[E12]="Try \$i"
T[C12]="第\$i次尝试"
T[E13]="There have been more than \$j failures. The script is aborted. Feedback: [https://github.com/fscarmen/warp/issues]"
T[C13]="失败已超过\$j次，脚本中止，问题反馈:[https://github.com/fscarmen/warp/issues]"
T[E14]="Got the WARP IP successfully."
T[C14]="已成功获取 WARP 网络"
T[E15]="WARP is turned off. It could be turned on again by [warp o]"
T[C15]="已暂停 WARP，再次开启可以用 warp o"
T[E16]="The script specifically adds WARP network interface for VPS, detailed:[https://github.com/fscarmen/warp]\n Features:\n	* Support WARP+ account. Third-party scripts are use to increase WARP+ quota or upgrade kernel.\n	* Not only menus, but commands with option.\n	* Intelligent analysis of operating system：Ubuntu 18.04、20.04，Debian 10、11，CentOS 7、8, Alpine 3. Be sure to choose the LTS system. And architecture：AMD or ARM\n	* Automatically select four WireGuard solutions. Performance: Kernel with WireGuard integration＞Install kernel module＞wireguard-go\n	* Intelligent analysis of the latest version of the WGCF\n	* Suppert WARP Linux client.\n	* Output WARP status, IP region and asn\n"
T[C16]="本项目专为 VPS 添加 wgcf 网络接口，详细说明：[https://github.com/fscarmen/warp]\n脚本特点:\n	* 支持 WARP+ 账户，附带第三方刷 WARP+ 流量和升级内核 BBR 脚本\n	* 普通用户友好的菜单，进阶者通过后缀选项快速搭建\n	* 智能判断操作系统：Ubuntu 、Debian 、CentOS 和 Alpine，请务必选择 LTS 系统；硬件结构类型：AMD 或者 ARM\n	* 结合 Linux 版本和虚拟化方式，自动优选4个 WireGuard 方案。网络性能方面：内核集成 WireGuard＞安装内核模块＞wireguard-go\n	* 智能判断 WGCF 作者 github库的最新版本 （Latest release）\n	* 支持 WARP Linux Socks5 Client\n	* 输出执行结果，提示是否使用 WARP IP ，IP 归属地和线路提供商\n"
T[E17]="Version"
T[C17]="脚本版本"
T[E18]="New features"
T[C18]="功能新增"
T[E19]="System infomation"
T[C19]="系统信息"
T[E20]="Operating System"
T[C20]="当前操作系统"
T[E21]="Kernel"
T[C21]="内核"
T[E22]="Architecture"
T[C22]="处理器架构"
T[E23]="Virtualization"
T[C23]="虚拟化"
T[E24]="Socks5 Client is on"
T[C24]="Socks5 Client 已开启"
T[E25]="Device name"
T[C25]="设备名"
T[E26]="Curren operating system is \$SYS.\\\n The system lower than \$SYSTEM \${MAJOR[int]} is not supported. Feedback: [https://github.com/fscarmen/warp/issues]"
T[C26]="当前操作是 \$SYS\\\n 不支持 \$SYSTEM \${MAJOR[int]} 以下系统,问题反馈:[https://github.com/fscarmen/warp/issues]"
T[E27]="Local Socks5:\$PROXYSOCKS5	WARP\$AC IPv4:\$PROXYIP \$PROXYCOUNTRY	\$PROXYASNORG"
T[C27]="本地 Socks5:\$PROXYSOCKS5	WARP\$AC IPv4:\$PROXYIP \$PROXYCOUNTRY	\$PROXYASNORG"
T[E28]="If there is a WARP+ License, please enter it, otherwise press Enter to continue:"
T[C28]="如有 WARP+ License 请输入，没有可回车继续:"
T[E29]="Input errors up to 5 times.The script is aborted."
T[C29]="输入错误达5次，脚本退出"
T[E30]="License should be 26 characters, please re-enter WARP+ License. Otherwise press Enter to continue. \(\$i times remaining\):"
T[C30]="License 应为26位字符，请重新输入 Warp+ License，没有可回车继续\(剩余\$i次\):"
T[E31]="\n 1.Update with WARP+ license\n 2.Update with Teams (You need upload the Teams file to a private storage space before. For example: gist.github.com)\n"
T[C31]="\n 1.使用 WARP+ license 升级\n 2.使用 Teams 升级 (你须事前把 Teams 文件上传到私密存储空间，比如：gist.github.com )\n"
T[E32]="Step 1/3: Install dependencies..."
T[C32]="进度 1/3：安装系统依赖……"
T[E33]="Step 2/3: WGCF is ready"
T[C33]="进度 2/3：已安装 WGCF"
T[E34]="This system is a native dualstack. You can only choose the WARP dualstack. Same options as 1"
T[C34]="此系统为原生双栈，只能选择 Warp 双栈方案，选项与 1 相同"
T[E35]="Update WARP+ account..."
T[C35]="升级 WARP+ 账户中……"
T[E36]="The upgrade failed, WARP+ account error or more than 5 devices have been activated. Free WARP account to continu."
T[C36]="升级失败，WARP+ 账户错误或者已激活超过5台设备，自动更换免费 WARP 账户继续"
T[E37]="Checking VPS infomation..."
T[C37]="检查环境中……"
T[E38]="Create shortcut [warp] successfully"
T[C38]="创建快捷 warp 指令成功"
T[E39]="Running WARP"
T[C39]="运行 WARP"
T[E40]="\$COMPANY vps needs to restart and run [warp n] to open WARP."
T[C40]="\$COMPANY vps 需要重启后运行 warp n 才能打开 WARP,现执行重启"
T[E41]="Congratulations! WARP\$TYPE is turned on. Spend time:\$(( end - start )) seconds.\\\n The script runs today: \$TODAY. Total:\$TOTAL"
T[C41]="恭喜！WARP\$TYPE 已开启，总耗时:\$(( end - start ))秒， 脚本当天运行次数:\$TODAY，累计运行次数：\$TOTAL"
T[E42]="Congratulations! WARP is turned on. Spend time:\$(( end - start )) seconds.\\\n The script runs on today: \$TODAY. Total:\$TOTAL"
T[C42]="恭喜！WARP 已开启，总耗时:\$(( end - start ))秒， 脚本当天运行次数:\$TODAY，累计运行次数：\$TOTAL"
T[E43]="Run again with warp [option] [lisence], such as"
T[C43]="再次运行用 warp [option] [lisence]，如"
T[E44]="WARP installation failed. Feedback: [https://github.com/fscarmen/warp/issues]"
T[C44]="WARP 安装失败，问题反馈:[https://github.com/fscarmen/warp/issues]"
T[E45]="WARP interface and Linux Client have been completely deleted!"
T[C45]="WARP 网络接口和 Linux Client 已彻底删除!"
T[E46]="Not cleaned up, please reboot and try again."
T[C46]="没有清除干净，请重启(reboot)后尝试再次删除"
T[E47]="Upgrade kernel, turn on BBR, change Linux system by other authors [ylx2016],[https://github.com/ylx2016/Linux-NetSpeed]"
T[C47]="BBR、DD脚本用的[ylx2016]的成熟作品，地址[https://github.com/ylx2016/Linux-NetSpeed]，请熟知"
T[E48]="Run script"
T[C48]="安装脚本【推荐原版BBR+FQ】"
T[E49]="Return to main menu"
T[C49]="回退主目录"
T[E50]="Choose:"
T[C50]="请选择:"
T[E51]="Please enter the correct number"
T[C51]="请输入正确数字"
T[E52]="Please input WARP+ ID:"
T[C52]="请输入 WARP+ ID:"
T[E53]="WARP+ ID should be 36 characters, please re-enter \(\$i times remaining\):"
T[C53]="WARP+ ID 应为36位字符，请重新输入 \(剩余\$i次\):"
T[E54]="Getting the WARP+ quota by the following 2 authors:\n	* [ALIILAPRO]，[https://github.com/ALIILAPRO/warp-plus-cloudflare]\n	* [mixool]，[https://github.com/mixool/across/tree/master/wireguard]\n	* [SoftCreatR]，[https://github.com/SoftCreatR/warp-up]\n * Open the 1.1.1.1 app\n * Click on the hamburger menu button on the top-right corner\n * Navigate to: Account > Key\n Important：Refresh WARP+ quota： 三 --> Advanced --> Connection options --> Reset keys\n It is best to run script with screen."
T[C54]="刷 WARP+ 流量用可选择以下两位作者的成熟作品，请熟知:\n	* [ALIILAPRO]，地址[https://github.com/ALIILAPRO/warp-plus-cloudflare]\n	* [mixool]，地址[https://github.com/mixool/across/tree/master/wireguard]\n	* [SoftCreatR]，地址[https://github.com/SoftCreatR/warp-up]\n 下载地址：https://1.1.1.1/，访问和苹果外区 ID 自理\n 获取 WARP+ ID 填到下面。方法：App右上角菜单 三 --> 高级 --> 诊断 --> ID\n 重要：刷脚本后流量没有增加处理：右上角菜单 三 --> 高级 --> 连接选项 --> 重置加密密钥\n 最好配合 screen 在后台运行任务"
T[E55]="1.Run [ALIILAPRO] script\n 2.Run [mixool] script\n 3.Run [SoftCreatR] script"
T[C55]="1.运行 [ALIILAPRO] 脚本\n 2.运行 [mixool] 脚本\n 3.运行 [SoftCreatR] 脚本"
T[E56]=""
T[C56]=""
T[E57]="The target quota you want to get. The unit is GB, the default value is 10:"
T[C57]="你希望获取的目标流量值，单位为 GB，输入数字即可，默认值为10:"
T[E58]="WARP+ or Teams account is working now. No need to upgrade."
T[C58]="已经是 WARP+ 或者 Teams 账户，不需要升级"
T[E59]="Cannot find the account file: /etc/wireguard/wgcf-account.toml, you can reinstall with the WARP+ License"
T[C59]="找不到账户文件：/etc/wireguard/wgcf-account.toml，可以卸载后重装，输入 WARP+ License"
T[E60]="Cannot find the configuration file: /etc/wireguard/wgcf.conf, you can reinstall with the WARP+ License"
T[C60]="找不到配置文件： /etc/wireguard/wgcf.conf，可以卸载后重装，输入 WARP+ License"
T[E61]="Please Input WARP+ license:"
T[C61]="请输入WARP+ License:"
T[E62]="Successfully upgraded to a WARP+ account"
T[C62]="已升级为 WARP+ 账户"
T[E63]="WARP+ quota"
T[C63]="剩余流量"
T[E64]="Successfully synchronized the latest version"
T[C64]="成功！已同步最新脚本，版本号"
T[E65]="Upgrade failed. Feedback:[https://github.com/fscarmen/warp/issues]"
T[C65]="升级失败，问题反馈:[https://github.com/fscarmen/warp/issues]"
T[E66]="Add WARP IPv4 interface to IPv6 only VPS"
T[C66]="为 IPv6 only 添加 IPv4 网络接口"
T[E67]="Add WARP IPv6 interface to IPv4 only VPS"
T[C67]="为 IPv4 only 添加 IPv6 网络接口"
T[E68]="Add WARP dualstack interface to IPv6 only VPS"
T[C68]="为 IPv6 only 添加双栈网络接口"
T[E69]="Add WARP dualstack interface to IPv4 only VPS"
T[C69]="为 IPv4 only 添加双栈网络接口"
T[E70]="Add WARP dualstack interface to native dualstack"
T[C70]="为 原生双栈 添加 WARP 双栈 网络接口"
T[E71]="Turn on WARP"
T[C71]="打开 WARP"
T[E72]="Turn off, uninstall WARP interface and Linux Client"
T[C72]="永久关闭 WARP 网络接口，并删除 WARP 和 Linux Client"
T[E73]="Upgrade kernel, turn on BBR, change Linux system"
T[C73]="升级内核、安装BBR、DD脚本"
T[E74]="Getting WARP+ quota by scripts"
T[C74]="刷 WARP+ 流量"
T[E75]="Sync the latest version"
T[C75]="同步最新版本"
T[E76]="Exit"
T[C76]="退出脚本"
T[E77]="Turn off WARP"
T[C77]="暂时关闭 WARP"
T[E78]="Upgrade to WARP+ or Teams account"
T[C78]="升级为 WARP+ 或 Teams 账户"
T[E79]="This system is a native dualstack. You can only choose the WARP dualstack, please enter [y] to continue, and other keys to exit:"
T[C79]="此系统为原生双栈，只能选择 Warp 双栈方案，继续请输入 y，其他按键退出:"
T[E80]="The WARP is working. It will be closed, please run the previous command to install or enter !!"
T[C80]="检测 WARP 已开启，自动关闭后运行上一条命令安装或者输入 !!"
T[E81]="Step 3/3: Searching for the best MTU value is ready."
T[C81]="进度 3/3：寻找 MTU 最优值已完成"
T[E82]="Install WARP Client for Linux and Proxy Mode"
T[C82]="安装 WARP 的 Linux Client 和代理模式"
T[E83]="Step 1/2: Installing WARP Client..."
T[C83]="进度 1/2： 安装 Client……"
T[E84]="Step 2/2: Setting to Proxy Mode"
T[C84]="进度 2/2： 设置代理模式"
T[E85]="Client was installed. You can connect/disconnect by [warp r]"
T[C85]="Linux Client 已安装，连接/断开 Client 可以用 warp r"
T[E86]="Client is working. Socks5 proxy listening on: \$(ss -nltp | grep warp | grep -oP '127.0*\S+')"
T[C86]="Linux Client 正常运行中。 Socks5 代理监听:\$(ss -nltp | grep warp | grep -oP '127.0*\S+')"
T[E87]="Fail to establish Socks5 proxy. Feedback: [https://github.com/fscarmen/warp/issues]"
T[C87]="创建 Socks5 代理失败，问题反馈:[https://github.com/fscarmen/warp/issues]"
T[E88]="Connect the client"
T[C88]="连接 Client"
T[E89]="Disconnect the client"
T[C89]="断开 Client"
T[E90]="Client is connected"
T[C90]="Client 已连接"
T[E91]="Client is disconnected. It could be connect again by [warp r]"
T[C91]="已断开 Client ，再次连接可以用 warp r"
T[E92]="Client is installed already. It could be uninstalled by [warp u]"
T[C92]="Client 已安装，如要卸载，可以用 warp u"
T[E93]="Client is not installed. It could be installed by [warp c]"
T[C93]="Client 未安装，如需安装，可以用 warp c"
T[E94]="Congratulations! WARP\$AC Linux Client is working. Spend time:\$(( end - start )) seconds.\\\n The script runs on today: \$TODAY. Total:\$TOTAL"
T[C94]="恭喜！WARP\$AC Linux Client 工作中, 总耗时:\$(( end - start ))秒， 脚本当天运行次数:\$TODAY，累计运行次数：\$TOTAL"
T[E95]="Client works with non-WARP IPv4. The script is aborted. Feedback: [https://github.com/fscarmen/warp/issues]"
T[C95]="Client 在非 WARP IPv4 下才能工作正常，脚本中止，问题反馈:[https://github.com/fscarmen/warp/issues]"
T[E96]="Client connecting failure. It may be a CloudFlare IPv4."
T[C96]="Client 连接失败，可能是 CloudFlare IPv4."
T[E97]="It is a WARP+ account already. Update is aborted."
T[C97]="已经是 WARP+ 账户，不需要升级"
T[E98]="\n 1. WGCF WARP account\n 2. WARP Linux Client account\n"
T[C98]="\n 1. WGCF WARP 账户\n 2. WARP Linux Client 账户\n"
T[E99]="Local Socks5:\$PROXYSOCKS5\\\n WARP\$AC IPv4:\$PROXYIP\\\n \$PROXYCOUNTRY\\\n \$PROXYASNORG"
T[C99]="本地 Socks5:\$PROXYSOCKS5\\\n WARP\$AC IPv4:\$PROXYIP\\\n \$PROXYCOUNTRY\\\n \$PROXYASNORG"
T[E100]="License should be 26 characters, please re-enter WARP+ License. Otherwise press Enter to continue. \(\$i times remaining\): "
T[C100]="License 应为26位字符,请重新输入 WARP+ License \(剩余\$i次\): "
T[E101]="Client doesn't support architecture ARM64. The script is aborted. Feedback: [https://github.com/fscarmen/warp/issues]"
T[C101]="Client 不支持 ARM64，问题反馈:[https://github.com/fscarmen/warp/issues]"
T[E102]="Please customize the WARP+ device name (Default is [WARP] if left blank):"
T[C102]="请自定义 WARP+ 设备名 (如果不输入，默认为 [WARP]):"
T[E103]="Port is in use. Please input another Port\(\$i times remaining\):"
T[C103]="端口占用中，请使用另一端口\(剩余\$i次\):"
T[E104]="Please customize the Client port (It must be 4-5 digits. Default to 40000 if it is blank):"
T[C104]="请自定义 Client 端口号 (必须为4-5位自然数，如果不输入，会默认40000):"
T[E105]="\n Please choose the priority:\n  1.IPv4 (default)\n  2.IPv6\n  3.Use initial settings\n"
T[C105]="\n 请选择优先级别:\n  1.IPv4 (默认)\n  2.IPv6\n  3.使用 VPS 初始设置\n"
T[E106]="IPv6 priority"
T[C106]="IPv6 优先"
T[E107]="IPv4 priority"
T[C107]="IPv4 优先"
T[E108]="\n 1. WGCF WARP IP ( Only IPv6 can be brushed when WGCF and Client exist at the same time )\n 2. WARP Linux Client IP\n"
T[C108]="\n 1. WGCF WARP IP ( WGCF 和 Client 并存时只能刷 IPv6)\n 2. WARP Linux Client IP\n"
T[E109]="Socks5 Proxy Client on IPv4 VPS is working now. You can only choose the WARP IPv6 interface, please enter [y] to continue, and other keys to exit:"
T[C109]="IPv4 only VPS，并且 Socks5 代理正在运行中，只能选择单栈方案，继续请输入 y，其他按键退出:"
T[E110]="Socks5 Proxy Client on native dualstack VPS is working now. WARP interface could not be installed. The script is aborted. Feedback: [https://github.com/fscarmen/warp/issues]"
T[C110]="原生双栈 VPS，并且 Socks5 代理正在运行中。WARP 网络接口不能安装，脚本中止，问题反馈:[https://github.com/fscarmen/warp/issues]"
T[E111]="Port must be 4-5 digits. Please re-input\(\$i times remaining\):"
T[C111]="端口必须为4-5位自然数，请重新输入\(剩余\$i次\):"
T[E112]="Client is not installed."
T[C112]="Client 未安装"
T[E113]="Client is installed and disconnected"
T[C113]="Client 已安装，状态为断开连接"
T[E114]="WARP\$TYPE Interface is on"
T[C114]="WARP\$TYPE 网络接口已开启"
T[E115]="WARP Interface is on"
T[C115]="WARP 网络接口已开启"
T[E116]="WARP Interface is off"
T[C116]="WARP 网络接口未开启"
T[E117]="Uninstall WARP Interface was complete."
T[C117]="WARP 网络接口卸载成功"
T[E118]="Uninstall WARP Interface was fail."
T[C118]="WARP 网络接口卸载失败"
T[E119]="Uninstall Socks5 Proxy Client was complete."
T[C119]="Socks5 Proxy Client 卸载成功"
T[E120]="Uninstall Socks5 Proxy Client was fail."
T[C120]="Socks5 Proxy Client 卸载失败"
T[E121]="Changing Netflix IP is adapted from other authors [luoxue-bot],[https://github.com/luoxue-bot/warp_auto_change_ip]"
T[C121]="更换支持 Netflix IP 改编自 [luoxue-bot] 的成熟作品，地址[https://github.com/luoxue-bot/warp_auto_change_ip]，请熟知"
T[E122]="WARP interface is not running.The script is aborted. Feedback: [https://github.com/fscarmen/warp/issues]"
T[C122]="WARP 还没有运行，脚本中止，问题反馈:[https://github.com/fscarmen/warp/issues]"
T[E123]="Change the WARP IP to support Netflix"
T[C123]="更换支持 Netflix 的 IP"
T[E124]="It is IPv6 priority now, press [y] to change to IPv4 priority? And other keys for unchanging:"
T[C124]="现在是 IPv6 优先，改为IPv4 优先的话请按 [y]，其他按键保持不变:"
T[E125]="\$(date +'%F %T') Region: \$REGION Done. IPv\$NF: \$WAN  \$COUNTRY  \$ASNORG. Retest after 1 hour. Brush ip runing time:\$DAY days \$HOUR hours \$MIN minutes \$SEC seconds" 
T[C125]="\$(date +'%F %T') 区域 \$REGION 解锁成功，IPv\$NF: \$WAN  \$COUNTRY  \$ASNORG，1 小时后重新测试，刷 IP 运行时长: \$DAY 天 \$HOUR 时 \$MIN 分 \$SEC 秒"
T[E126]="\$(date +'%F %T') Try \$i. Failed. IPv\$NF: \$WAN  \$COUNTRY  \$ASNORG. Retry after \$j seconds. Brush ip runing time:\$DAY days \$HOUR hours \$MIN minutes \$SEC seconds" 
T[C126]="\$(date +'%F %T') 尝试第\$i次，解锁失败，IPv\$NF: \$WAN  \$COUNTRY  \$ASNORG，\$j秒后重新测试，刷 IP 运行时长: \$DAY 天 \$HOUR 时 \$MIN 分 \$SEC 秒"
T[E127]="Please input Teams file URL (To use the one provided by the script if left blank):" 
T[C127]="请输入 Teams 文件 URL (如果留空，则使用脚本提供的):"
T[E128]="Successfully upgraded to a WARP Teams account"
T[C128]="已升级为 WARP Teams 账户"
T[E129]="The current Teams account is unavailable, automatically switch back to the free account"
T[C129]="当前 Teams 账户不可用，自动切换回免费账户"
T[E130]="\\\n Please confirm\\\n Private key : \$PRIVATEKEY \$MATCH1\\\n Public key : \$PUBLICKEY \$MATCH2\\\n Address IPv4 : \$ADDRESS4/32 \$MATCH3\\\n Address IPv6 : \$ADDRESS6/128 \$MATCH4\\\n"
T[C130]="\\\n 请确认Teams 信息\\\n Private key : \$PRIVATEKEY \$MATCH1\\\n Public key : \$PUBLICKEY \$MATCH2\\\n Address IPv4 : \$ADDRESS4/32 \$MATCH3\\\n Address IPv6 : \$ADDRESS6/128 \$MATCH4\\\n"
T[E131]="comfirm please enter [y] , and other keys to use free account:"
T[C131]="确认请按 y ，其他按键则使用免费账户:"
T[E132]="\n Is there a WARP+ or Teams account?\n 1. WARP+\n 2. Teams\n 3. use free account (default)\n"
T[C132]="\n 如有 WARP+ 或 Teams 账户请选择\n 1. WARP+\n 2. Teams\n 3. 使用免费账户 (默认)\n"
T[E133]="Device name：\$(grep -s 'Device name' /etc/wireguard/info.log | awk '{ print \$NF }')\\\n Quota：\$(grep -s Quota /etc/wireguard/info.log | awk '{ print \$(NF-1), \$NF }')"
T[C133]="设备名:\$(grep -s 'Device name' /etc/wireguard/info.log | awk '{ print \$NF }')\\\n 剩余流量:\$(grep -s Quota /etc/wireguard/info.log | awk '{ print \$(NF-1), \$NF }')"
T[E134]="Curren architecture \$(arch) is not supported. Feedback: [https://github.com/fscarmen/warp/issues]"
T[C134]="当前架构 \$(arch) 暂不支持,问题反馈:[https://github.com/fscarmen/warp/issues]"
T[E135]="( match √ )"
T[C135]="( 符合 √ )"
T[E136]="( mismatch X )"
T[C136]="( 不符合 X )"

# 脚本当天及累计运行次数统计
COUNT=$(curl -sm1 "https://hits.seeyoufarm.com/api/count/incr/badge.svg?url=https%3A%2F%2Fcdn.jsdelivr.net%2Fgh%2Ffscarmen%2Fwarp%2Fmenu.sh&count_bg=%2379C83D&title_bg=%23555555&icon=&icon_color=%23E7E7E7&title=&edge_flat=true" 2>&1) &&
TODAY=$(expr "$COUNT" : '.*\s\([0-9]\{1,\}\)\s/.*') && TOTAL=$(expr "$COUNT" : '.*/\s\([0-9]\{1,\}\)\s.*')
	
# 选择语言，先判断 /etc/wireguard/language 里的语言选择，没有的话再让用户选择，默认英语
case $(cat /etc/wireguard/language 2>&1) in
E ) L=E;;	C ) L=C;;
* ) L=E && [[ -z $OPTION || $OPTION = [chdpbvi12] ]] && yellow " ${T[${L}0]} " && reading " ${T[${L}50]} " LANGUAGE 
[[ $LANGUAGE = 2 ]] && L=C;;
esac

# 多方式判断操作系统，试到有值为止。只支持 Debian 10/11、Ubuntu 18.04/20.04 或 CentOS 7/8 ,如非上述操作系统，退出脚本
# 感谢猫大的技术指导优化重复的命令。https://github.com/Oreomeow
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
alpine_wgcf_restart(){ wg-quick down wgcf >/dev/null 2>&1; wg-quick up wgcf >/dev/null 2>&1; }
alpine_wgcf_enable(){ echo 'nohup wg-quick up wgcf &' > /etc/local.d/wgcf.start; chmod +x /etc/local.d/wgcf.start; rc-update add local; }

REGEX=("debian" "ubuntu" "centos|red hat|kernel|oracle linux|alma|rocky" "'amazon linux'" "alpine")
RELEASE=("Debian" "Ubuntu" "CentOS" "CentOS" "Alpine")
EXCLUDE=("bookworm")
COMPANY=("" "" "" "amazon" "")
MAJOR=("10" "18" "7" "7" "3")
PACKAGE_UPDATE=("apt -y update" "apt -y update" "yum -y update" "yum -y update" "apk update -f")
PACKAGE_INSTALL=("apt -y install" "apt -y install" "yum -y install" "yum -y install" "apk add -f")
PACKAGE_UNINSTALL=("apt -y autoremove" "apt -y autoremove" "yum -y autoremove" "yum -y autoremove" "apk del -f")
SYSTEMCTL_START=("systemctl start wg-quick@wgcf" "systemctl start wg-quick@wgcf" "systemctl start wg-quick@wgcf" "systemctl start wg-quick@wgcf" "wg-quick up wgcf")
SYSTEMCTL_RESTART=("systemctl restart wg-quick@wgcf" "systemctl restart wg-quick@wgcf" "systemctl restart wg-quick@wgcf" "systemctl restart wg-quick@wgcf" "alpine_wgcf_restart")
SYSTEMCTL_ENABLE=("systemctl enable --now wg-quick@wgcf" "systemctl enable --now wg-quick@wgcf" "systemctl enable --now wg-quick@wgcf" "systemctl enable --now wg-quick@wgcf" "alpine_wgcf_enable")

for ((int=0; int<${#REGEX[@]}; int++)); do
	[[ $(echo "$SYS" | tr '[:upper:]' '[:lower:]') =~ ${REGEX[int]} ]] && SYSTEM="${RELEASE[int]}" && COMPANY="${COMPANY[int]}" && [[ -n $SYSTEM ]] && break
done
[[ -z $SYSTEM ]] && red " ${T[${L}5]} " && exit 1

# 先排除 EXCLUDE 里包括的特定系统，其他系统需要作大发行版本的比较
for ex in "${EXCLUDE[@]}"; do [[ ! $(echo "$SYS" | tr '[:upper:]' '[:lower:]')  =~ $ex ]]; done &&
[[ $(echo $SYS | sed "s/[^0-9.]//g" | cut -d. -f1) -lt "${MAJOR[int]}" ]] && red " $(eval echo "${T[${L}26]}") " && exit 1

[[ $SYSTEM = Alpine ]] && ! type -P curl >/dev/null 2>&1 && ${PACKAGE_UPDATE[int]} && ${PACKAGE_INSTALL[int]} curl wget grep

# 检测 IPv4 IPv6 信息，WARP Ineterface 开启，普通还是 Plus账户 和 IP 信息
ip4_info(){
	IP4=$(curl -s4m8 https://ip.gs/json)
	LAN4=$(ip route get 162.159.192.1 2>/dev/null | grep -oP 'src \K\S+')
	WAN4=$(expr "$IP4" : '.*ip\":\"\([^"]*\).*')
	COUNTRY4=$(expr "$IP4" : '.*country\":\"\([^"]*\).*')
	ASNORG4=$(expr "$IP4" : '.*asn_org\":\"\([^"]*\).*')
	TRACE4=$(curl -s4m8 https://www.cloudflare.com/cdn-cgi/trace | grep warp | sed "s/warp=//g")
	if [[ $TRACE4 = plus ]]; then 
	grep -sq 'Device name' /etc/wireguard/info.log && PLUS4='+' || PLUS4=' Teams'
	fi
	[[ $TRACE4 = on || $TRACE4 = plus ]] && WARPSTATUS4="( WARP$PLUS4 IPv4 )"
	}

ip6_info(){
	IP6=$(curl -s6m8 https://ip.gs/json)
	LAN6=$(ip route get 2606:4700:d0::a29f:c001 2>/dev/null | grep -oP 'src \K\S+')
	WAN6=$(expr "$IP6" : '.*ip\":\"\([^"]*\).*')
	COUNTRY6=$(expr "$IP6" : '.*country\":\"\([^"]*\).*')
	ASNORG6=$(expr "$IP6" : '.*asn_org\":\"\([^"]*\).*')
	TRACE6=$(curl -s6m8 https://www.cloudflare.com/cdn-cgi/trace | grep warp | sed "s/warp=//g")
	if [[ $TRACE6 = plus ]]; then 
	grep -sq 'Device name' /etc/wireguard/info.log && PLUS6='+' || PLUS6=' Teams'
	fi
	[[ $TRACE6 = on || $TRACE6 = plus ]] && WARPSTATUS6="( WARP$PLUS6 IPv6 )"
	}

# 检测 Client 是否开启，普通还是 Plus账户 和 IP 信息
proxy_info(){
	unset PROXYSOCKS5 PROXYJASON PROXYIP PROXYCOUNTR PROXYASNORG ACCOUNT QUOTA AC
	PROXYSOCKS5=$(ss -nltp | grep warp | grep -oP '127.0*\S+')
	PROXYJASON=$(curl -s4m7 --socks5 "$PROXYSOCKS5" https://ip.gs/json)
	PROXYIP=$(expr "$PROXYJASON" : '.*ip\":\"\([^"]*\).*')
	PROXYCOUNTRY=$(expr "$PROXYJASON" : '.*country\":\"\([^"]*\).*')
	[[ $L = C ]] && PROXYCOUNTRY=$(translate "$PROXYCOUNTRY")
	PROXYASNORG=$(expr "$PROXYJASON" : '.*asn_org\":\"\([^"]*\).*')
	ACCOUNT=$(warp-cli --accept-tos account 2>/dev/null)
	if [[ $ACCOUNT =~ 'Limited' ]]; then
	QUOTA=$(expr "$ACCOUNT" : '.*Quota:\s\([0-9]\{1,\}\)\s.*')
	[[ $QUOTA -gt 10000000000000 ]] && QUOTA="$((QUOTA/1000000000000)) TiB" ||  QUOTA="$((QUOTA/1000000000)) GiB"
	AC='+'
	fi
	}

# 帮助说明
help(){	yellow " ${T[${L}6]} "; }

# 刷 WARP+ 流量
input(){
	reading " ${T[${L}52]} " ID
	i=5
	until [[ $ID =~ ^[A-F0-9a-f]{8}-[A-F0-9a-f]{4}-[A-F0-9a-f]{4}-[A-F0-9a-f]{4}-[A-F0-9a-f]{12}$ ]]
		do
		(( i-- )) || true
		[[ $i = 0 ]] && red " ${T[${L}29]} " && exit 1 || reading " $(eval echo "${T[${L}53]}") " ID
	done
	}

plus(){
	red "\n=============================================================="
	yellow " ${T[${L}54]}\n "
	green " ${T[${L}55]} "
	[[ -n $PLAN ]] && green " 4.${T[${L}49]} " || green " 4.${T[${L}76]} "
	red "=============================================================="
	reading " ${T[${L}50]} " CHOOSEPLUS
	case "$CHOOSEPLUS" in
		1 ) input
		    [[ $(type -P git) ]] || ${PACKAGE_INSTALL[int]} git 2>/dev/null
		    [[ $(type -P python3) ]] || ${PACKAGE_INSTALL[int]} python3 2>/dev/null
		    [[ -d ~/warp-plus-cloudflare ]] || git clone https://github.com/aliilapro/warp-plus-cloudflare.git
		    echo "$ID" | python3 ~/warp-plus-cloudflare/wp-plus.py;;
		2 ) input
		    reading " ${T[${L}57]} " MISSION
		    MISSION=${MISSION//[^0-9]/}
		    bash <(wget --no-check-certificate -qO- -T8 https://cdn.jsdelivr.net/gh/fscarmen/tools/warp_plus.sh) $MISSION $ID;;
		3 ) input
		    reading " ${T[${L}57]} " MISSION
		    MISSION=${MISSION//[^0-9]/}
		    bash <(wget --no-check-certificate -qO- -T8 https://cdn.jsdelivr.net/gh/SoftCreatR/warp-up/warp-up.sh) --disclaimer --id $ID --iterations $MISSION;;
		4 ) [[ -n $PLAN ]] && menu "$PLAN" || exit;;
		* ) red " ${T[${L}51]} [1-4] "; sleep 1; plus;;
	esac
	}

# 更换支持 Netflix WARP IP 改编自 [luoxue-bot] 的成熟作品，地址[https://github.com/luoxue-bot/warp_auto_change_ip]
change_ip(){
	change_wgcf(){
	if [[ $WGCFSTATUS$SOCKS5STATUS != 11 ]]; then
		[[ $(curl -sm8 https://ip.gs) =~ ":" ]] && NF=6 && reading " ${T[${L}124]} " NETFLIX || NF=4
		[[ $NETFLIX = [Yy] ]] && NF=4 && PRIORITY=1 && stack_priority
	else NF=6
	fi

	i=0;j=3
	while true
	do (( i++ )) || true
	ip_now=$(date +%s); RUNTIME=$((ip_now - ip_start)); DAY=$(( RUNTIME / 86400 )); HOUR=$(( (RUNTIME % 86400 ) / 3600 )); MIN=$(( (RUNTIME % 86400 % 3600) / 60 )); SEC=$(( RUNTIME % 86400 % 3600 % 60 ))
	RESULT=$(curl --user-agent "${UA_Browser}" -$NF -fsL --write-out %{http_code} --output /dev/null --max-time 10 "https://www.netflix.com/title/81215567"  2>&1)
	ip${NF}_info; until [[ -n $(eval echo \$IP$NF) ]]; do ip${NF}_info; done
	WAN=$(eval echo \$WAN$NF) && ASNORG=$(eval echo \$ASNORG$NF)
	[[ $L = C ]] && COUNTRY=$(translate "$(eval echo \$COUNTRY$NF)") || COUNTRY=$(eval echo \$COUNTRY$NF)
	if [[ $RESULT = 200 ]]; then
	REGION=$(tr '[:lower:]' '[:upper:]' <<< $(curl --user-agent "${UA_Browser}" -fs --max-time 10 --write-out %{redirect_url} --output /dev/null "https://www.netflix.com/title/80018499" | sed 's/.*com\/\([^-]\{1,\}\).*/\1/g'))
	REGION=${REGION:-US}
	green " $(eval echo "${T[${L}125]}") " && i=0 && sleep 1h
	else red " $(eval echo "${T[${L}126]}") " && ${SYSTEMCTL_RESTART[int]} && sleep $j
	fi
	done
	}
	
	change_socks5(){
	PROXYSOCKS5=$(ss -nltp | grep warp | grep -oP '127.0*\S+')
	
	i=0; [[ -e /etc/wireguard/license ]] && j=8 || j=10
	while true
	do (( i++ )) || true
	ip_now=$(date +%s); RUNTIME=$((ip_now - ip_start)); DAY=$(( RUNTIME / 86400 )); HOUR=$(( (RUNTIME % 86400 ) / 3600 )); MIN=$(( (RUNTIME % 86400 % 3600) / 60 )); SEC=$(( RUNTIME % 86400 % 3600 % 60 ))
	RESULT=$(curl --user-agent "${UA_Browser}" --socks5 "$PROXYSOCKS5" -fsL --write-out %{http_code} --output /dev/null --max-time 10 "https://www.netflix.com/title/81215567"  2>&1)
	proxy_info; until [[ -n "$PROXYJASON" ]]; do proxy_info; done
	WAN=$PROXYIP && ASNORG=$PROXYASNORG && NF=4 && COUNTRY=$PROXYCOUNTRY
	if [[ $RESULT = 200 ]]; then
	REGION=$(tr '[:lower:]' '[:upper:]' <<< $(curl --user-agent "${UA_Browser}" -fs --max-time 10 --write-out %{redirect_url} --output /dev/null "https://www.netflix.com/title/80018499" | sed 's/.*com\/\([^-]\{1,\}\).*/\1/g'))
	REGION=${REGION:-US}
	green " $(eval echo "${T[${L}125]}") " && i=0 && sleep 1h
	else red " $(eval echo "${T[${L}126]}") " && warp-cli --accept-tos delete >/dev/null 2>&1 && warp-cli --accept-tos register >/dev/null 2>&1 && sleep $j &&
	[[ -e /etc/wireguard/license ]] && warp-cli --accept-tos set-license $(cat /etc/wireguard/license) >/dev/null 2>&1 && sleep 2
	fi
	done
	}

	# 设置时区，让时间戳时间准确，显示脚本运行时长，中文为 GMT+8，英文为 UTC; 设置 UA
	ip_start=$(date +%s)
	[[ $L = C ]] && timedatectl set-timezone Asia/Shanghai || timedatectl set-timezone UTC
	UA_Browser="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.87 Safari/537.36"

	# 判断刷 IP 时 WGCF 和 Client 的状态，分情况处理
	WGCFSTATUS=0; SOCKS5STATUS=0
	yellow " ${T[${L}121]} "
	if [[ -z $(wg 2>/dev/null) ]]; then
	type -P wg-quick >/dev/null 2>&1 && wg-quick up wgcf >/dev/null 2>&1 && WGCFSTATUS=1
	else WGCFSTATUS=1
	fi

	if [[ ! $(ss -nltp) =~ 'warp-svc' ]]; then
	type -P warp-cli >/dev/null 2>&1 && warp-cli --accept-tos register >/dev/null 2>&1 && SOCKS5STATUS=1 && [[ -e /etc/wireguard/license ]] && warp-cli --accept-tos set-license $(cat /etc/wireguard/license)>/dev/null 2>&1
	else SOCKS5STATUS=1
	fi

	case $WGCFSTATUS$SOCKS5STATUS in
	01 ) change_socks5;;
	10 ) change_wgcf;;
	11 ) yellow " ${T[${L}108]} " && reading " ${T[${L}50]} " CHOOSESTATUS
		case "$CHOOSESTATUS" in
		1 ) change_wgcf;;	2 ) change_socks5;;	* ) red " ${T[${L}51]} [1-2]"; change_ip;;
		esac;;
	00 ) red " ${T[${L}122]} " && exit;;
	esac	
	}

# 设置部分后缀 1/3
case "$OPTION" in
h ) help; exit 0;;
p ) plus; exit 0;;
i ) change_ip; exit 0;;
esac

green " ${T[${L}37]} "

# 必须以root运行脚本
[[ $(id -u) != 0 ]] && red " ${T[${L}2]} " && exit 1

# 判断虚拟化，选择 Wireguard内核模块 还是 Wireguard-Go
VIRT=$(systemd-detect-virt 2>/dev/null | tr '[:upper:]' '[:lower:]')
[[ -n $VIRT ]] || VIRT=$(hostnamectl 2>/dev/null | tr '[:upper:]' '[:lower:]' | grep virtualization | sed "s/.*://g")
[[ $VIRT =~ openvz|lxc || -z $VIRT ]] && LXC=1

# 安装BBR
bbrInstall(){
	red "\n=============================================================="
	yellow " ${T[${L}47]}\n "
	green " 1.${T[${L}48]} "
	[[ -n $PLAN ]] && green " 2.${T[${L}49]} " || green " 2.${T[${L}76]} "
	red "=============================================================="
	reading " ${T[${L}50]} " BBR
	case "$BBR" in
		1 ) wget --no-check-certificate -N "https://raw.githubusercontent.com/ylx2016/Linux-NetSpeed/master/tcp.sh" && chmod +x tcp.sh && ./tcp.sh;;
		2 ) [[ -n $PLAN ]] && menu "$PLAN" || exit;;
		* ) red " ${T[${L}51]} [1-2]"; sleep 1; bbrInstall;;
	esac
	}

# 关闭 WARP 网络接口，并删除 WGCF
uninstall(){
	unset IP4 IP6 WAN4 WAN6 COUNTRY4 COUNTRY6 ASNORG4 ASNORG6
	# 卸载 WGCF
	uninstall_wgcf(){
	wg-quick down wgcf >/dev/null 2>&1
	systemctl disable --now wg-quick@wgcf >/dev/null 2>&1
	${PACKAGE_UNINSTALL[int]} wireguard-tools wireguard-dkms 2>/dev/null
	rpm -e wireguard-tools 2>/dev/null
	rm -rf /usr/local/bin/wgcf /etc/wireguard /usr/bin/wireguard-go wgcf-account.toml wgcf-profile.conf /usr/bin/warp
	[[ -e /etc/gai.conf ]] && sed -i '/^precedence \:\:ffff\:0\:0/d;/^label 2002\:\:\/16/d' /etc/gai.conf
	}
	
	# 卸载 Linux Client
	uninstall_proxy(){
	warp-cli --accept-tos disconnect >/dev/null 2>&1
	warp-cli --accept-tos disable-always-on >/dev/null 2>&1
	warp-cli --accept-tos delete >/dev/null 2>&1
	${PACKAGE_UNINSTALL[int]} cloudflare-warp 2>/dev/null
	systemctl disable --now warp-svc >/dev/null 2>&1
	rm -rf /usr/local/bin/wgcf /etc/wireguard /usr/bin/wireguard-go wgcf-account.toml wgcf-profile.conf /usr/bin/warp
	}
	
	# 根据已安装情况执行卸载任务并显示结果
	[[ $(type -P wg-quick) ]] && (uninstall_wgcf; green " ${T[${L}117]} ")
	[[ $(type -P warp-cli) ]] && (uninstall_proxy; green " ${T[${L}119]} ")

	# 显示卸载结果
	ip4_info; [[ $L = C && -n "$COUNTRY4" ]] && COUNTRY4=$(translate "$COUNTRY4")
	ip6_info; [[ $L = C && -n "$COUNTRY6" ]] && COUNTRY6=$(translate "$COUNTRY6")
	green " ${T[${L}45]}\n IPv4：$WAN4 $COUNTRY4 $ASNORG4\n IPv6：$WAN6 $COUNTRY6 $ASNORG6 "
	}
	
# 同步脚本至最新版本
ver(){
	wget -N -P /etc/wireguard https://raw.githubusercontent.com/fscarmen/warp/main/menu.sh || wget -N -P /etc/wireguard https://cdn.jsdelivr.net/gh/fscarmen/warp/menu.sh
	chmod +x /etc/wireguard/menu.sh
	ln -sf /etc/wireguard/menu.sh /usr/bin/warp
	green " ${T[${L}64]}:$(grep ^VERSION /etc/wireguard/menu.sh | sed "s/.*=//g")  ${T[${L}18]}：$(grep "T\[${L}1]" /etc/wireguard/menu.sh | cut -d \" -f2) " || red " ${T[${L}65]} "
	exit
	}

# 由于warp bug，有时候获取不了ip地址，加入刷网络脚本手动运行，并在定时任务加设置 VPS 重启后自动运行,i=当前尝试次数，j=要尝试的次数
net(){
	unset IP4 IP6 WAN4 WAN6 COUNTRY4 COUNTRY6 ASNORG4 ASNORG6
	[[ ! $(type -P wg-quick) || ! -e /etc/wireguard/wgcf.conf ]] && red " ${T[${L}10]} " && exit 1
	i=1;j=5
	yellow " $(eval echo "${T[${L}11]}")\n $(eval echo "${T[${L}12]}") "
	[[ $SYSTEM != Alpine ]] && [[ $(systemctl is-active wg-quick@wgcf) != 'active' ]] && wg-quick down wgcf >/dev/null 2>&1
	${SYSTEMCTL_START[int]} >/dev/null 2>&1
	wg-quick up wgcf >/dev/null 2>&1
	ip4_info
	[[ -n $IP4 ]] && ip6_info
	until [[ -n $IP4 && -n $IP6 && $TRACE4$TRACE6 =~ on|plus ]]
		do	(( i++ )) || true
			yellow " $(eval echo "${T[${L}12]}") "
			${SYSTEMCTL_RESTART[int]} >/dev/null 2>&1
			ip4_info
			[[ -n $IP4 ]] && ip6_info
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
	green " ${T[${L}14]} "
	[[ $L = C ]] && COUNTRY4=$(translate "$COUNTRY4")
	[[ $L = C ]] && COUNTRY6=$(translate "$COUNTRY6")
	[[ $OPTION = [on] ]] && green " IPv4:$WAN4 $WARPSTATUS4 $COUNTRY4 $ASNORG4\n IPv6:$WAN6 $WARPSTATUS6 $COUNTRY6 $ASNORG6 "
	}

# WARP 开关
onoff(){
	[[ -n $(wg 2>/dev/null) ]] && (wg-quick down wgcf >/dev/null 2>&1; green " ${T[${L}15]} ") || net
	}

# PROXY 开关
proxy_onoff(){
	PROXY=$(warp-cli --accept-tos status 2>/dev/null)
	[[ -z $PROXY ]] && red " ${T[${L}93]} " && exit 1
	[[ $PROXY =~ Connecting ]] && red " ${T[${L}96]} " && exit 1
	[[ $PROXY =~ missing ]] && warp-cli --accept-tos register >/dev/null 2>&1 &&
	[[ -e /etc/wireguard/license ]] && warp-cli --accept-tos set-license $(cat /etc/wireguard/license)>/dev/null 2>&1
	[[ $PROXY =~ Connected ]] && warp-cli --accept-tos disconnect >/dev/null 2>&1 && warp-cli --accept-tos disable-always-on >/dev/null 2>&1 && 
	[[ ! $(ss -nltp) =~ 'warp-svc' ]] && green " ${T[${L}91]} "  && exit 0
	[[ $PROXY =~ Disconnected ]] && warp-cli --accept-tos connect >/dev/null 2>&1 && warp-cli --accept-tos enable-always-on >/dev/null 2>&1 && STATUS=1 && proxy_info
	[[ $STATUS = 1 ]] && [[ $(ss -nltp) =~ 'warp-svc' ]] && green " ${T[${L}90]}\n $(eval echo "${T[${L}99]}") " && exit 0
	[[ $STATUS = 1 ]] && [[ $(warp-cli --accept-tos status 2>/dev/null) =~ Connecting ]] && red " ${T[${L}96]} " && exit 1
    }

# 设置部分后缀 2/3
case "$OPTION" in
b ) bbrInstall; exit 0;;
u ) uninstall; exit 0;;
v ) ver; exit 0;;
n ) net; exit 0;;
o ) onoff; exit 0;;
r ) proxy_onoff; exit 0;;
esac

# 必须加载 TUN 模块
TUN=$(cat /dev/net/tun 2>&1 | tr '[:upper:]' '[:lower:]')
[[ ! $TUN =~ 'in bad state' ]] && [[ ! $TUN =~ '处于错误状态' ]] && red " ${T[${L}3]} " && exit 1

# 判断是否大陆 VPS。先尝试连接 CloudFlare WARP 服务的 Endpoint IP，如遇到 WARP 断网则先关闭、杀进程后重试一次，仍然不通则 WARP 项目不可用。
ping6 -c2 -w8 2606:4700:d0::a29f:c001 >/dev/null 2>&1 && IPV6=1 && CDN=-6 || IPV6=0
ping -c2 -W8 162.159.192.1 >/dev/null 2>&1 && IPV4=1 && CDN=-4 || IPV4=0
if [[ $IPV4$IPV6 = 00 && -n $(wg) ]]; then
	wg-quick down wgcf >/dev/null 2>&1
	kill -9 $(pgrep -f wireguard 2>/dev/null)
	ping6 -c2 -w10 2606:4700:d0::a29f:c001 >/dev/null 2>&1 && IPV6=1 && CDN=-6
	ping -c2 -W10 162.159.192.1 >/dev/null 2>&1 && IPV4=1 && CDN=-4
fi
[[ $IPV4$IPV6 = 00 ]] && red " ${T[${L}4]} " && exit 1

# 安装 curl
type -P curl >/dev/null 2>&1 || (yellow " ${T[${L}7]} " && ${PACKAGE_INSTALL[int]} curl) || (yellow " ${T[${L}8]} " && ${PACKAGE_UPDATE[int]} && ${PACKAGE_INSTALL[int]} curl)
! type -P curl >/dev/null 2>&1 && yellow " ${T[${L}9]} " && exit 1

# 判断处理器架构
case $(tr '[:upper:]' '[:lower:]' <<< "$(arch)") in
aarch64 ) ARCHITECTURE=arm64;;	x86_64 ) ARCHITECTURE=amd64;;	s390x ) ARCHITECTURE=s390x && S390X='-s390x';;	* ) red " $(eval echo "${T[${L}134]}") " && exit 1;;
esac

# 判断当前 IPv4 与 IPv6 ，IP归属 及 WARP, Linux Client 是否开启
[[ $IPV4 = 1 ]] && ip4_info
[[ $IPV6 = 1 ]] && ip6_info
[[ $L = C && -n "$COUNTRY4" ]] && COUNTRY4=$(translate "$COUNTRY4")
[[ $L = C && -n "$COUNTRY6" ]] && COUNTRY6=$(translate "$COUNTRY6")

# 判断当前 WARP 状态，决定变量 PLAN，变量 PLAN 含义：1=单栈  2=双栈  3=WARP已开启
[[ $TRACE4 = plus || $TRACE4 = on || $TRACE6 = plus || $TRACE6 = on ]] && PLAN=3 || PLAN=$((IPV4+IPV6))

# 判断当前 Linux Client 状态，决定变量 CLIENT，变量 CLIENT 含义：0=未安装  1=已安装未激活  2=状态激活  3=Clinet 已开启
[[ $(type -P warp-cli 2>/dev/null) ]] && CLIENT=1 || CLIENT=0
[[ $CLIENT = 1 ]] && [[ $(systemctl is-active warp-svc 2>/dev/null) = active || $(systemctl is-enabled warp-svc 2>/dev/null) = enabled ]] && CLIENT=2
[[ $CLIENT = 2 ]] && [[ $(ss -nltp) =~ 'warp-svc' ]] && CLIENT=3 && proxy_info

# 在KVM的前提下，判断 Linux 版本是否小于 5.6，如是则安装 wireguard 内核模块，变量 WG=1。由于 linux 不能直接用小数作比较，所以用 （主版本号 * 100 + 次版本号 ）与 506 作比较
[[ $LXC != 1 && $(($(uname -r | cut -d . -f1) * 100 +  $(uname -r | cut -d . -f2))) -lt 506 ]] && WG=1

# WGCF 配置修改，其中用到的 162.159.192.1 和 2606:4700:d0::a29f:c001 均是 engage.cloudflareclient.com 的IP
MODIFYS01='sed -i "s/1.1.1.1/2606:4700:4700::1111,2001:4860:4860::8888,2001:4860:4860::8844,1.1.1.1,8.8.8.8,8.8.4.4/g;/\:\:\/0/d;s/engage.cloudflareclient.com/[2606:4700:d0::a29f:c001]/g" wgcf-profile.conf'
MODIFYD01='sed -i "s/1.1.1.1/2606:4700:4700::1111,2001:4860:4860::8888,2001:4860:4860::8844,1.1.1.1,8.8.8.8,8.8.4.4/g;7 s/^/PostDown = ip -6 rule delete from '$LAN6' lookup main\n/;7 s/^/PostUp = ip -6 rule add from '$LAN6' lookup main\n/;s/engage.cloudflareclient.com/[2606:4700:d0::a29f:c001]/g" wgcf-profile.conf'
MODIFYS10='sed -i "s/1.1.1.1/1.1.1.1,8.8.8.8,8.8.4.4,2606:4700:4700::1111,2001:4860:4860::8888,2001:4860:4860::8844/g;/0\.\0\/0/d;s/engage.cloudflareclient.com/162.159.192.1/g" wgcf-profile.conf'
MODIFYD10='sed -i "s/1.1.1.1/1.1.1.1,8.8.8.8,8.8.4.4,2606:4700:4700::1111,2001:4860:4860::8888,2001:4860:4860::8844/g;7 s/^/PostDown = ip -4 rule delete from '$LAN4' lookup main\n/;7 s/^/PostUp = ip -4 rule add from '$LAN4' lookup main\n/;s/engage.cloudflareclient.com/162.159.192.1/g" wgcf-profile.conf'
MODIFYD11='sed -i "s/1.1.1.1/1.1.1.1,8.8.8.8,8.8.4.4,2606:4700:4700::1111,2001:4860:4860::8888,2001:4860:4860::8844/g;7 s/^/PostDown = ip -6 rule delete from '$LAN6' lookup main\n/;7 s/^/PostUp = ip -6 rule add from '$LAN6' lookup main\n/;7 s/^/PostDown = ip -4 rule delete from '$LAN4' lookup main\n/;7 s/^/PostUp = ip -4 rule add from '$LAN4' lookup main\n/" wgcf-profile.conf'

# 替换为 Teams 账户信息
teams_change(){
	sed -i "s#PrivateKey.*#PrivateKey = $PRIVATEKEY#g;s#Address.*32#Address = ${ADDRESS4}/32#g;s#Address.*128#Address = ${ADDRESS6}/128#g;s#PublicKey.*#PublicKey = $PUBLICKEY#g" /etc/wireguard/wgcf.conf
		case $IPV4$IPV6 in
			01 ) sed -i "s#Endpoint.*#Endpoint = $(expr "$TEAMS" : '.*v6&quot;:&quot;\(\[[^&]*\).*')#g" /etc/wireguard/wgcf.conf;;
			10 ) sed -i "s#Endpoint.*#Endpoint = $(expr "$TEAMS" : '.*endpoint&quot;:{&quot;v4&quot;:&quot;\([^&]*\).*')#g" /etc/wireguard/wgcf.conf;;	
		esac
	}
	
# 输入 WARP+ 账户（如有），限制位数为空或者26位以防输入错误
input_license(){
	[[ -z $LICENSE ]] && reading " ${T[${L}28]} " LICENSE
	i=5
	until [[ -z $LICENSE || $LICENSE =~ ^[A-Z0-9a-z]{8}-[A-Z0-9a-z]{8}-[A-Z0-9a-z]{8}$ ]]
		do	(( i-- )) || true
			[[ $i = 0 ]] && red " ${T[${L}29]} " && exit 1 || reading " $(eval echo "${T[${L}30]}") " LICENSE
		done
	if [[ $INPUT_LICENSE = 1 ]]; then
		[[ -n $LICENSE && -z $NAME ]] && reading " ${T[${L}102]} " NAME
		[[ -n $NAME ]] && NAME="${NAME//[[:space:]]/_}" || NAME=${NAME:-'WARP'}
	fi
	}

# 输入 Teams 账户 URL（如有）
input_url(){
	[[ -z $URL ]] && reading " ${T[${L}127]} " URL
	URL=${URL:-'https://gist.githubusercontent.com/fscarmen/56aaf02d743551737c9973b8be7a3496/raw/16cf34edf5fb28be00f53bb1c510e95a35491032/com.cloudflare.onedotonedotonedotone_preferences.xml'}
	TEAMS=$(curl -sSL "$URL" | sed "s/\"/\&quot;/g")
	PRIVATEKEY=$(expr "$TEAMS" : '.*private_key&quot;>\([^<]*\).*')
	PUBLICKEY=$(expr "$TEAMS" : '.*public_key&quot;:&quot;\([^&]*\).*')
	ADDRESS4=$(expr "$TEAMS" : '.*v4&quot;:&quot;\(172[^&]*\).*')
	ADDRESS6=$(expr "$TEAMS" : '.*v6&quot;:&quot;\([^[&]*\).*')
	[[ $PRIVATEKEY =~ ^[A-Z0-9a-z/+]{43}=$ ]] && MATCH1=${T[${L}135]} || MATCH1=${T[${L}136]}
	[[ $PUBLICKEY =~ ^[A-Z0-9a-z/+]{43}=$ ]] && MATCH2=${T[${L}135]} || MATCH2=${T[${L}136]}
	[[ $ADDRESS4 =~ ^172.16.[01].[0-9]{1,3}$ ]] && MATCH3=${T[${L}135]} || MATCH3=${T[${L}136]}
	[[ $ADDRESS6 =~ ^fd01(:[0-9a-f]{0,4}){7}$ ]] && MATCH4=${T[${L}135]} || MATCH4=${T[${L}136]}
	yellow " $(eval echo "${T[${L}130]}") " && reading " ${T[${L}131]} " CONFIRM
	}

# 升级 WARP+ 账户（如有），限制位数为空或者26位以防输入错误，WARP interface 可以自定义设备名(不允许字符串间有空格，如遇到将会以_代替)
update_license(){
	[[ -z $LICENSE ]] && reading " ${T[${L}61]} " LICENSE
	i=5
	until [[ $LICENSE =~ ^[A-Z0-9a-z]{8}-[A-Z0-9a-z]{8}-[A-Z0-9a-z]{8}$ ]]
		do	(( i-- )) || true
			[[ $i = 0 ]] && red " ${T[${L}29]} " && exit 1 || reading " $(eval echo "${T[${L}100]}") " LICENSE
	       done
	[[ $UPDATE_LICENSE = 1 && -n $LICENSE && -z $NAME ]] && reading " ${T[${L}102]} " NAME
	[[ -n $NAME ]] && NAME="${NAME//[[:space:]]/_}" || NAME=${NAME:-'WARP'}
}

# 输入 Linux Client 端口,先检查默认的40000是否被占用,限制4-5位数字,准确匹配空闲端口
input_port(){
	ss -nltp | grep -q ':40000'[[:space:]] && reading " $(eval echo "${T[${L}103]}") " PORT || reading " ${T[${L}104]} " PORT
	PORT=${PORT:-'40000'}
	i=5
	until echo "$PORT" | grep -qE "^[1-9][0-9]{3,4}$" && [[ ! $(ss -nltp) =~ :"$PORT"[[:space:]] ]]
		do	(( i-- )) || true
			[[ $i = 0 ]] && red " ${T[${L}29]} " && exit 1
			echo "$PORT" | grep -qvE "^[1-9][0-9]{1,4}$" && reading " $(eval echo "${T[${L}111]}") " PORT
			echo "$PORT" | grep -qE "^[1-9][0-9]{1,4}$" && [[ $(ss -nltp) =~ :"$PORT"[[:space:]] ]] && reading " $(eval echo "${T[${L}103]}") " PORT
		done
}

# IPv4 / IPv6 优先
stack_priority(){
	[[ -e /etc/gai.conf ]] && sed -i '/^precedence \:\:ffff\:0\:0/d;/^label 2002\:\:\/16/d' /etc/gai.conf
	case "$PRIORITY" in
		2 )	echo "label 2002::/16   2" >> /etc/gai.conf;;
		3 )	;;
		* )	echo "precedence ::ffff:0:0/96  100" >> /etc/gai.conf;;
	esac
}

# WGCF 安装
install(){
	# 先删除之前安装，可能导致失败的文件
	rm -rf /usr/local/bin/wgcf /usr/bin/wireguard-go wgcf-account.toml wgcf-profile.conf
	
	# 询问是否有 WARP+ 或 Teams 账户
	[[ -z $LICENSETYPE ]] && yellow " ${T[${L}132]}" && reading " ${T[${L}50]} " LICENSETYPE
	case $LICENSETYPE in
	1 ) INPUT_LICENSE=1 && input_license;;	
	2 ) input_url;;
	esac

	# 选择优先使用 IPv4 /IPv6 网络
	yellow " ${T[${L}105]} " && reading " ${T[${L}50]} " PRIORITY

	# 脚本开始时间
	start=$(date +%s)
			
	# 注册 WARP 账户 (将生成 wgcf-account.toml 文件保存账户信息)
	# 判断 wgcf 的最新版本,如因 github 接口问题未能获取，默认 v2.2.11
	{	
	latest=$(wget --no-check-certificate -qO- -T1 -t1 $CDN "https://api.github.com/repos/ViRb3/wgcf/releases/latest" | grep "tag_name" | head -n 1 | cut -d : -f2 | sed 's/[ \"v,]//g')
	latest=${latest:-'2.2.11'}

	# 安装 wgcf，尽量下载官方的最新版本，如官方 wgcf 下载不成功，将使用 jsDelivr 的 CDN，以更好的支持双栈。并添加执行权限
	wget --no-check-certificate -T1 -t1 $CDN -O /usr/local/bin/wgcf https://github.com/ViRb3/wgcf/releases/download/v"$latest"/wgcf_"$latest"_linux_$ARCHITECTURE ||
	wget --no-check-certificate $CDN -O /usr/local/bin/wgcf https://cdn.jsdelivr.net/gh/fscarmen/warp/wgcf_"$latest"_linux_$ARCHITECTURE
	chmod +x /usr/local/bin/wgcf
	
	# 注册 WARP 账户 ( wgcf-account.toml 使用默认值加加快速度)。如有 WARP+ 账户，修改 license 并升级，并把设备名等信息保存到 /etc/wireguard/info.log
	mkdir -p /etc/wireguard/ >/dev/null 2>&1
	until [[ -e wgcf-account.toml ]] >/dev/null 2>&1; do
		wgcf register --accept-tos >/dev/null 2>&1 && break
	done
	[[ -n $LICENSE ]] && yellow " \n${T[${L}35]}\n " && sed -i "s/license_key.*/license_key = \"$LICENSE\"/g" wgcf-account.toml &&
	( wgcf update --name "$NAME" > /etc/wireguard/info.log 2>&1 || red " \n${T[${L}36]}\n " )

	# 生成 Wire-Guard 配置文件 (wgcf-profile.conf)
	[[ -e wgcf-account.toml ]] && wgcf generate >/dev/null 2>&1
	green " \n${T[${L}33]}\n "

	# 反复测试最佳 MTU。 Wireguard Header：IPv4=60 bytes,IPv6=80 bytes，1280 ≤1 MTU ≤ 1420。 ping = 8(ICMP回显示请求和回显应答报文格式长度) + 20(IP首部) 。
	# 详细说明：<[WireGuard] Header / MTU sizes for Wireguard>：https://lists.zx2c4.com/pipermail/wireguard/2017-December/002201.html
	MTU=$((1500-28))
	[[ $IPV4$IPV6 = 01 ]] && ping6 -c1 -W1 -s $MTU -Mdo 2606:4700:d0::a29f:c001 >/dev/null 2>&1 || ping -c1 -W1 -s $MTU -Mdo 162.159.192.1 >/dev/null 2>&1
	until [[ $? = 0 || $MTU -le $((1280+80-28)) ]]
	do
	MTU=$((MTU-10))
	[[ $IPV4$IPV6 = 01 ]] && ping6 -c1 -W1 -s $MTU -Mdo 2606:4700:d0::a29f:c001 >/dev/null 2>&1 || ping -c1 -W1 -s $MTU -Mdo 162.159.192.1 >/dev/null 2>&1
	done

	if [[ $MTU -eq $((1500-28)) ]]; then MTU=$MTU
	elif [[ $MTU -le $((1280+80-28)) ]]; then MTU=$((1280+80-28))
	else
		for ((i=0; i<9; i++)); do
		(( MTU++ ))
		( [[ $IPV4$IPV6 = 01 ]] && ping6 -c1 -W1 -s $MTU -Mdo 2606:4700:d0::a29f:c001 >/dev/null 2>&1 || ping -c1 -W1 -s $MTU -Mdo 162.159.192.1 >/dev/null 2>&1 ) || break
		done
		(( MTU-- ))
	fi

	MTU=$((MTU+28-80))

	[[ -e wgcf-profile.conf ]] && sed -i "s/MTU.*/MTU = $MTU/g" wgcf-profile.conf && green " \n${T[${L}81]}\n "

	}&

	# 对于 IPv4 only VPS 开启 IPv6 支持
	# 感谢 P3terx 大神项目这块的技术指导。项目:https://github.com/P3TERX/warp.sh/blob/main/warp.sh
    	{
	[[ $IPV4$IPV6 = 10 ]] && [[ $(sysctl -a 2>/dev/null | grep 'disable_ipv6.*=.*1') || $(grep -s "disable_ipv6.*=.*1" /etc/sysctl.{conf,d/*} ) ]] &&
	(sed -i '/disable_ipv6/d' /etc/sysctl.{conf,d/*}
        echo 'net.ipv6.conf.all.disable_ipv6 = 0' >/etc/sysctl.d/ipv6.conf
        sysctl -w net.ipv6.conf.all.disable_ipv6=0)
	}&

        # 优先使用 IPv4 /IPv6 网络
	{ stack_priority; }&
	
	# 根据系统选择需要安装的依赖
	green " \n${T[${L}32]}\n "
	
	Debian(){
		# 更新源
		${PACKAGE_UPDATE[int]}

		# 添加 backports 源,之后才能安装 wireguard-tools 
		${PACKAGE_INSTALL[int]} lsb-release
		echo "deb http://deb.debian.org/debian $(lsb_release -sc)-backports main" > /etc/apt/sources.list.d/backports.list

		# 再次更新源
		${PACKAGE_UPDATE[int]}

		# 安装一些必要的网络工具包和wireguard-tools (Wire-Guard 配置工具：wg、wg-quick)
		${PACKAGE_INSTALL[int]} --no-install-recommends net-tools iproute2 openresolv dnsutils wireguard-tools iptables

		# 如 Linux 版本低于5.6并且是 kvm，则安装 wireguard 内核模块
		[[ $WG = 1 ]] && ${PACKAGE_INSTALL[int]} --no-install-recommends linux-headers-"$(uname -r)" && ${PACKAGE_INSTALL[int]} --no-install-recommends wireguard-dkms
		}
		
	Ubuntu(){
		# 更新源
		${PACKAGE_UPDATE[int]}

		# 安装一些必要的网络工具包和 wireguard-tools (Wire-Guard 配置工具：wg、wg-quick)
		${PACKAGE_INSTALL[int]} --no-install-recommends net-tools iproute2 openresolv dnsutils wireguard-tools iptables
		}
		
	CentOS(){
		# 安装一些必要的网络工具包和wireguard-tools (Wire-Guard 配置工具：wg、wg-quick)
		[[ $COMPANY = amazon ]] && ${PACKAGE_UPDATE[int]} && amazon-linux-extras install -y epel		
		${PACKAGE_INSTALL[int]} epel-release
		${PACKAGE_INSTALL[int]} wireguard-tools net-tools iptables

		# 如 Linux 版本低于5.6并且是 kvm，则安装 wireguard 内核模块
		VERSION_ID=$(expr "$SYS" : '.*\s\([0-9]\{1,\}\)\.*')
		[[ $WG = 1 ]] && curl -Lo /etc/yum.repos.d/wireguard.repo https://copr.fedorainfracloud.org/coprs/jdoss/wireguard/repo/epel-"$VERSION_ID"/jdoss-wireguard-epel-"$VERSION_ID".repo &&
		${PACKAGE_INSTALL[int]} wireguard-dkms

		# 升级所有包同时也升级软件和系统内核
		${PACKAGE_UPDATE[int]}
		
		# s390x wireguard-tools 安装
		[[ $ARCHITECTURE = s390x ]] && ! type -P wg >/etc/null 2>&1 && rpm -i https://mirrors.cloud.tencent.com/epel/8/Everything/s390x/Packages/w/wireguard-tools-1.0.20210914-1.el8.s390x.rpm
		}

	Alpine(){
		# 安装一些必要的网络工具包和wireguard-tools (Wire-Guard 配置工具：wg、wg-quick)
		${PACKAGE_INSTALL[int]} net-tools iproute2 openresolv wireguard-tools openrc iptables
		}


	$SYSTEM
	
	wait

	echo "$MODIFY" | sh
	
	# 特殊 VPS 的配置文件 DNS 次序
	[[ $(hostname 2>&1) = DiG9 ]] && sed -i "s/DNS.*/DNS = 2001:4860:4860::8888,2001:4860:4860::8844,8.8.8.8,8.8.4.4/g" wgcf-profile.conf

	# 把 wgcf-profile.conf 复制到/etc/wireguard/ 并命名为 wgcf.conf, 如有 Teams，改为 Teams 账户信息
	cp -f wgcf-profile.conf /etc/wireguard/wgcf.conf >/dev/null 2>&1
	
	[[ $CONFIRM = [Yy] ]] && teams_change && echo "$TEAMS" > /etc/wireguard/info.log 2>&1

	# 设置开机启动
	${SYSTEMCTL_ENABLE[int]}>/dev/null 2>&1

	# 如是 LXC，安装 Wireguard-GO。部分较低内核版本的KVM，即使安装了wireguard-dkms, 仍不能正常工作，兜底使用 wireguard-go
	[[ $LXC = 1 ]] || ([[ $WG = 1 ]] && [[ $(systemctl is-active wg-quick@wgcf) != active || $(systemctl is-enabled wg-quick@wgcf) != enabled ]]) &&
	wget --no-check-certificate $CDN -O /usr/bin/wireguard-go https://cdn.jsdelivr.net/gh/fscarmen/warp/wireguard-go$S390X && chmod +x /usr/bin/wireguard-go

	# 保存好配置文件
	mv -f wgcf-account.toml wgcf-profile.conf menu.sh /etc/wireguard >/dev/null 2>&1

	# 创建再次执行的软链接快捷方式，再次运行可以用 warp 指令,设置默认语言
	chmod +x /etc/wireguard/menu.sh >/dev/null 2>&1
	ln -sf /etc/wireguard/menu.sh /usr/bin/warp && green " ${T[${L}38]} "
	echo "$L" >/etc/wireguard/language
	
	# 自动刷直至成功（ warp bug，有时候获取不了ip地址），重置之前的相关变量值，记录新的 IPv4 和 IPv6 地址和归属地，IPv4 / IPv6 优先级别
	green " ${T[${L}39]} "
	unset IP4 IP6 WAN4 WAN6 COUNTRY4 COUNTRY6 ASNORG4 ASNORG6 TRACE4 TRACE6 PLUS4 PLUS6 WARPSTATUS4 WARPSTATUS6
	[[ $COMPANY = amazon ]] && red " $(eval echo "${T[${L}40]}") " && reboot || net
	[[ $(curl -sm8 https://ip.gs) = "$WAN6" ]] && PRIORITY=${T[${L}106]} || PRIORITY=${T[${L}107]}
	
	# 部分 LXC 内核已经包含 WireGuard 模块则会优先使用，此场景下删除 WireGuard-go
	[[ -e /usr/bin/wireguard-go ]] && ! pgrep -laf "wireguard-go" >/dev/null 2>&1 && rm -f /usr/bin/wireguard-go

	# 结果提示，脚本运行时间，次数统计
	end=$(date +%s)
	red "\n==============================================================\n"
	green " IPv4：$WAN4 $WARPSTATUS4 $COUNTRY4  $ASNORG4 "
	green " IPv6：$WAN6 $WARPSTATUS6 $COUNTRY6  $ASNORG6 "
	grep -sq 'Device name' /etc/wireguard/info.log 2>/dev/null && TYPE='+' || TYPE=' Teams'
	[[ $TRACE4 = plus || $TRACE6 = plus ]] && green " $(eval echo "${T[${L}41]}") " && grep -sq 'Device name' /etc/wireguard/info.log && green " $(eval echo "${T[${L}133]}") "
	[[ $TRACE4 = on || $TRACE6 = on ]] && green " $(eval echo "${T[${L}42]}") "
	green " $PRIORITY "
	red "\n==============================================================\n"
	yellow " ${T[${L}43]}\n " && help
	[[ $TRACE4 = off && $TRACE6 = off ]] && red " ${T[${L}44]} "
	}

proxy(){
	settings(){
		# 设置为代理模式，如有 WARP+ 账户，修改 license 并升级
		green " ${T[${L}84]} "
		warp-cli --accept-tos register >/dev/null 2>&1
		warp-cli --accept-tos set-mode proxy >/dev/null 2>&1
		warp-cli --accept-tos set-proxy-port "$PORT" >/dev/null 2>&1
		warp-cli --accept-tos connect >/dev/null 2>&1
		warp-cli --accept-tos enable-always-on >/dev/null 2>&1
		[[ -n $LICENSE ]] && ( yellow " ${T[${L}35]} " && 
		warp-cli --accept-tos set-license "$LICENSE" >/dev/null 2>&1 && sleep 1 &&
		ACCOUNT=$(warp-cli --accept-tos account 2>/dev/null) &&
		[[ $ACCOUNT =~ Limited ]] && echo "$LICENSE" >/etc/wireguard/license && green " ${T[${L}62]} " ||
		red " ${T[${L}36]} " )
		sleep 2 && [[ ! $(ss -nltp) =~ 'warp-svc' ]] && red " ${T[${L}87]} " && exit 1 || green " $(eval echo "${T[${L}86]}") "
		}
	
	[[ $ARCHITECTURE = arm64 ]] && red " ${T[${L}101]} " && exit 1
	[[ $TRACE4 != off ]] && red " ${T[${L}95]} " && exit 1

 	# 安装 WARP Linux Client
	input_license
	input_port
	start=$(date +%s)
	mkdir -p /etc/wireguard/ >/dev/null 2>&1
	if [[ $CLIENT = 0 ]]; then
	green " ${T[${L}83]} "
	[[ $SYSTEM = CentOS ]] && (rpm -ivh http://pkg.cloudflareclient.com/cloudflare-release-el"$(expr "$SYS" : '.*\s\([0-9]\{1,\}\)\.*')".rpm
	${PACKAGE_UPDATE[int]}; ${PACKAGE_INSTALL[int]} cloudflare-warp)
	[[ $SYSTEM != CentOS ]] && ${PACKAGE_UPDATE[int]} && ${PACKAGE_INSTALL[int]} lsb-release
	[[ $SYSTEM = Debian && ! $(type -P gpg 2>/dev/null) ]] && ${PACKAGE_INSTALL[int]} gnupg
	[[ $SYSTEM = Debian && ! $(apt list 2>/dev/null | grep apt-transport-https ) =~ installed ]] && ${PACKAGE_INSTALL[int]} apt-transport-https
	[[ $SYSTEM != CentOS ]] && (curl https://pkg.cloudflareclient.com/pubkey.gpg | apt-key add -
	echo "deb http://pkg.cloudflareclient.com/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/cloudflare-client.list
	${PACKAGE_UPDATE[int]}; ${PACKAGE_INSTALL[int]} cloudflare-warp)
	settings

	elif [[ $CLIENT = 2 && $(warp-cli --accept-tos status 2>/dev/null) =~ 'Registration missing' ]]; then
	settings

	else
	red " ${T[${L}85]} " 
	fi

	# 创建再次执行的软链接快捷方式，再次运行可以用 warp 指令,设置默认语言
	mv -f menu.sh /etc/wireguard >/dev/null 2>&1
	chmod +x /etc/wireguard/menu.sh >/dev/null 2>&1
	ln -sf /etc/wireguard/menu.sh /usr/bin/warp && green " ${T[${L}38]} "
	echo "$L" >/etc/wireguard/language
	
	# 结果提示，脚本运行时间，次数统计
	proxy_info
	end=$(date +%s)
	[[ $ACCOUNT =~ Free ]] && green " $(eval echo "${T[${L}94]}")\n $(eval echo "${T[${L}99]}") "
	[[ $ACCOUNT =~ Limited ]] && green " $(eval echo "${T[${L}94]}")\n $(eval echo "${T[${L}99]}")\n ${T[${L}63]}：$QUOTA "
	red "\n==============================================================\n"
	yellow " ${T[${L}43]}\n " && help
	}

# 免费 WARP 账户升级 WARP+ 账户
update(){
	wgcf_account(){
	[[ $TRACE4 = plus || $TRACE6 = plus ]] && red " ${T[${L}58]} " && exit 1
	[[ ! -e /etc/wireguard/wgcf-account.toml ]] && red " ${T[${L}59]} " && exit 1
	[[ ! -e /etc/wireguard/wgcf.conf ]] && red " ${T[${L}60]} " && exit 1
	
	[[ -z $LICENSETYPE ]] && yellow " ${T[${L}31]}" && reading " ${T[${L}50]} " LICENSETYPE
	case $LICENSETYPE in
	1 ) UPDATE_LICENSE=1 && update_license
	cd /etc/wireguard || exit
	sed -i "s#license_key.*#license_key = \"$LICENSE\"#g" wgcf-account.toml &&
	wgcf update --name "$NAME" > /etc/wireguard/info.log 2>&1 &&
	(wgcf generate >/dev/null 2>&1
	sed -i "2s#.*#$(sed -ne 2p wgcf-profile.conf)#;3s#.*#$(sed -ne 3p wgcf-profile.conf)#;4s#.*#$(sed -ne 4p wgcf-profile.conf)#" wgcf.conf
	wg-quick down wgcf >/dev/null 2>&1
	net
	[[ $(curl -s4 https://www.cloudflare.com/cdn-cgi/trace | grep warp | sed "s/warp=//g") = plus || $(curl -s6 https://www.cloudflare.com/cdn-cgi/trace | grep warp | sed "s/warp=//g") = plus ]] &&
	green " ${T[${L}62]}\n ${T[${L}25]}：$(grep 'Device name' /etc/wireguard/info.log | awk '{ print $NF }')\n ${T[${L}63]}：$(grep Quota /etc/wireguard/info.log | awk '{ print $(NF-1), $NF }')" ) || red " ${T[${L}36]} ";;
	
	2 ) input_url
	[[ $CONFIRM = [Yy] ]] && (echo "$TEAMS" > /etc/wireguard/info.log 2>&1
	teams_change
	wg-quick down wgcf >/dev/null 2>&1; net
	[[ $(curl -s4 https://www.cloudflare.com/cdn-cgi/trace | grep warp | sed "s/warp=//g") = plus || $(curl -s6 https://www.cloudflare.com/cdn-cgi/trace | grep warp | sed "s/warp=//g") = plus ]] && green " ${T[${L}128]} ");;

	* ) red " ${T[${L}51]} [1-2] "; sleep 1; update
	esac
	}
	
	client_account(){
	[[ $ARCHITECTURE = arm64 ]] && red " ${T[${L}101]} " && exit 1
	[[ $(warp-cli --accept-tos account) =~ Limited ]] && red " ${T[${L}97]} " && exit 1
	update_license
	warp-cli --accept-tos set-license "$LICENSE" >/dev/null 2>&1; sleep 1
	ACCOUNT=$(warp-cli --accept-tos account 2>/dev/null)
	if [[ $ACCOUNT =~ 'Limited' ]]; then
	echo "$LICENSE" >/etc/wireguard/license
	QUOTA=$(expr "$ACCOUNT" : '.*Quota:\s\([0-9]\{1,\}\)\s.*')
	[[ $QUOTA -gt 10000000000000 ]] && QUOTA="$((QUOTA/1000000000000)) TB" ||  QUOTA="$((QUOTA/1000000000)) GB"
	green " ${T[${L}62]}\n ${T[${L}63]}：$QUOTA "
	
	else red " ${T[${L}36]} "
	fi
	}

	# 根据 WARP interface 和 Client 的安装情况判断升级的对象
	[[ $(type -P wg-quick) ]] && WGCFINSTALL=1 || WGCFINSTALL=0
	[[ $(type -P warp-cli) ]] && SOCK5INSTALL=1 || SOCK5INSTALL=0
	case $WGCFINSTALL$SOCK5INSTALL in
	01 ) client_account; exit 0;;
	10 ) wgcf_account; exit 0;;
	11 ) yellow " ${T[${L}98]} " && reading " ${T[${L}50]} " MODE
		case "$MODE" in
		1 ) wgcf_account; exit 0;;
		2 ) client_account; exit 0;;
		* ) red " ${T[${L}51]} [1-2] "; sleep 1; update;;
		esac;;
	esac
}

# 显示菜单
menu(){
	if [[ $1 != 3 ]]; then
		case $IPV4$IPV6 in
		01 ) OPTION1=${T[${L}66]} && OPTION2=${T[${L}68]} && OPTION3=${T[${L}71]};;
		10 ) OPTION1=${T[${L}67]} && OPTION2=${T[${L}69]} && OPTION3=${T[${L}71]};;
		11 ) OPTION1=${T[${L}70]} && OPTION2=${T[${L}34]} && OPTION3=${T[${L}71]};;	
	esac
	else	OPTION1=${T[${L}77]} && OPTION2=${T[${L}78]} && OPTION3=${T[${L}123]}
	fi
	
	case $CLIENT in
	2 )	OPTION4=${T[${L}88]};; 3 ) OPTION4=${T[${L}89]};; * ) OPTION4=${T[${L}82]};;
	esac
	
	grep -sq 'Device name' /etc/wireguard/info.log 2>/dev/null && TYPE='+' && PLUSINFO="${T[${L}25]}：$(grep 'Device name' /etc/wireguard/info.log 2>/dev/null | awk '{ print $NF }')" || TYPE=' Teams'
	
	clear
	yellow " ${T[${L}16]} "
	red "======================================================================================================================\n"
	green " ${T[${L}17]}：$VERSION  ${T[${L}18]}：${T[${L}1]}\n ${T[${L}19]}：\n	${T[${L}20]}：$SYS\n	${T[${L}21]}：$(uname -r)\n	${T[${L}22]}：$ARCHITECTURE\n	${T[${L}23]}：$VIRT "
	green "	IPv4：$WAN4 $WARPSTATUS4 $COUNTRY4  $ASNORG4 "
	green "	IPv6：$WAN6 $WARPSTATUS6 $COUNTRY6  $ASNORG6 "
	[[ $TRACE4 = plus || $TRACE6 = plus ]] && green "	$(eval echo "${T[${L}114]}")	$PLUSINFO "
	[[ $TRACE4 = on || $TRACE6 = on ]] && green "	${T[${L}115]} " 	
	[[ $PLAN != 3 ]] && green "	${T[${L}116]} "
	[[ $CLIENT = 0 ]] && green "	${T[${L}112]} "
	[[ $CLIENT = 2 ]] && green "	${T[${L}113]} "
	[[ $CLIENT = 3 ]] && green "	WARP$AC ${T[${L}24]}	$(eval echo "${T[${L}27]}") "
 	red "\n======================================================================================================================\n"
	green " 1. $OPTION1\n 2. $OPTION2\n 3. $OPTION3\n 4. $OPTION4\n 5. ${T[${L}72]}\n 6. ${T[${L}73]}\n 7. ${T[${L}74]}\n 8. ${T[${L}75]}\n 0. ${T[${L}76]}\n "
	reading " ${T[${L}50]} " CHOOSE1
		case "$CHOOSE1" in
		1 )	[[ $OPTION1 = ${T[${L}66]} || $OPTION1 = ${T[${L}67]} ]] && MODIFY=$(eval echo \$MODIFYS$IPV4$IPV6) && install
			[[ $OPTION1 = ${T[${L}70]} ]] && MODIFY=$(eval echo \$MODIFYD$IPV4$IPV6) && install
			[[ $OPTION1 = ${T[${L}77]} ]] && onoff;;
		2 )	[[ $OPTION2 = ${T[${L}68]} || $OPTION2 = ${T[${L}69]} || $OPTION2 = ${T[${L}34]} ]] && MODIFY=$(eval echo \$MODIFYD$IPV4$IPV6) && install
			[[ $OPTION2 = ${T[${L}78]} ]] && update;;
		3 )	[[ $OPTION3 = ${T[${L}71]} ]] && OPTION=o && net
			[[ $OPTION3 = ${T[${L}123]} ]] && change_ip;;
		4 )	[[ $CLIENT = 2 || $CLIENT = 3 ]] && proxy_onoff || proxy;;
		5 )	uninstall;;
		6 )	bbrInstall;;
		7 )	plus;;
		8 )	ver;;
		0 )	exit;;
		* )	red " ${T[${L}51]} [0-8] "; sleep 1; [[ $CLIENT -gt 2 ]] && menu 3 || menu $PLAN;;
		esac
	}

# 设置部分后缀 3/3
case "$OPTION" in
1 )	# 先判断是否运行 WARP,再按 Client 运行情况分别处理。在已运行 Linux Client 前提下，对于 IPv4 only 只能添加 IPv6 单栈，对于原生双栈不能安装，IPv6 因不能安装 Linux Client 而不用作限制
	if [[ $PLAN = 3 ]]; then
		yellow " ${T[${L}80]} " && wg-quick down wgcf >/dev/null 2>&1 && exit 1
	elif [[ $CLIENT = 3 ]]; then
		[[ $IPV4$IPV6 = 10 ]] && MODIFY=$MODIFYS10
		[[ $IPV4$IPV6 = 11 ]] && red " ${T[${L}110]} " && exit 1
	else [[ $PLAN = 2 ]] && reading " ${T[${L}79]} " DUAL && [[ $DUAL != [Yy] ]] && exit 1 || MODIFY=$(eval echo \$MODIFYD$IPV4$IPV6)
		[[ $PLAN = 1 ]] && MODIFY=$(eval echo \$MODIFYS$IPV4$IPV6)
	fi
	install;;
2 )	# 先判断是否运行 WARP,再按 Client 运行情况分别处理。在已运行 Linux Client 前提下，对于 IPv4 only 只能添加 IPv6 单栈，对于原生双栈不能安装，IPv6 因不能安装 Linux Client 而不用作限制
	if [[ $PLAN = 3 ]]; then
		yellow " ${T[${L}80]} " && wg-quick down wgcf >/dev/null 2>&1 && exit 1
	elif [[ $CLIENT = 3 ]]; then
		[[ $IPV4$IPV6 = 10 ]] && reading " ${T[${L}109]} " SINGLE && [[ $SINGLE != [Yy] ]] && exit 1 || MODIFY=$MODIFYS10
		[[ $IPV4$IPV6 = 11 ]] && red " ${T[${L}110]} " && exit 1
	else MODIFY=$(eval echo \$MODIFYD$IPV4$IPV6)
	fi
	install;;

c )	[[ $CLIENT = 3 ]] && red " ${T[${L}92]} " && exit 1 || proxy;;
d )	update;;
* )	[[ $CLIENT -gt 2 ]] && menu 3 || menu "$PLAN";;
esac
