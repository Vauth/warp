#!/bin/bash
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/root/bin:/sbin:/bin
export LANG=en_US.UTF-8

# 当前脚本版本号和新增功能
VERSION=2.37

declare -A T

T[E0]="\n Language:\n  1.English (default) \n  2.简体中文\n"
T[C0]="${T[E0]}"
T[E1]="1. First publication on a global scale: After WirePorxy, another major technological breakthrough -- WARP-Cli's WARP mode solution. Thanks to the original creator -- Teacher LUBAN. It solves two major pain points: 1) The instability of the traditional proxy model; 2) Currently HK does not have a WARP service; "
T[C1]="1. 全网首发: 继 WirePorxy 之后，又一重大技术突破，WARP-Cli 的 WARP 模式方案，感谢原创者 LUBAN 老师，引用大神的思路，解决两大痛点: 1) 传统 proxy 模式的断流和慢; 2) 解决 HK 没有 WARP 服务;"
T[E2]="The script must be run as root, you can enter sudo -i and then download and run again. Feedback: [https://github.com/fscarmen/warp/issues]"
T[C2]="必须以root方式运行脚本，可以输入 sudo -i 后重新下载运行，问题反馈:[https://github.com/fscarmen/warp/issues]"
T[E3]="The TUN module is not loaded. You should turn it on in the control panel. Ask the supplier for more help. Feedback: [https://github.com/fscarmen/warp/issues]"
T[C3]="没有加载 TUN 模块，请在管理后台开启或联系供应商了解如何开启，问题反馈:[https://github.com/fscarmen/warp/issues]"
T[E4]="The WARP server cannot be connected. It may be a China Mainland VPS. You can manually ping 162.159.193.10 or ping6 2606:4700:d0::a29f:c001.You can run the script again if the connect is successful. Feedback: [https://github.com/fscarmen/warp/issues]"
T[C4]="与 WARP 的服务器不能连接,可能是大陆 VPS，可手动 ping 162.159.193.10 或 ping6 2606:4700:d0::a29f:c001，如能连通可再次运行脚本，问题反馈:[https://github.com/fscarmen/warp/issues]"
T[E5]="The script supports Debian, Ubuntu, CentOS or Alpine systems only. Feedback: [https://github.com/fscarmen/warp/issues]"
T[C5]="本脚本只支持 Debian、Ubuntu、CentOS 或 Alpine 系统,问题反馈:[https://github.com/fscarmen/warp/issues]"
T[E6]="warp h (help)\n warp o (Turn off WARP temporarily)\n warp u (Turn off and uninstall WARP interface and Socks5 Linux Client)\n warp b (Upgrade kernel, turn on BBR, change Linux system)\n warp a (Upgrade to WARP+ account)\n warp p (Getting WARP+ quota by scripts)\n warp v (Sync the latest version)\n warp r (Connect/Disconnect WARP Linux Client)\n warp 4/6 (Add WARP IPv4/IPv6 interface)\n warp d (Add WARP dualstack interface IPv4 + IPv6)\n warp c (Install WARP Linux Client and set to proxy mode)\n warp l (Install WARP Linux Client and set to WARP mode)\n warp i (Change the WARP IP to support Netflix)\n warp s (WARP single and dual stacks switch echo other. Such as [warp s 4],[warp s 6],[warp s d])\n warp e (Install Iptables + dnsmasq + ipset solution)\n warp w (Install WireProxy solution)\n warp y (Connect/Disconnect WireProxy socks5)\n"
T[C6]="warp h (帮助菜单）\n warp o (临时warp开关)\n warp u (卸载 WARP 网络接口和 Socks5 Client)\n warp b (升级内核、开启BBR及DD)\n warp a (免费 WARP 账户升级 WARP+)\n warp p (刷WARP+流量)\n warp v (同步脚本至最新版本)\n warp r (WARP Linux Client 开关)\n warp 4/6 (WARP IPv4/IPv6 单栈)\n warp d (WARP 双栈)\n warp c (安装 WARP Linux Client，开启 Socks5 代理模式)\n warp l (安装 WARP Linux Client，开启 WARP 模式)\n warp i (更换支持 Netflix 的IP)\n warp s [OPTION](WARP 单双栈相互切换，如 [warp s 4]、[warp s 6]、[warp s d])\n warp e (安装 Iptables + dnsmasq + ipset 解决方案)\n warp w (安装 WireProxy 解决方案)\n warp y (WireProxy socks5 开关)\n"
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
T[E16]="The script specifically adds WARP network interface for VPS, detailed:[https://github.com/fscarmen/warp]\n Features:\n	* Support WARP+ account. Third-party scripts are use to increase WARP+ quota or upgrade kernel.\n	* Not only menus, but commands with option.\n	* Intelligent analysis of operating system：Ubuntu 16.04、18.04、20.04，Debian 9、10、11，CentOS 7、8, Alpine, Arch Linux 3. Be sure to choose the LTS system. And architecture：AMD or ARM\n	* Automatically select four WireGuard solutions. Performance: Kernel with WireGuard integration＞Install kernel module＞wireguard-go\n	* Intelligent analysis of the latest version of the WGCF\n	* Suppert WARP Linux client.\n	* Output WARP status, IP region and asn\n"
T[C16]="本项目专为 VPS 添加 wgcf 网络接口，详细说明：[https://github.com/fscarmen/warp]\n脚本特点:\n	* 支持 WARP+ 账户，附带第三方刷 WARP+ 流量和升级内核 BBR 脚本\n	* 普通用户友好的菜单，进阶者通过后缀选项快速搭建\n	* 智能判断操作系统：Ubuntu 、Debian 、CentOS、 Alpine 和 Arch Linux，请务必选择 LTS 系统；硬件结构类型：AMD 或者 ARM\n	* 结合 Linux 版本和虚拟化方式，自动优选4个 WireGuard 方案。网络性能方面：内核集成 WireGuard＞安装内核模块＞wireguard-go\n	* 智能判断 WGCF 作者 github库的最新版本 （Latest release）\n	* 支持 WARP Linux Socks5 Client\n	* 输出执行结果，提示是否使用 WARP IP ，IP 归属地和线路提供商\n"
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
T[E24]="Client is on"
T[C24]="Client 已开启"
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
T[C30]="License 应为26位字符，请重新输入 WARP+ License，没有可回车继续\(剩余\$i次\):"
T[E31]="\n 1.Update with WARP+ license\n 2.Update with Teams (You need upload the Teams file to a private storage space before. For example: gist.github.com)\n"
T[C31]="\n 1.使用 WARP+ license 升级\n 2.使用 Teams 升级 (你须事前把 Teams 文件上传到私密存储空间，比如：gist.github.com )\n"
T[E32]="Step 1/3: Install dependencies..."
T[C32]="进度 1/3：安装系统依赖……"
T[E33]="Step 2/3: WGCF is ready"
T[C33]="进度 2/3：已安装 WGCF"
T[E34]="Failed to change port. Feedback: [https://github.com/fscarmen/warp/issues]"
T[C34]="更换端口不成功，问题反馈:[https://github.com/fscarmen/warp/issues]"
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
T[E45]="WARP interface, Linux Client and WirePorxy have been completely deleted!"
T[C45]="WARP 网络接口、 Linux Client 和 WirePorxy 已彻底删除!"
T[E46]="Not cleaned up, please reboot and try again."
T[C46]="没有清除干净，请重启(reboot)后尝试再次删除"
T[E47]="Upgrade kernel, turn on BBR, change Linux system by other authors [ylx2016],[https://github.com/ylx2016/Linux-NetSpeed]"
T[C47]="BBR、DD脚本用的[ylx2016]的成熟作品，地址[https://github.com/ylx2016/Linux-NetSpeed]，请熟知"
T[E48]="Run script"
T[C48]="安装脚本"
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
T[E56]="The current Netflix region is \$REGION. Confirm press [y] . If you want another regions, please enter the two-digit region abbreviation. \(such as hk,sg. Default is \$REGION\):"
T[C56]="当前 Netflix 地区是:\$REGION，需要解锁当前地区请按 y , 如需其他地址请输入两位地区简写 \(如 hk ,sg，默认:\$REGION\):"
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
T[E66]="Add WARP IPv4 interface to \${NATIVE[m]} VPS"
T[C66]="为 \${NATIVE[m]} 添加 WARP IPv4 网络接口"
T[E67]="Add WARP IPv6 interface to \${NATIVE[m]} VPS"
T[C67]="为 \${NATIVE[m]} 添加 WARP IPv6 网络接口"
T[E68]="Add WARP dualstack interface to \${NATIVE[m]} VPS"
T[C68]="为 \${NATIVE[m]} 添加 WARP 双栈网络接口"
T[E69]="Native dualstack"
T[C69]="原生双栈"
T[E70]="WARP dualstack"
T[C70]="WARP 双栈"
T[E71]="Turn on WARP"
T[C71]="打开 WARP"
T[E72]="Turn off, uninstall WARP interface, Linux Client and WireProxy"
T[C72]="永久关闭 WARP 网络接口，并删除 WARP、 Linux Client 和 WireProxy"
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
T[E79]="WARP is already running and will switch to single and dual stack mutual switching mode"
T[C79]="WARP 已经运行，将改为单双栈相互切换模式"
T[E80]="Professional one-click script for WARP to unblock streaming media (Supports multi-platform, multi-mode and TG push)"
T[C80]="WARP 解锁 Netflix 等流媒体专业一键(支持多平台、多方式和 TG 通知)"
T[E81]="Step 3/3: Searching for the best MTU value is ready."
T[C81]="进度 3/3：寻找 MTU 最优值已完成"
T[E82]="Install CloudFlare Client and set mode to Proxy"
T[C82]="安装 CloudFlare Client 并设置为 Proxy 模式"
T[E83]="Step 1/2: Installing WARP Client..."
T[C83]="进度 1/2： 安装 Client……"
T[E84]="Step 2/2: Setting Client Mode"
T[C84]="进度 2/2： 设置 Client 模式"
T[E85]="Client was installed.\n connect/disconnect by [warp r].\n uninstall by [warp u]"
T[C85]="Linux Client 已安装\n 连接/断开: warp r\n 卸载: warp u"
T[E86]="Client is working. Socks5 proxy listening on: \$(ss -nltp | grep -E 'warp|wireproxy' | grep -oP '127.0*\S+')"
T[C86]="Linux Client 正常运行中。 Socks5 代理监听:\$(ss -nltp | grep -E 'warp|wireproxy' | grep -oP '127.0*\S+')"
T[E87]="Fail to establish Socks5 proxy. Feedback: [https://github.com/fscarmen/warp/issues]"
T[C87]="创建 Socks5 代理失败，问题反馈:[https://github.com/fscarmen/warp/issues]"
T[E88]="Connect the client"
T[C88]="连接 Client"
T[E89]="Disconnect the client"
T[C89]="断开 Client"
T[E90]="Client is connected"
T[C90]="Client 已连接"
T[E91]="Client is disconnected. It could be connect again by [warp r]"
T[C91]="已断开 Client，再次连接可以用 warp r"
T[E92]="(!!! Already installed, do not select.)"
T[C92]="(!!! 已安装，请勿选择)"
T[E93]="Client is not installed."
T[C93]="Client 未安装"
T[E94]="Congratulations! WARP\$AC Linux Client is working. Spend time:\$(( end - start )) seconds.\\\n The script runs on today: \$TODAY. Total:\$TOTAL"
T[C94]="恭喜！WARP\$AC Linux Client 工作中, 总耗时:\$(( end - start ))秒， 脚本当天运行次数:\$TODAY，累计运行次数：\$TOTAL"
T[E95]="Client works with non-WARP IPv4. The script is aborted. Feedback: [https://github.com/fscarmen/warp/issues]"
T[C95]="Client 在非 WARP IPv4 下才能工作正常，脚本中止，问题反馈:[https://github.com/fscarmen/warp/issues]"
T[E96]="Client connecting failure. It may be a CloudFlare IPv4."
T[C96]="Client 连接失败，可能是 CloudFlare IPv4."
T[E97]="It is a WARP+ account already. Update is aborted."
T[C97]="已经是 WARP+ 账户，不需要升级"
T[E98]="Uninstall WirePorxy was complete."
T[C98]="WirePorxy 卸载成功"
T[E99]="WireProxy is connected"
T[C99]="WireProxy 已连接"
T[E100]="License should be 26 characters, please re-enter WARP+ License. Otherwise press Enter to continue. \(\$i times remaining\): "
T[C100]="License 应为26位字符,请重新输入 WARP+ License \(剩余\$i次\): "
T[E101]="Client doesn't support architecture ARM64. The script is aborted. Feedback: [https://github.com/fscarmen/warp/issues]"
T[C101]="Client 不支持 ARM64，问题反馈:[https://github.com/fscarmen/warp/issues]"
T[E102]="Please customize the WARP+ device name (Default is [WARP] if left blank):"
T[C102]="请自定义 WARP+ 设备名 (如果不输入，默认为 [WARP]):"
T[E103]="Port 40000 is in use. Please input another Port\(\$i times remaining\):"
T[C103]="40000 端口占用中，请使用另一端口\(剩余\$i次\):"
T[E104]="Please customize the Client port (It must be 4-5 digits. Default to 40000 if it is blank):"
T[C104]="请自定义 Client 端口号 (必须为4-5位自然数，如果不输入，会默认40000):"
T[E105]="\n Please choose the priority:\n  1.IPv4 (default)\n  2.IPv6\n  3.Use initial settings\n"
T[C105]="\n 请选择优先级别:\n  1.IPv4 (默认)\n  2.IPv6\n  3.使用 VPS 初始设置\n"
T[E106]="IPv6 priority"
T[C106]="IPv6 优先"
T[E107]="IPv4 priority"
T[C107]="IPv4 优先"
T[E108]="\n 1. WARP Linux Client IP\n 2. WGCF WARP IP ( Only IPv6 can be brushed when WGCF and Client exist at the same time )\n"
T[C108]="\n 1. WARP Linux Client IP\n 2. WGCF WARP IP ( WGCF 和 Client 并存时只能刷 IPv6)\n"
T[E109]="Socks5 Proxy Client is working now. WARP IPv4 and dualstack interface could not be switch to. The script is aborted. Feedback: [https://github.com/fscarmen/warp/issues]"
T[C109]="Socks5 代理正在运行中，不能转为 WARP IPv4 或者双栈网络接口，脚本中止，问题反馈:[https://github.com/fscarmen/warp/issues]"
T[E110]="Socks5 Proxy Client is working now. WARP IPv4 and dualstack interface could not be installed. The script is aborted. Feedback: [https://github.com/fscarmen/warp/issues]"
T[C110]="Socks5 代理正在运行中，WARP IPv4 或者双栈网络接口不能安装，脚本中止，问题反馈:[https://github.com/fscarmen/warp/issues]"
T[E111]="Port must be 4-5 digits. Please re-input\(\$i times remaining\):"
T[C111]="端口必须为4-5位自然数，请重新输入\(剩余\$i次\):"
T[E112]="Client is not installed."
T[C112]="Client 未安装"
T[E113]="Client is installed. Mode is \$CLIENT_MODE. Disconnected"
T[C113]="Client 已安装，模式为:\$CLIENT_MODE， 断开状态"
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
T[E122]="Port change to \$PORT succeeded."
T[C122]="端口成功更换至 \$PORT"
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
T[E130]="\\\n Please confirm\\\n Private key\\\t: \$PRIVATEKEY \$MATCH1\\\n Public key\\\t: \$PUBLICKEY \$MATCH2\\\n Address IPv4\\\t: \$ADDRESS4/32 \$MATCH3\\\n Address IPv6\\\t: \$ADDRESS6/128 \$MATCH4\\\n"
T[C130]="\\\n 请确认Teams 信息\\\n Private key\\\t: \$PRIVATEKEY \$MATCH1\\\n Public key\\\t: \$PUBLICKEY \$MATCH2\\\n Address IPv4\\\t: \$ADDRESS4/32 \$MATCH3\\\n Address IPv6\\\t: \$ADDRESS6/128 \$MATCH4\\\n"
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
T[E137]="Cannot find the configuration file: /etc/wireguard/wgcf.conf. You should install WARP first"
T[C137]="找不到配置文件 /etc/wireguard/wgcf.conf，请先安装 WARP"
T[E138]="Install iptable + dnsmasq + ipset. Let WARP only take over the streaming media traffic (Not available for ipv6 only)"
T[C138]="安装 iptable + dnsmasq + ipset，让 WARP IPv4 only 接管流媒体流量 (不适用于 IPv6 only VPS)"
T[E139]="Through Iptable + dnsmasq + ipset, minimize the realization of media unblocking such as Netflix, WARP IPv4 only takes over the streaming media traffic,adapted from the mature works of [Anemone],[https://github.com/acacia233/Project-WARP-Unlock]"
T[C139]="通过 Iptable + dnsmasq + ipset，最小化实现 Netflix 等媒体解锁，WARP IPv4 只接管流媒体流量，改编自 [Anemone] 的成熟作品，地址[https://github.com/acacia233/Project-WARP-Unlock]，请熟知"
T[E140]="Socks5 Proxy Client on IPv4 VPS is working now. WARP IPv6 interface could not be installed. Feedback: [https://github.com/fscarmen/warp/issues]"
T[C140]="IPv4 only VPS，并且 Socks5 代理正在运行中，不能安装 WARP IPv6 网络接口，问题反馈:[https://github.com/fscarmen/warp/issues]"
T[E141]="Switch \${WARP_BEFORE[m]} to \${WARP_AFTER1[m]}"
T[C141]="\${WARP_BEFORE[m]} 转为 \${WARP_AFTER1[m]}"
T[E142]="Switch \${WARP_BEFORE[m]} to \${WARP_AFTER2[m]}"
T[C142]="\${WARP_BEFORE[m]} 转为 \${WARP_AFTER2[m]}"
T[E143]="Change Client or WireProxy port"
T[C143]="更改 Client 或 WireProxy 端口"
T[E144]="Install WARP IPv6 interface"
T[C144]="安装 WARP IPv6 网络接口"
T[E145]="\\\n WARP ineterface can be switched to the following:\\\n 1. \$OPTION1\\\n 2. \$OPTION2\\\n 0. \${T[\${L}76]}\\\n"
T[C145]="\\\n WARP 网络接口可以切换为以下方式:\\\n 1. \$OPTION1\\\n 2. \$OPTION2\\\n 0. \${T[\${L}76]}\\\n"
T[E146]="Cannot switch to the same form as the current one."
T[C146]="不能切换为当前一样的形态"
T[E147]="Not available for IPv6 only VPS"
T[C147]="IPv6 only VPS 不能使用此方案"
T[E148]="Install wireproxy. Wireguard client that exposes itself as a socks5 proxy or tunnels"
T[C148]="安装 wireproxy，让 WARP 在本地创建一个 socks5 代理"
T[E149]="Congratulations! WirePorxy is working. Spend time:\$(( end - start )) seconds.\\\n The script runs on today: \$TODAY. Total:\$TOTAL"
T[C149]="恭喜！WirePorxy 工作中, 总耗时:\$(( end - start ))秒， 脚本当天运行次数:\$TODAY，累计运行次数：\$TOTAL"
T[E150]="\n WGCF WARP, WARP Linux Client, WireProxy hasn't been installed yet. The script is aborted.\n"
T[C150]="\n WGCF WARP, WARP Linux Client 和 WireProxy 均未安装，脚本退出\n"
T[E151]="\n 1. WARP Linux Client account\n 2. WireProxy account\n"
T[C151]="\n 1. WARP Linux Client 账户\n 2. WireProxy 账户\n"
T[E152]="\n 1. WGCF WARP account\n 2. WireProxy account\n"
T[C152]="\n 1. WGCF WARP 账户\n 2. WireProxy 账户\n"
T[E153]="\n 1. WGCF WARP account\n 2. WARP Linux Client account\n"
T[C153]="\n 1. WGCF WARP 账户\n 2. WARP Linux Client 账户\n"
T[E154]="\n 1. WGCF WARP account\n 2. WARP Linux Client account\n 3. WireProxy account\n"
T[C154]="\n 1. WGCF WARP 账户\n 2. WARP Linux Client 账户\n 3. WireProxy 账户\n"
T[E155]="WGCF WARP has not been installed yet."
T[C155]="WGCF WARP 还未安装"
T[E156]=""
T[C156]=""
T[E157]="WireProxy has not been installed yet."
T[C157]="WireProxy 还未安装"
T[E158]="WireProxy is disconnected. It could be connect again by [warp y]"
T[C158]="已断开 WirePorxy，再次连接可以用 warp y"
T[E159]="WireProxy is on"
T[C159]="WireProxy 已开启"
T[E160]="WireProxy is not installed."
T[C160]="WireProxy 未安装"
T[E161]="WireProxy is installed and disconnected"
T[C161]="WireProxy 已安装，状态为断开连接"
T[E162]="Local Socks5:\$PROXYSOCKS52	WARP\$AC2 IPv4:\$PROXYIP2 \$PROXYCOUNTRY2	\$PROXYASNORG2"
T[C162]="本地 Socks5:\$PROXYSOCKS52	WARP\$AC2 IPv4:\$PROXYIP2 \$PROXYCOUNTRY2	\$PROXYASNORG2"
T[E163]="Connect the WirePorxy"
T[C163]="连接 WirePorxy"
T[E164]="Disconnect the WirePorxy"
T[C164]="断开 WirePorxy"
T[E165]="WireProxy Solution. A wireguard client that exposes itself as a socks5 proxy or tunnels. Adapted from the mature works of [octeep],[https://github.com/octeep/wireproxy]"
T[C165]="WireProxy，让 WARP 在本地建议一个 socks5 代理。改编自 [octeep] 的成熟作品，地址[https://github.com/octeep/wireproxy]，请熟知"
T[E166]="WireProxy was installed.\n connect/disconnect by [warp y]\n uninstall by [warp u]"
T[C166]="WireProxy 已安装\n 连接/断开: warp y\n 卸载: warp u"
T[E167]="WARP iptable was installed.\n connect/disconnect by [warp o]\n uninstall by [warp u]"
T[C167]="WARP iptable 已安装\n 连接/断开: warp o\n 卸载: warp u"
T[E168]="Install CloudFlare Client and set mode to WARP"
T[C168]="安装 CloudFlare Client 并设置为 WARP 模式"
T[E169]="WARP\$AC IPv4：\$WAN4 \$WARPSTATUS4 \$COUNTRY4  \$ASNORG4"
T[C169]="WARP\$AC IPv4：\$WAN4 \$WARPSTATUS4 \$COUNTRY4  \$ASNORG4"

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
	* ) L=E && [[ -z $OPTION || $OPTION = [aclehdpbvisw46] ]] && yellow " ${T[${L}0]} " && reading " ${T[${L}50]} " LANGUAGE 
	[[ $LANGUAGE = 2 ]] && L=C;;
	esac
	}

# 必须以root运行脚本
check_root_virt(){
	[[ $(id -u) != 0 ]] && red " ${T[${L}2]} " && exit 1
	
	# 判断虚拟化，选择 Wireguard内核模块 还是 Wireguard-Go
	VIRT=$(systemd-detect-virt 2>/dev/null | tr '[:upper:]' '[:lower:]')
	[[ -n $VIRT ]] || VIRT=$(hostnamectl 2>/dev/null | tr '[:upper:]' '[:lower:]' | grep virtualization | sed "s/.*://g")
	[[ $VIRT =~ openvz|lxc || -z $VIRT ]] && LXC=1
	}

# 多方式判断操作系统，试到有值为止。只支持 Debian 10/11、Ubuntu 18.04/20.04 或 CentOS 7/8 ,如非上述操作系统，退出脚本
# 感谢猫大的技术指导优化重复的命令。https://github.com/Oreomeow
check_operating_system(){
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

	REGEX=("debian" "ubuntu" "centos|red hat|kernel|oracle linux|alma|rocky" "'amazon linux'" "alpine" "arch linux")
	RELEASE=("Debian" "Ubuntu" "CentOS" "CentOS" "Alpine" "Arch")
	EXCLUDE=("bookworm")
	COMPANY=("" "" "" "amazon" "" "")
	MAJOR=("9" "16" "7" "7" "3" "")
	PACKAGE_UPDATE=("apt -y update" "apt -y update" "yum -y update" "yum -y update" "apk update -f" "pacman -Sy")
	PACKAGE_INSTALL=("apt -y install" "apt -y install" "yum -y install" "yum -y install" "apk add -f" "pacman -S --noconfirm")
	PACKAGE_UNINSTALL=("apt -y autoremove" "apt -y autoremove" "yum -y autoremove" "yum -y autoremove" "apk del -f" "pacman -Rcnsu --noconfirm")
	SYSTEMCTL_START=("systemctl start wg-quick@wgcf" "systemctl start wg-quick@wgcf" "systemctl start wg-quick@wgcf" "systemctl start wg-quick@wgcf" "wg-quick up wgcf" "systemctl start wg-quick@wgcf")
	SYSTEMCTL_RESTART=("systemctl restart wg-quick@wgcf" "systemctl restart wg-quick@wgcf" "systemctl restart wg-quick@wgcf" "systemctl restart wg-quick@wgcf" "alpine_wgcf_restart" "systemctl restart wg-quick@wgcf")
	SYSTEMCTL_ENABLE=("systemctl enable --now wg-quick@wgcf" "systemctl enable --now wg-quick@wgcf" "systemctl enable --now wg-quick@wgcf" "systemctl enable --now wg-quick@wgcf" "alpine_wgcf_enable" "systemctl enable --now wg-quick@wgcf")

	for ((int=0; int<${#REGEX[@]}; int++)); do
		[[ $(echo "$SYS" | tr '[:upper:]' '[:lower:]') =~ ${REGEX[int]} ]] && SYSTEM="${RELEASE[int]}" && COMPANY="${COMPANY[int]}" && [[ -n $SYSTEM ]] && break
	done
	[[ -z $SYSTEM ]] && red " ${T[${L}5]} " && exit 1

	# 先排除 EXCLUDE 里包括的特定系统，其他系统需要作大发行版本的比较
	for ex in "${EXCLUDE[@]}"; do [[ ! $(echo "$SYS" | tr '[:upper:]' '[:lower:]')  =~ $ex ]]; done &&
	[[ $(echo $SYS | sed "s/[^0-9.]//g" | cut -d. -f1) -lt "${MAJOR[int]}" ]] && red " $(eval echo "${T[${L}26]}") " && exit 1
	}

# 安装 curl
check_dependencies(){
	type -P curl >/dev/null 2>&1 || (yellow " ${T[${L}7]} " && ${PACKAGE_INSTALL[int]} curl) || (yellow " ${T[${L}8]} " && ${PACKAGE_UPDATE[int]} && ${PACKAGE_INSTALL[int]} curl)
	! type -P curl >/dev/null 2>&1 && yellow " ${T[${L}9]} " && exit 1
	[[ $SYSTEM = Alpine ]] && ! type -P curl >/dev/null 2>&1 && ${PACKAGE_UPDATE[int]} && ${PACKAGE_INSTALL[int]} curl wget grep
	}

# 检测 IPv4 IPv6 信息，WARP Ineterface 开启，普通还是 Plus账户 和 IP 信息
ip4_info(){
	unset IP4 LAN4 COUNTRY4 ASNORG4 TRACE4 PLUS4 WARPSTATUS4
	IP4=$(curl -ks4m8 https://ip.gs/json $INTERFACE)
	LAN4=$(ip route get 162.159.193.10 2>/dev/null | grep -oP 'src \K\S+')
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
	LAN6=$(ip route get 2606:4700:d0::a29f:c001 2>/dev/null | grep -oP 'src \K\S+')
	WAN6=$(expr "$IP6" : '.*ip\":\"\([^"]*\).*')
	COUNTRY6=$(expr "$IP6" : '.*country\":\"\([^"]*\).*')
	ASNORG6=$(expr "$IP6" : '.*asn_org\":\"\([^"]*\).*')
	TRACE6=$(curl -ks6m8 https://www.cloudflare.com/cdn-cgi/trace | grep warp | sed "s/warp=//g")
	if [[ $TRACE6 = plus ]]; then
		grep -sq 'Device name' /etc/wireguard/info.log && PLUS6='+' || PLUS6=' Teams'
	fi
	[[ $TRACE6 =~ on|plus ]] && WARPSTATUS6="( WARP$PLUS6 IPv6 )"
	}

# 检测 Client 是否开启，普通还是 Plus账户 和 IP 信息
proxy_info(){
	unset PROXYSOCKS5 PROXYPORT PROXYJASON PROXYIP PROXYCOUNTR PROXYASNORG ACCOUNT QUOTA AC PROXYSOCKS52 PROXYPORT2 PROXYJASON2 PROXYIP2 PROXYCOUNTR2 PROXYASNORG2 ACCOUNT2 AC2 TRACE42

	if type -P warp-cli >/dev/null 2>&1; then
	PROXYSOCKS5=$(ss -nltp | grep 'warp' | grep -oP '127.0*\S+')
	PROXYPORT=$(echo $PROXYSOCKS5 | cut -d: -f2)
	PROXYJASON=$(curl -sx socks5h://localhost:$PROXYPORT https://ip.gs/json)
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
	fi

	if type -P wireproxy >/dev/null 2>&1; then
	PROXYSOCKS52=$(ss -nltp | grep 'wireproxy' | grep -oP '127.0*\S+')
	PROXYPORT2=$(echo $PROXYSOCKS52 | cut -d: -f2)
	PROXYJASON2=$(curl -sx socks5h://localhost:$PROXYPORT2 https://ip.gs/json)
	PROXYIP2=$(expr "$PROXYJASON2" : '.*ip\":\"\([^"]*\).*')
	PROXYCOUNTRY2=$(expr "$PROXYJASON2" : '.*country\":\"\([^"]*\).*')
	[[ $L = C ]] && PROXYCOUNTRY2=$(translate "$PROXYCOUNTRY2")
	PROXYASNORG2=$(expr "$PROXYJASON2" : '.*asn_org\":\"\([^"]*\).*')
	TRACE42=$(eval echo "\$(curl -sx socks5h://localhost:$(ss -nltp | grep wireproxy | grep -oP '127.0*\S+' | cut -d: -f2) https://www.cloudflare.com/cdn-cgi/trace)")
		if [[ $TRACE42 =~ plus ]]; then
			grep -sq 'Device name' /etc/wireguard/info.log && AC2='+' || AC2=' Teams'
		fi
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
	[[ $OPTION != p ]] && green " 4.${T[${L}49]} " || green " 4.${T[${L}76]} "
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
		4 ) [[ $OPTION != p ]] && menu || exit;;
		* ) red " ${T[${L}51]} [1-4] "; sleep 1; plus;;
	esac
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

# 更换 Netflix IP 时确认期望区域
input_region(){
	[[ -n "$NF" ]] && REGION=$(tr '[:lower:]' '[:upper:]' <<< $(curl --user-agent "${UA_Browser}" -$NF -fs --max-time 10 --write-out %{redirect_url} --output /dev/null "https://www.netflix.com/title/$REGION_TITLE" | sed 's/.*com\/\([^-/]\{1,\}\).*/\1/g')) ||
	[[ -n "$PROXYPORT" ]] && REGION=$(tr '[:lower:]' '[:upper:]' <<< $(curl --user-agent "${UA_Browser}" -sx socks5h://localhost:$PROXYPORT -fs --max-time 10 --write-out %{redirect_url} --output /dev/null "https://www.netflix.com/title/$REGION_TITLE" | sed 's/.*com\/\([^-/]\{1,\}\).*/\1/g'))
	[[ -n "$INTERFACE" ]] && REGION=$(tr '[:lower:]' '[:upper:]' <<< $(curl --user-agent "${UA_Browser}" $INTERFACE -fs --max-time 10 --write-out %{redirect_url} --output /dev/null "https://www.netflix.com/title/$REGION_TITLE" | sed 's/.*com\/\([^-/]\{1,\}\).*/\1/g'))
	REGION=${REGION:-'US'}
	reading " $(eval echo "${T[${L}56]}") " EXPECT
	until [[ -z $EXPECT || $EXPECT = [Yy] || $EXPECT =~ ^[A-Za-z]{2}$ ]]; do
		reading " $(eval echo "${T[${L}56]}") " EXPECT
	done
	[[ -z $EXPECT || $EXPECT = [Yy] ]] && EXPECT="$REGION"
	}

# 更换支持 Netflix WARP IP 改编自 [luoxue-bot] 的成熟作品，地址[https://github.com/luoxue-bot/warp_auto_change_ip]
change_ip(){
	change_wgcf(){
		wgcf_restart(){ red " $(eval echo "${T[${L}126]}") " && ${SYSTEMCTL_RESTART[int]}; ss -nltp | grep dnsmasq >/dev/null 2>&1 && systemctl restart dnsmasq >/dev/null 2>&1; sleep $j; }
		unset T4 T6
		grep -q "^#.*0\.\0\/0" /etc/wireguard/wgcf.conf && T4=0 || T4=1
		grep -q "^#.*\:\:\/0" /etc/wireguard/wgcf.conf && T6=0 || T6=1
		case "$T4$T6" in
			01 ) NF='6';;	10 ) NF='4';;
			11 ) [[ $(curl -ksm8 https://ip.gs) =~ ":" ]] && NF='6' && reading " ${T[${L}124]} " NETFLIX || NF='4'
			[[ $NETFLIX = [Yy] ]] && NF='4' && PRIORITY=1 && stack_priority;;
		esac

		[[ -z "$EXPECT" ]] && input_region
		i=0; j=5
		while true
		do (( i++ )) || true
		ip_now=$(date +%s); RUNTIME=$((ip_now - ip_start)); DAY=$(( RUNTIME / 86400 )); HOUR=$(( (RUNTIME % 86400 ) / 3600 )); MIN=$(( (RUNTIME % 86400 % 3600) / 60 )); SEC=$(( RUNTIME % 86400 % 3600 % 60 ))
		ip${NF}_info
		WAN=$(eval echo \$WAN$NF) && ASNORG=$(eval echo \$ASNORG$NF)
		[[ $L = C ]] && COUNTRY=$(translate "$(eval echo \$COUNTRY$NF)") || COUNTRY=$(eval echo \$COUNTRY$NF)
		RESULT=$(curl --user-agent "${UA_Browser}" -$NF -fsL --write-out %{http_code} --output /dev/null --max-time 10 "https://www.netflix.com/title/$RESULT_TITLE"  2>&1)
		if [[ $RESULT = 200 ]]; then
		REGION=$(tr '[:lower:]' '[:upper:]' <<< $(curl --user-agent "${UA_Browser}" -"$NF" -fs --max-time 10 --write-out %{redirect_url} --output /dev/null "https://www.netflix.com/title/$REGION_TITLE" | sed 's/.*com\/\([^-/]\{1,\}\).*/\1/g'))
		REGION=${REGION:-'US'}
		echo "$REGION" | grep -qi "$EXPECT" && green " $(eval echo "${T[${L}125]}") " && i=0 && sleep 1h || wgcf_restart
		else wgcf_restart
		fi
		done
		}

	change_client(){
		client_restart(){
			[[ $(warp-cli --accept-tos settings) =~ WarpProxy ]] && CLIENT_PROXY=1
			red " $(eval echo "${T[${L}126]}") " && warp-cli --accept-tos delete >/dev/null 2>&1
			[[ $CLIENT_PROXY != 1 ]] && ( ip -4 rule delete from 172.16.0.2/32 lookup 51820; ip -4 rule delete table main suppress_prefixlength 0 )
			warp-cli --accept-tos register >/dev/null 2>&1 &&
			[[ -e /etc/wireguard/license ]] && warp-cli --accept-tos set-license $(cat /etc/wireguard/license) >/dev/null 2>&1
			sleep $j
			[[ $CLIENT_PROXY != 1 ]] && ( ip -4 rule add from 172.16.0.2 lookup 51820; ip -4 route add default dev CloudflareWARP table 51820; ip -4 rule add table main suppress_prefixlength 0 )
			}

		if [[ $(warp-cli --accept-tos settings) =~ WarpProxy ]]; then
			PROXYPORT="$(ss -nltp | grep 'warp' | grep -oP '127.0*\S+' | cut -d: -f2)"
			[[ -z "$EXPECT" ]] && input_region
			i=0; j=10
			while true
			do (( i++ )) || true
			ip_now=$(date +%s); RUNTIME=$((ip_now - ip_start)); DAY=$(( RUNTIME / 86400 )); HOUR=$(( (RUNTIME % 86400 ) / 3600 )); MIN=$(( (RUNTIME % 86400 % 3600) / 60 )); SEC=$(( RUNTIME % 86400 % 3600 % 60 ))
			proxy_info
			WAN=$PROXYIP && ASNORG=$PROXYASNORG && NF=4 && COUNTRY=$PROXYCOUNTRY
			RESULT=$(curl --user-agent "${UA_Browser}" -sx socks5h://localhost:$PROXYPORT -fsL --write-out %{http_code} --output /dev/null --max-time 10 "https://www.netflix.com/title/$RESULT_TITLE"  2>&1)
			if [[ $RESULT = 200 ]]; then
				REGION=$(tr '[:lower:]' '[:upper:]' <<< $(curl --user-agent "${UA_Browser}" -sx socks5h://localhost:$PROXYPORT -fs --max-time 10 --write-out %{redirect_url} --output /dev/null "https://www.netflix.com/title/$REGION_TITLE" | sed 's/.*com\/\([^-/]\{1,\}\).*/\1/g'))
				REGION=${REGION:-'US'}
				echo "$REGION" | grep -qi "$EXPECT" && green " $(eval echo "${T[${L}125]}") " && i=0 && sleep 1h || client_restart
			else client_restart
			fi
			done

		else	INTERFACE='--interface CloudflareWARP'
			[[ -z "$EXPECT" ]] && input_region
			i=0; j=10
			while true
			do (( i++ )) || true
			ip_now=$(date +%s); RUNTIME=$((ip_now - ip_start)); DAY=$(( RUNTIME / 86400 )); HOUR=$(( (RUNTIME % 86400 ) / 3600 )); MIN=$(( (RUNTIME % 86400 % 3600) / 60 )); SEC=$(( RUNTIME % 86400 % 3600 % 60 ))
			ip4_info
			WAN=$WAN4 && ASNORG=$ASNORG4 && NF=4
			[[ $L = C ]] && COUNTRY=$(translate "$COUNTRY4") || COUNTRY=$COUNTRY4
			RESULT=$(curl --user-agent "${UA_Browser}" $INTERFACE -fsL --write-out %{http_code} --output /dev/null --max-time 10 "https://www.netflix.com/title/$RESULT_TITLE"  2>&1)
			if [[ $RESULT = 200 ]]; then
				REGION=$(tr '[:lower:]' '[:upper:]' <<< $(curl --user-agent "${UA_Browser}" $INTERFACE -fs --max-time 10 --write-out %{redirect_url} --output /dev/null "https://www.netflix.com/title/$REGION_TITLE" | sed 's/.*com\/\([^-/]\{1,\}\).*/\1/g'))
				REGION=${REGION:-'US'}
				echo "$REGION" | grep -qi "$EXPECT" && green " $(eval echo "${T[${L}125]}") " && i=0 && sleep 1h || client_restart
			else client_restart
			fi
			done

		fi
		}

	change_wireproxy(){
		wireproxy_restart(){ red " $(eval echo "${T[${L}126]}") " && systemctl restart wireproxy; sleep $j; }

		PROXYPORT="$(ss -nltp | grep 'wireproxy' | grep -oP '127.0*\S+' | cut -d: -f2)"
		[[ -z "$EXPECT" ]] && input_region
		i=0; j=5
		while true
		do (( i++ )) || true
		ip_now=$(date +%s); RUNTIME=$((ip_now - ip_start)); DAY=$(( RUNTIME / 86400 )); HOUR=$(( (RUNTIME % 86400 ) / 3600 )); MIN=$(( (RUNTIME % 86400 % 3600) / 60 )); SEC=$(( RUNTIME % 86400 % 3600 % 60 ))
		proxy_info
		WAN=$PROXYIP2 && ASNORG=$PROXYASNORG2 && COUNTRY=$PROXYCOUNTRY2
		RESULT=$(curl --user-agent "${UA_Browser}" -sx socks5h://localhost:$PROXYPORT -fsL --write-out %{http_code} --output /dev/null --max-time 10 "https://www.netflix.com/title/$RESULT_TITLE"  2>&1)
		if [[ $RESULT = 200 ]]; then
			REGION=$(tr '[:lower:]' '[:upper:]' <<< $(curl --user-agent "${UA_Browser}" -sx socks5h://localhost:$PROXYPORT -fs --max-time 10 --write-out %{redirect_url} --output /dev/null "https://www.netflix.com/title/$REGION_TITLE" | sed 's/.*com\/\([^-/]\{1,\}\).*/\1/g'))
			REGION=${REGION:-'US'}
			echo "$REGION" | grep -qi "$EXPECT" && green " $(eval echo "${T[${L}125]}") " && i=0 && sleep 1h || wireproxy_restart
		else wireproxy_restart
		fi
		done
		}

	# 设置时区，让时间戳时间准确，显示脚本运行时长，中文为 GMT+8，英文为 UTC; 设置 UA
	ip_start=$(date +%s)
	[[ $SYSTEM != Alpine ]] && ( [[ $L = C ]] && timedatectl set-timezone Asia/Shanghai || timedatectl set-timezone UTC )
	UA_Browser="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.87 Safari/537.36"
	
	# 根据 lmc999 脚本检测 Netflix Title，如获取不到，使用兜底默认值
	LMC999=$(curl -sSLm4 https://raw.githubusercontent.com/lmc999/RegionRestrictionCheck/main/check.sh)
	RESULT_TITLE=$(echo "$LMC999" | grep "result.*netflix.com/title/" | sed "s/.*title\/\([^\"]*\).*/\1/")
	REGION_TITLE=$(echo "$LMC999" | grep "region.*netflix.com/title/" | sed "s/.*title\/\([^\"]*\).*/\1/")
	RESULT_TITLE=${RESULT_TITLE:-'81215567'}; REGION_TITLE=${REGION_TITLE:-'80018499'}

	# 根据 WARP interface 、 Client 和 WirePorxy 的安装情况判断刷 IP 的方式
	INSTALL_CHECK=("wg-quick" "warp-cli" "wireproxy")
	CASE_RESAULT=("0 0 0"		"0 0 1"			"0 1 0"			"0 1 1"			"1 0 0"			"1 0 1"			"1 1 0"			"1 1 1")
	SHOW_CHOOSE=("${T[${L}150]}"	""			""			"${T[${L}151]}"		""			"${T[${L}152]}"		"${T[${L}153]}"		"${T[${L}154]}")
	CHANGE_IP1=(""			"change_wireproxy"	"change_client"		"change_client"		"change_wgcf"		"change_wgcf"		"change_wgcf"		"change_wgcf")
	CHANGE_IP2=(""			"" 			"" 			"change_wireproxy" 	""			"change_wireproxy" 	"change_client" 	"change_client")
	CHANGE_IP3=(""			"" 			""			""			""			""			""			"change_wireproxy")

	for ((a=0; a<${#INSTALL_CHECK[@]}; a++)); do
		type -P ${INSTALL_CHECK[a]} >/dev/null 2>&1 && INSTALL_RESULT[a]=1 || INSTALL_RESULT[a]=0
	done

	for ((b=0; b<${#CASE_RESAULT[@]}; b++)); do
		[[ ${INSTALL_RESULT[@]} = "${CASE_RESAULT[b]}" ]] && break
	done

	case "$b" in
	0 ) red " ${T[${L}150]} " && exit 1;;
	1|2|4 ) ${CHANGE_IP1[b]};;
	* ) yellow " ${SHOW_CHOOSE[b]} " && reading " ${T[${L}50]} " MODE
		case "$MODE" in
		[1-3] ) $(eval echo "\${CHANGE_IP$MODE[b]}");;
		* ) red " ${T[${L}51]} [1-3] "; sleep 1; change_ip;;
		esac;;
	esac
	}

# 安装BBR
bbrInstall(){
	red "\n=============================================================="
	yellow " ${T[${L}47]}\n "
	green " 1.${T[${L}48]} "
	[[ $OPTION != b ]] && green " 2.${T[${L}49]} " || green " 2.${T[${L}76]} "
	red "=============================================================="
	reading " ${T[${L}50]} " BBR
	case "$BBR" in
		1 ) wget --no-check-certificate -N "https://raw.githubusercontent.com/ylx2016/Linux-NetSpeed/master/tcp.sh" && chmod +x tcp.sh && ./tcp.sh;;
		2 ) [[ $OPTION != b ]] && menu || exit;;
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
	[[ $SYSTEM != "Arch" ]] && ${PACKAGE_UNINSTALL[int]} wireguard-dkms ipset dnsmasq resolvconf 2>/dev/null
	${PACKAGE_UNINSTALL[int]} wireguard-tools openresolv 2>/dev/null
	rpm -e wireguard-tools 2>/dev/null
	[[ $(systemctl is-active systemd-resolved) != active ]] && systemctl enable --now systemd-resolved >/dev/null 2>&1
	rm -rf /usr/bin/wgcf /etc/wireguard /usr/bin/wireguard-go wgcf-account.toml wgcf-profile.conf /usr/bin/warp /etc/dnsmasq.d/warp.conf /usr/bin/wireproxy
	[[ -e /etc/gai.conf ]] && sed -i '/^precedence \:\:ffff\:0\:0/d;/^label 2002\:\:\/16/d' /etc/gai.conf
	[[ -e /usr/bin/tun.sh ]] && rm -f /usr/bin/tun.sh && sed -i '/tun.sh/d' /etc/crontab
	sed -i "/250   warp/d" /etc/iproute2/rt_tables
	}
	
	# 卸载 Linux Client
	uninstall_proxy(){
	warp-cli --accept-tos disconnect >/dev/null 2>&1
	warp-cli --accept-tos disable-always-on >/dev/null 2>&1
	warp-cli --accept-tos delete >/dev/null 2>&1
	ip -4 rule delete from 172.16.0.2/32 lookup 51820 >/dev/nulll 2>&1
	ip -4 rule delete table main suppress_prefixlength 0 >/dev/nulll 2>&1
	${PACKAGE_UNINSTALL[int]} cloudflare-warp 2>/dev/null
	systemctl disable --now warp-svc >/dev/null 2>&1
	rm -rf /usr/bin/wgcf /etc/wireguard /usr/bin/wireguard-go wgcf-account.toml wgcf-profile.conf /usr/bin/warp
	}
	
	# 卸载 WirePorxy
 	uninstall_wireproxy(){
	systemctl disable --now wireproxy
	[[ $SYSTEM != "Arch" ]] && ${PACKAGE_UNINSTALL[int]} wireguard-dkms resolvconf 2>/dev/null
	${PACKAGE_UNINSTALL[int]} openresolv 2>/dev/null
	rm -rf /usr/bin/wgcf /etc/wireguard /usr/bin/wireguard-go wgcf-account.toml wgcf-profile.conf /usr/bin/warp /etc/dnsmasq.d/warp.conf /usr/bin/wireproxy /lib/systemd/system/wireproxy.service
	[[ -e /etc/gai.conf ]] && sed -i '/^precedence \:\:ffff\:0\:0/d;/^label 2002\:\:\/16/d' /etc/gai.conf
	[[ -e /usr/bin/tun.sh ]] && rm -f /usr/bin/tun.sh && sed -i '/tun.sh/d' /etc/crontab
	}
	
	# 如已安装 warp_unlock 项目，先行卸载
	[[ -e /etc/wireguard/warp_unlock.sh ]] && bash <(curl -sSL https://raw.githubusercontent.com/fscarmen/warp_unlock/main/unlock.sh) -U -$L
	
	# 根据已安装情况执行卸载任务并显示结果
	UNINSTALL_CHECK=("wg-quick"		"warp-cli"		"wireproxy")
	UNINSTALL_DO=("uninstall_wgcf"		"uninstall_proxy"	"uninstall_wireproxy")
	UNINSTALL_RESULT=("${T[${L}117]}"	"${T[${L}119]}"		"${T[${L}98]}")
	for ((i=0; i<${#UNINSTALL_CHECK}; i++)); do
		type -P ${UNINSTALL_CHECK[i]} >/dev/null 2>&1 && (${UNINSTALL_DO[i]}; green " ${UNINSTALL_RESULT[i]} ")
	done

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
	unset IP4 IP6 WAN4 WAN6 COUNTRY4 COUNTRY6 ASNORG4 ASNORG6 WARPSTATUS4 WARPSTATUS6
	[[ ! $(type -P wg-quick) || ! -e /etc/wireguard/wgcf.conf ]] && red " ${T[${L}10]} " && exit 1
	i=1;j=5
	yellow " $(eval echo "${T[${L}11]}")\n $(eval echo "${T[${L}12]}") "
	[[ $SYSTEM != Alpine ]] && [[ $(systemctl is-active wg-quick@wgcf) != 'active' ]] && wg-quick down wgcf >/dev/null 2>&1
	${SYSTEMCTL_START[int]} >/dev/null 2>&1
	wg-quick up wgcf >/dev/null 2>&1
	ss -nltp | grep dnsmasq >/dev/null 2>&1 && systemctl restart dnsmasq >/dev/null 2>&1
	ip4_info; ip6_info
	until [[ $TRACE4$TRACE6 =~ on|plus ]]
		do	(( i++ )) || true
			yellow " $(eval echo "${T[${L}12]}") "
			${SYSTEMCTL_RESTART[int]} >/dev/null 2>&1
			ss -nltp | grep dnsmasq >/dev/null 2>&1 && systemctl restart dnsmasq >/dev/null 2>&1
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
	green " ${T[${L}14]} "
	[[ $L = C ]] && COUNTRY4=$(translate "$COUNTRY4")
	[[ $L = C ]] && COUNTRY6=$(translate "$COUNTRY6")
	[[ $OPTION = [on] ]] && green " IPv4:$WAN4 $WARPSTATUS4 $COUNTRY4 $ASNORG4\n IPv6:$WAN6 $WARPSTATUS6 $COUNTRY6 $ASNORG6 "
	}

# WARP 开关，先检查是否已安装，再根据当前状态转向相反状态
onoff(){ 
	! type -P wg-quick >/dev/null 2>&1 && red " ${T[${L}155]} " && exit 1
	[[ -n $(wg 2>/dev/null) ]] && (wg-quick down wgcf >/dev/null 2>&1; green " ${T[${L}15]} ") || net
	}

# Proxy 开关，先检查是否已安装，再根据当前状态转向相反状态
proxy_onoff(){
	! type -P warp-cli >/dev/null 2>&1 && red " ${T[${L}93]} " && exit 1
	if systemctl is-active warp-svc >/dev/null 2>&1; then
		[[ ! $(warp-cli --accept-tos settings) =~ WarpProxy ]] && ( ip -4 rule delete from 172.16.0.2/32 lookup 51820; ip -4 rule delete table main suppress_prefixlength 0 )
		systemctl stop warp-svc
		green " ${T[${L}91]} " && exit 0

	else	systemctl start warp-svc; sleep 2
		if [[ $(warp-cli --accept-tos settings) =~ WarpProxy ]]; then
			proxy_info
			ACCOUNT=$(warp-cli --accept-tos account 2>/dev/null)
			if [[ $ACCOUNT =~ 'Limited' ]]; then
				QUOTA=$(expr "$ACCOUNT" : '.*Quota:\s\([0-9]\{1,\}\)\s.*')
				[[ $QUOTA -gt 10000000000000 ]] && QUOTA="$((QUOTA/1000000000000)) TiB" ||  QUOTA="$((QUOTA/1000000000)) GiB"
				AC='+'
			fi
			[[ $(ss -nltp) =~ 'warp-svc' ]] && green " ${T[${L}90]}\n $(eval echo "${T[${L}27]}") "
			[[ -n "$QUOTA" ]] && green " ${T[${L}63]}：$QUOTA "
		exit 0

		else INTERFACE='--interface CloudflareWARP'
			ip -4 rule add from 172.16.0.2 lookup 51820; ip -4 route add default dev CloudflareWARP table 51820; ip -4 rule add table main suppress_prefixlength 0
			ip4_info
			[[ $L = C && -n "$COUNTRY4" ]] && COUNTRY4=$(translate "$COUNTRY4")
			ACCOUNT=$(warp-cli --accept-tos account 2>/dev/null)
			if [[ $ACCOUNT =~ 'Limited' ]]; then
				QUOTA=$(expr "$ACCOUNT" : '.*Quota:\s\([0-9]\{1,\}\)\s.*')
				[[ $QUOTA -gt 10000000000000 ]] && QUOTA="$((QUOTA/1000000000000)) TiB" ||  QUOTA="$((QUOTA/1000000000)) GiB"
				AC='+'
			fi
			[[ $(ip a) =~ 'CloudflareWARP' ]] && green " ${T[${L}90]}\n $(eval echo "${T[${L}169]}") "
			[[ -n "$QUOTA" ]] && green " ${T[${L}63]}：$QUOTA "
		exit 0
		fi
	fi
	}

# WireProxy 开关，先检查是否已安装，再根据当前状态转向相反状态
wireproxy_onoff(){
	! type -P wireproxy >/dev/null 2>&1 && red " ${T[${L}157]} " && exit 1 || OCTEEP=1
	if ss -nltp | grep wireproxy >/dev/null 2>&1; then
		systemctl stop wireproxy
		[[ ! $(ss -nltp) =~ 'wireproxy' ]] && green " ${T[${L}158]} "

	else systemctl start wireproxy
		sleep 1 && proxy_info 
		[[ $(ss -nltp) =~ 'wireproxy' ]] && green " ${T[${L}99]}\n $(eval echo "${T[${L}162]}") "
	fi
	}

# 检查系统 WARP 单双栈情况。为了速度，先检查 WGCF 配置文件里的情况，再判断 trace
check_stack(){
	if [[ -e /etc/wireguard/wgcf.conf ]]; then
		grep -q "^#.*0\.\0\/0" /etc/wireguard/wgcf.conf && T4=0 || T4=1
		grep -q "^#.*\:\:\/0" /etc/wireguard/wgcf.conf && T6=0 || T6=1
		else
		case "$TRACE4" in off ) T4='0';; 'on'|'plus' ) T4='1';; esac
		case "$TRACE6" in off ) T6='0';; 'on'|'plus' ) T6='1';; esac
	fi
	CASE=("@0" "0@" "0@0" "@1" "0@1" "1@" "1@0" "1@1")
	for ((m=0;m<${#CASE[@]};m++)); do [[ $T4@$T6 = ${CASE[m]} ]] && break; done
	WARP_BEFORE=("" "" "" "WARP IPv6 only" "WARP IPv6" "WARP IPv4 only" "WARP IPv4" "${T[${L}70]}")
	WARP_AFTER1=("" "" "" "WARP IPv4" "WARP IPv4" "WARP IPv6" "WARP IPv6" "WARP IPv4")
	WARP_AFTER2=("" "" "" "${T[${L}70]}" "${T[${L}70]}" "${T[${L}70]}" "${T[${L}70]}" "WARP IPv6")
	TO1=("" "" "" "014" "014" "106" "106" "114")
	TO2=("" "" "" "01D" "01D" "10D" "10D" "116")
	}

# 单双栈在线互换。先看菜单是否有选择，再看传参数值，再没有显示2个可选项
stack_switch(){
	# WARP 单双栈切换选项
	SWITCH014='sed -i "s/#//g;s/^.*\:\:\/0/#&/g" /etc/wireguard/wgcf.conf'
	SWITCH01D='sed -i "s/#//g" /etc/wireguard/wgcf.conf'
	SWITCH106='sed -i "s/#//g;s/^.*0\.\0\/0/#&/g" /etc/wireguard/wgcf.conf'
	SWITCH10D='sed -i "s/#//g" /etc/wireguard/wgcf.conf'
	SWITCH114='sed -i "s/^.*\:\:\/0/#&/g" /etc/wireguard/wgcf.conf'
	SWITCH116='sed -i "s/^.*0\.\0\/0/#&/g" /etc/wireguard/wgcf.conf'
	
	[[ $CLIENT = [35] && $SWITCHCHOOSE = [4D] ]] && red " ${T[${L}109]} " && exit 1
	check_stack
	if [[ $CHOOSE1 = [12] ]]; then TO=$(eval echo \${TO$CHOOSE1[m]})
	elif [[ $SWITCHCHOOSE = [46D] ]]; then
	[[ "$T4@$T6@$SWITCHCHOOSE" =~ '1@0@4'|'0@1@6'|'1@1@D' ]] && red " ${T[${L}146]} " && exit 1 || TO="$T4$T6$SWITCHCHOOSE"
	else
	OPTION1="$(eval echo "${T[${L}141]}")"; OPTION2="$(eval echo "${T[${L}142]}")"
	yellow " $(eval echo "${T[${L}145]}") " && reading " ${T[${L}50]} " SWITCHTO
		case "$SWITCHTO" in
		1 ) TO=${TO1[m]};;	2 ) TO=${TO2[m]};;	0 ) exit;;
		* ) red " ${T[${L}51]} [0-2] "; sleep 1; stack_switch;;
		esac
	fi
	sh -c "$(eval echo "\$SWITCH$TO")"
	${SYSTEMCTL_RESTART[int]}
	OPTION=n && net
	}

# 检测系统信息
check_system_info(){
	green " ${T[${L}37]} "

	# 必须加载 TUN 模块，先尝试在线打开 TUN。尝试成功放到启动项，失败作提示并退出脚本
	TUN=$(cat /dev/net/tun 2>&1 | tr '[:upper:]' '[:lower:]')
 	if [[ ! $TUN =~ 'in bad state' ]] && [[ ! $TUN =~ '处于错误状态' ]] && [[ ! $TUN =~ 'Die Dateizugriffsnummer ist in schlechter Verfassung' ]]; then
	cat >/usr/bin/tun.sh << EOF
#!/bin/bash
mkdir -p /dev/net
mknod /dev/net/tun c 10 200
chmod 0666 /dev/net/tun
EOF
	bash /usr/bin/tun.sh
	TUN=$(cat /dev/net/tun 2>&1 | tr '[:upper:]' '[:lower:]')
		if [[ ! $TUN =~ 'in bad state' ]] && [[ ! $TUN =~ '处于错误状态' ]] && [[ ! $TUN =~ 'Die Dateizugriffsnummer ist in schlechter Verfassung' ]]; then
			rm -f /usr/bin//tun.sh && red " ${T[${L}3]} " && exit 1
		else echo "@reboot root bash /usr/bin/tun.sh" >> /etc/crontab
		fi
	fi

	# 判断是否大陆 VPS。先尝试连接 CloudFlare WARP 服务的 Endpoint IP，如遇到 WARP 断网则先关闭、杀进程后重试一次，仍然不通则 WARP 项目不可用。
	ping6 -c2 -w8 2606:4700:d0::a29f:c001 >/dev/null 2>&1 && IPV6=1 && CDN=-6 || IPV6=0
	ping -c2 -W8 162.159.193.10 >/dev/null 2>&1 && IPV4=1 && CDN=-4 || IPV4=0
	if [[ $IPV4$IPV6 = 00 && -n $(wg 2>/dev/null) ]]; then
		wg-quick down wgcf >/dev/null 2>&1
		kill -9 $(pgrep -f wireguard 2>/dev/null)
		ping6 -c2 -w10 2606:4700:d0::a29f:c001 >/dev/null 2>&1 && IPV6=1 && CDN=-6
		ping -c2 -W10 162.159.193.10 >/dev/null 2>&1 && IPV4=1 && CDN=-4
	fi

	# 判断处理器架构
	case $(uname -m) in
	aarch64 ) ARCHITECTURE=arm64;;	x86_64 ) ARCHITECTURE=amd64;;	s390x ) ARCHITECTURE=s390x;;	* ) red " $(eval echo "${T[${L}134]}") " && exit 1;;
	esac

	# 判断当前 IPv4 与 IPv6 ，IP归属 及 WARP 方案, Linux Client 是否开启
	[[ $IPV4 = 1 ]] && ip4_info
	[[ $IPV6 = 1 ]] && ip6_info
	[[ $L = C && -n "$COUNTRY4" ]] && COUNTRY4=$(translate "$COUNTRY4")
	[[ $L = C && -n "$COUNTRY6" ]] && COUNTRY6=$(translate "$COUNTRY6")

	# 判断当前 WARP 状态，决定变量 PLAN，变量 PLAN 含义：1=单栈  2=双栈  3=WARP已开启
	[[ $TRACE4$TRACE6 =~ on|plus ]] && PLAN=3 || PLAN=$((IPV4+IPV6))

	# 判断当前 Linux Client 状态，决定变量 CLIENT，变量 CLIENT 含义：0=未安装  1=已安装未激活  2=状态激活  3=Clinet proxy 已开启  5=Clinet warp 已开启
	CLIENT=0
	if type -P warp-cli >/dev/null 2>&1; then
		CLIENT=1 && CLIENT_INSTALLED="${T[${L}92]}"
		[[ $(systemctl is-active warp-svc 2>/dev/null) = active || $(systemctl is-enabled warp-svc 2>/dev/null) = enabled ]] && CLIENT=2
		if [[ $(warp-cli --accept-tos settings) =~ WarpProxy ]]; then
			[[ $CLIENT = 2 ]] && CLIENT_MODE='Proxy' && [[ $(ss -nltp) =~ 'warp-svc' ]] && CLIENT=3 && proxy_info
		else
			[[ $CLIENT = 2 ]] && CLIENT_MODE='WARP' && [[ $(ip a) =~ 'CloudflareWARP' ]] && CLIENT=5 && INTERFACE='--interface CloudflareWARP' && ip4_info
		fi
	fi

	# 判断当前 WireProxy 状态，决定变量 WIREPROXY，变量 WIREPROXY 含义：0=未安装  1=已安装未激活  2=状态激活  3=Clinet 已开启
	WIREPROXY=0
	if type -P wireproxy >/dev/null 2>&1; then
		WIREPROXY=1
		[[ $WIREPROXY = 1 ]] && WIREPROXY_INSTALLED="${T[${L}92]}" && [[ $(ss -nltp) =~ 'wireproxy' ]] && WIREPROXY=3 && proxy_info || WIREPROXY=2
	fi

	# 在KVM的前提下，判断 Linux 版本是否小于 5.6，如是则安装 wireguard 内核模块，变量 WG=1。由于 linux 不能直接用小数作比较，所以用 （主版本号 * 100 + 次版本号 ）与 506 作比较
	[[ $LXC != 1 && $(($(uname -r | cut -d . -f1) * 100 +  $(uname -r | cut -d . -f2))) -lt 506 ]] && WG=1
	}

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
	URL=${URL:-'https://gist.githubusercontent.com/fscarmen/56aaf02d743551737c9973b8be7a3496/raw/61bf63e68e4e91152545679b8f11c72cac215128/2021.12.21'}
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
	i=5
	ss -nltp | grep -q ':40000'[[:space:]] && reading " $(eval echo "${T[${L}103]}") " PORT || reading " ${T[${L}104]} " PORT
	PORT=${PORT:-'40000'}
	until echo "$PORT" | grep -qE "^[1-9][0-9]{3,4}$" && [[ ! $(ss -nltp) =~ :"$PORT"[[:space:]] ]]
		do	(( i-- )) || true
			[[ $i = 0 ]] && red " ${T[${L}29]} " && exit 1
			echo "$PORT" | grep -qvE "^[1-9][0-9]{1,4}$" && reading " $(eval echo "${T[${L}111]}") " PORT
			echo "$PORT" | grep -qE "^[1-9][0-9]{1,4}$" && [[ $(ss -nltp) =~ :"$PORT"[[:space:]] ]] && reading " $(eval echo "${T[${L}103]}") " PORT
	done
	}

# Linux Client 或 WireProxy 端口
change_port(){
	socks5_port(){ input_port; warp-cli --accept-tos set-proxy-port "$PORT"; }
	wireproxy_port(){
		input_port
		sed -i "s/BindAddress.*/BindAddress = 127.0.0.1:$PORT/g" /etc/wireguard/proxy.conf
		systemctl restart wireproxy
		}

	INSTALL_CHECK=("$CLIENT" "$WIREPROXY")
	CASE_RESAULT=("0 1"		"1 0"		"1 1")
	SHOW_CHOOSE=(""			""		"${T[${L}151]}")
	CHANGE_PORT1=("wireproxy_port"	"socks5_port"	"socks5_port")
	CHANGE_PORT2=(""		"" 		"wireproxy_port")

	for ((e=0;e<${#INSTALL_CHECK[@]}; e++)); do
		[[ "${INSTALL_CHECK[e]}" -gt 1 ]]  && INSTALL_RESULT[e]=1 ||  INSTALL_RESULT[e]=0
	done

	for ((f=0; f<${#CASE_RESAULT[@]}; f++)); do
		[[ ${INSTALL_RESULT[@]} = "${CASE_RESAULT[f]}" ]] && break
	done

	case "$f" in
	0|1 ) ${CHANGE_PORT1[f]}
		ss -nltp | grep -q ":$PORT" && green " $(eval echo "${T[${L}122]}") " || red " ${T[${L}34]} ";;
	2 ) yellow " ${SHOW_CHOOSE[f]} " && reading " ${T[${L}50]} " MODE
		case "$MODE" in
		[1-2] ) $(eval echo "\${CHANGE_IP$MODE[f]}")
		ss -nltp | grep -q ":$PORT" && green " $(eval echo "${T[${L}122]}") " || red " ${T[${L}34]} ";;
		* ) red " ${T[${L}51]} [1-2] "; sleep 1; change_port;;
		esac;;
	esac	
	}

# 选用 iptables+dnsmasq+ipset 方案执行
iptables_solution(){
	${PACKAGE_INSTALL[int]} ipset dnsmasq resolvconf mtr

	# 创建 dnsmasq 规则文件
	cat >/etc/dnsmasq.d/warp.conf << EOF
#!/bin/bash
server=1.1.1.1
server=8.8.8.8
# ----- WARP ----- #
# > Youtube Premium
server=/googlevideo.com/1.1.1.1
server=/youtube.com/1.1.1.1
server=/youtubei.googleapis.com/1.1.1.1
server=/fonts.googleapis.com/1.1.1.1
server=/yt3.ggpht.com/1.1.1.1
server=/gstatic.com/1.1.1.1

ipset=/www.cloudflare.com/warp
ipset=/ip.gs/warp
ipset=/googlevideo.com/warp
ipset=/youtube.com/warp
ipset=/youtubei.googleapis.com/warp
ipset=/fonts.googleapis.com/warp
ipset=/yt3.ggpht.com/warp

# > Netflix
ipset=/fast.com/warp
ipset=/netflix.com/warp
ipset=/netflix.net/warp
ipset=/nflxext.com/warp
ipset=/nflximg.com/warp
ipset=/nflximg.net/warp
ipset=/nflxso.net/warp
ipset=/nflxvideo.net/warp

# > TVBAnywhere+
ipset=/uapisfm.tvbanywhere.com.sg/warp

# > Disney+
ipset=/bamgrid.com/warp
ipset=/disney-plus.net/warp
ipset=/disneyplus.com/warp
ipset=/dssott.com/warp
ipset=/disneynow.com/warp
ipset=/disneystreaming.com/warp
ipset=/cdn.registerdisney.go.com/warp

# > TikTok
ipset=/byteoversea.com/warp
ipset=/ibytedtos.com/warp
ipset=/ipstatp.com/warp
ipset=/muscdn.com/warp
ipset=/musical.ly/warp
ipset=/tiktok.com/warp
ipset=/tik-tokapi.com/warp
ipset=/tiktokcdn.com/warp
ipset=/tiktokv.com/warp
EOF
		
	# 创建 PostUp 和 PreDown
	cat >/etc/wireguard/up << EOF
#!/bin/bash

ipset create warp hash:ip
iptables -t mangle -N fwmark
iptables -t mangle -A PREROUTING -j fwmark
iptables -t mangle -A OUTPUT -j fwmark
iptables -t mangle -A fwmark -m set --match-set warp dst -j MARK --set-mark 2
ip rule add fwmark 2 table warp
ip route add default dev wgcf table warp
iptables -t nat -A POSTROUTING -m mark --mark 0x2 -j MASQUERADE
iptables -t mangle -A POSTROUTING -o wgcf -p tcp -m tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu	
EOF

	cat >/etc/wireguard/down << EOF
#!/bin/bash

iptables -t mangle -D PREROUTING -j fwmark
iptables -t mangle -D OUTPUT -j fwmark
iptables -t mangle -D fwmark -m set --match-set warp dst -j MARK --set-mark 2
ip rule del fwmark 2 table warp
iptables -t mangle -D POSTROUTING -o wgcf -p tcp -m tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu
iptables -t nat -D POSTROUTING -m mark --mark 0x2 -j MASQUERADE
iptables -t mangle -F fwmark
iptables -t mangle -X fwmark
sleep 2
ipset destroy warp
EOF

	chmod +x /etc/wireguard/up /etc/wireguard/down
	
	# 修改 wgcf-profile.conf 和 warp.conf 文件
	sed -i "s/^Post.*/#&/g;\$a PersistentKeepalive = 5" wgcf-profile.conf
	sed -i "7 i Table = off\nPostUp = /etc/wireguard/up\nPredown = /etc/wireguard/down" wgcf-profile.conf
	[[ $m = 0 ]] && sed -i "2i server=2606:4700:4700::1111\nserver=2001:4860:4860::8888\nserver=2001:4860:4860::8844" /etc/dnsmasq.d/warp.conf
	! grep -q 'warp' /etc/iproute2/rt_tables && echo '250   warp' >>/etc/iproute2/rt_tables
	systemctl disable systemd-resolved --now >/dev/null 2>&1 && sleep 2
	systemctl enable dnsmasq --now >/dev/null 2>&1 && sleep 2
	}

# WGCF 或 WireProxy 安装
install(){
	# WireProxy 禁止重复安装，自定义 Port
	if [[ $OCTEEP = 1 ]]; then
		ss -nltp | grep -q wireproxy && red " ${T[${L}166]} " && exit 1 || input_port
	
	# iptables 禁止重复安装，不适用于 IPv6 only VPS
	elif [[ $ANEMONE = 1 ]]; then
		[[ -e /etc/dnsmasq.d/warp.conf ]] && red " ${T[${L}167]} " && exit 1
		[[ $m = 0 ]] && red " ${T[${L}147]} " && exit 1 || CONF=${CONF1[m]}
	fi

	# 先删除之前安装，可能导致失败的文件
	rm -rf /usr/bin/wgcf /usr/bin/wireguard-go wgcf-account.toml wgcf-profile.conf
	
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
	# 判断 wgcf 的最新版本,如因 github 接口问题未能获取，默认 v2.2.12
	{	
	latest=$(wget --no-check-certificate -qO- -T1 -t1 $CDN "https://api.github.com/repos/ViRb3/wgcf/releases/latest" | grep "tag_name" | head -n 1 | cut -d : -f2 | sed 's/[ \"v,]//g')
	latest=${latest:-'2.2.12'}

	# 安装 wgcf，尽量下载官方的最新版本，如官方 wgcf 下载不成功，将使用 jsDelivr 的 CDN，以更好的支持双栈。并添加执行权限
	wget --no-check-certificate -T1 -t1 $CDN -O /usr/bin/wgcf https://github.com/ViRb3/wgcf/releases/download/v"$latest"/wgcf_"$latest"_linux_$ARCHITECTURE ||
	wget --no-check-certificate $CDN -O /usr/bin/wgcf https://cdn.jsdelivr.net/gh/fscarmen/warp/wgcf/wgcf_"$latest"_linux_$ARCHITECTURE
	chmod +x /usr/bin/wgcf

	# 如安装 WireProxy ，尽量下载官方的最新版本，如官方 WireProxy 下载不成功，将使用 jsDelivr 的 CDN，以更好的支持双栈。并添加执行权限
	if [[ $OCTEEP = 1 ]]; then
		wireproxy_latest=$(wget --no-check-certificate -qO- -T1 -t1 $CDN "https://api.github.com/repos/octeep/wireproxy/releases/latest" | grep "tag_name" | head -n 1 | cut -d : -f2 | sed 's/[ \"v,]//g')
		wireproxy_latest=${wireproxy_latest:-'1.0.3'}
		wget --no-check-certificate -T1 -t1 $CDN -N https://github.com/octeep/wireproxy/releases/download/v"$wireproxy_latest"/wireproxy_linux_$ARCHITECTURE.tar.gz ||
		wget --no-check-certificate $CDN -N https://cdn.jsdelivr.net/gh/fscarmen/warp/wireproxy/wireproxy_linux_$ARCHITECTURE.tar.gz
		tar xzf wireproxy_linux_$ARCHITECTURE.tar.gz -C /usr/bin/; rm -f wireproxy_linux*
	fi
	
	# 注册 WARP 账户 ( wgcf-account.toml 使用默认值加加快速度)。如有 WARP+ 账户，修改 license 并升级，并把设备名等信息保存到 /etc/wireguard/info.log
	mkdir -p /etc/wireguard/ >/dev/null 2>&1
	until [[ -e wgcf-account.toml ]] >/dev/null 2>&1; do
		wgcf register --accept-tos >/dev/null 2>&1 && break
	done
	[[ -n $LICENSE ]] && yellow " \n${T[${L}35]}\n " && sed -i "s#license_key.*#license_key = \"$LICENSE\"#g" wgcf-account.toml &&
	( wgcf update --name "$NAME" > /etc/wireguard/info.log 2>&1 || red " \n${T[${L}36]}\n " )

	# 生成 Wire-Guard 配置文件 (wgcf-profile.conf)
	[[ -e wgcf-account.toml ]] && wgcf generate >/dev/null 2>&1
	green " \n${T[${L}33]}\n "

	# 反复测试最佳 MTU。 Wireguard Header：IPv4=60 bytes,IPv6=80 bytes，1280 ≤1 MTU ≤ 1420。 ping = 8(ICMP回显示请求和回显应答报文格式长度) + 20(IP首部) 。
	# 详细说明：<[WireGuard] Header / MTU sizes for Wireguard>：https://lists.zx2c4.com/pipermail/wireguard/2017-December/002201.html
	MTU=$((1500-28))
	[[ $IPV4$IPV6 = 01 ]] && ping6 -c1 -W1 -s $MTU -Mdo 2606:4700:d0::a29f:c001 >/dev/null 2>&1 || ping -c1 -W1 -s $MTU -Mdo 162.159.193.10 >/dev/null 2>&1
	until [[ $? = 0 || $MTU -le $((1280+80-28)) ]]
	do
	MTU=$((MTU-10))
	[[ $IPV4$IPV6 = 01 ]] && ping6 -c1 -W1 -s $MTU -Mdo 2606:4700:d0::a29f:c001 >/dev/null 2>&1 || ping -c1 -W1 -s $MTU -Mdo 162.159.193.10 >/dev/null 2>&1
	done

	if [[ $MTU -eq $((1500-28)) ]]; then MTU=$MTU
	elif [[ $MTU -le $((1280+80-28)) ]]; then MTU=$((1280+80-28))
	else
		for ((i=0; i<9; i++)); do
		(( MTU++ ))
		( [[ $IPV4$IPV6 = 01 ]] && ping6 -c1 -W1 -s $MTU -Mdo 2606:4700:d0::a29f:c001 >/dev/null 2>&1 || ping -c1 -W1 -s $MTU -Mdo 162.159.193.10 >/dev/null 2>&1 ) || break
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
		if [[ $(echo $SYS | sed "s/[^0-9.]//g" | cut -d. -f1) = 9 ]]; then
			apt -y upgrade
			echo "deb http://deb.debian.org/debian/ unstable main" > /etc/apt/sources.list.d/unstable-wireguard.list
			echo -e "Package: *\nPin: release a=unstable\nPin-Priority: 150\n" > /etc/apt/preferences.d/limit-unstable
			else ${PACKAGE_INSTALL[int]} lsb-release
			echo "deb http://deb.debian.org/debian $(lsb_release -sc)-backports main" > /etc/apt/sources.list.d/backports.list
		fi	
		# 再次更新源
		${PACKAGE_UPDATE[int]}

		# 安装一些必要的网络工具包和wireguard-tools (Wire-Guard 配置工具：wg、wg-quick)
		${PACKAGE_INSTALL[int]} --no-install-recommends net-tools iproute2 openresolv dnsutils iptables
		[[ $OCTEEP != 1 ]] && ${PACKAGE_INSTALL[int]} --no-install-recommends wireguard-tools

		# 如 Linux 版本低于5.6并且是 kvm，则安装 wireguard 内核模块
		[[ $WG = 1 ]] && ${PACKAGE_INSTALL[int]} --no-install-recommends linux-headers-"$(uname -r)" && ${PACKAGE_INSTALL[int]} --no-install-recommends wireguard-dkms
		}

	Ubuntu(){
		# 更新源
		${PACKAGE_UPDATE[int]}

		# 安装一些必要的网络工具包和 wireguard-tools (Wire-Guard 配置工具：wg、wg-quick)
		${PACKAGE_INSTALL[int]} --no-install-recommends net-tools iproute2 openresolv dnsutils iptables
		[[ $OCTEEP != 1 ]] && ${PACKAGE_INSTALL[int]} --no-install-recommends wireguard-tools
		}
		
	CentOS(){
		# 安装一些必要的网络工具包和wireguard-tools (Wire-Guard 配置工具：wg、wg-quick)
		[[ $COMPANY = amazon ]] && ${PACKAGE_UPDATE[int]} && amazon-linux-extras install -y epel		
		${PACKAGE_INSTALL[int]} epel-release
		${PACKAGE_INSTALL[int]} net-tools iptables
		[[ $OCTEEP != 1 ]] && ${PACKAGE_INSTALL[int]} wireguard-tools

		# 如 Linux 版本低于5.6并且是 kvm，则安装 wireguard 内核模块
		VERSION_ID=$(expr "$SYS" : '.*\s\([0-9]\{1,\}\)\.*')
		[[ $ARCHITECTURE != s390x ]] && [[ $WG = 1 ]] && curl -Lo /etc/yum.repos.d/wireguard.repo https://copr.fedorainfracloud.org/coprs/jdoss/wireguard/repo/epel-"$VERSION_ID"/jdoss-wireguard-epel-"$VERSION_ID".repo &&

		${PACKAGE_INSTALL[int]} wireguard-dkms

		# 升级所有包同时也升级软件和系统内核
		${PACKAGE_UPDATE[int]}
		
		# s390x wireguard-tools 安装
		[[ $ARCHITECTURE = s390x ]] && ! type -P wg >/etc/null 2>&1 && rpm -i https://mirrors.cloud.tencent.com/epel/8/Everything/s390x/Packages/w/wireguard-tools-1.0.20210914-1.el8.s390x.rpm
		}

	Alpine(){
		# 安装一些必要的网络工具包和wireguard-tools (Wire-Guard 配置工具：wg、wg-quick)
		${PACKAGE_INSTALL[int]} net-tools iproute2 openresolv openrc iptables
		[[ $OCTEEP != 1 ]] && ${PACKAGE_INSTALL[int]} wireguard-tools
		}

	Arch(){
		# 安装一些必要的网络工具包和wireguard-tools (Wire-Guard 配置工具：wg、wg-quick)
		${PACKAGE_INSTALL[int]} openresolv
		[[ $OCTEEP != 1 ]] && ${PACKAGE_INSTALL[int]} wireguard-tools
		}

	$SYSTEM

	wait
	
	# WGCF 配置修改，其中用到的 162.159.193.10 和 2606:4700:d0::a29f:c001 均是 engage.cloudflareclient.com 的 IP
	MODIFY014='sed -i "s/1.1.1.1/2606:4700:4700::1111,2001:4860:4860::8888,2001:4860:4860::8844,1.1.1.1,8.8.8.8,8.8.4.4/g;7 s/^/PostDown = ip -6 rule delete from '$LAN6' lookup main\n/;7 s/^/PostUp = ip -6 rule add from '$LAN6' lookup main\n/;s/engage.cloudflareclient.com/[2606:4700:d0::a29f:c001]/g;s/^.*\:\:\/0/#&/g" wgcf-profile.conf'
	MODIFY016='sed -i "s/1.1.1.1/2606:4700:4700::1111,2001:4860:4860::8888,2001:4860:4860::8844,1.1.1.1,8.8.8.8,8.8.4.4/g;7 s/^/PostDown = ip -6 rule delete from '$LAN6' lookup main\n/;7 s/^/PostUp = ip -6 rule add from '$LAN6' lookup main\n/;s/engage.cloudflareclient.com/[2606:4700:d0::a29f:c001]/g;s/^.*0\.\0\/0/#&/g" wgcf-profile.conf'
	MODIFY01D='sed -i "s/1.1.1.1/2606:4700:4700::1111,2001:4860:4860::8888,2001:4860:4860::8844,1.1.1.1,8.8.8.8,8.8.4.4/g;7 s/^/PostDown = ip -6 rule delete from '$LAN6' lookup main\n/;7 s/^/PostUp = ip -6 rule add from '$LAN6' lookup main\n/;s/engage.cloudflareclient.com/[2606:4700:d0::a29f:c001]/g" wgcf-profile.conf'
	MODIFY104='sed -i "s/1.1.1.1/1.1.1.1,8.8.8.8,8.8.4.4,2606:4700:4700::1111,2001:4860:4860::8888,2001:4860:4860::8844/g;7 s/^/PostDown = ip -4 rule delete from '$LAN4' lookup main\n/;7 s/^/PostUp = ip -4 rule add from '$LAN4' lookup main\n/;s/engage.cloudflareclient.com/162.159.193.10/g;s/^.*\:\:\/0/#&/g" wgcf-profile.conf'
	MODIFY106='sed -i "s/1.1.1.1/1.1.1.1,8.8.8.8,8.8.4.4,2606:4700:4700::1111,2001:4860:4860::8888,2001:4860:4860::8844/g;7 s/^/PostDown = ip -4 rule delete from '$LAN4' lookup main\n/;7 s/^/PostUp = ip -4 rule add from '$LAN4' lookup main\n/;s/engage.cloudflareclient.com/162.159.193.10/g;s/^.*0\.\0\/0/#&/g" wgcf-profile.conf'
	MODIFY10D='sed -i "s/1.1.1.1/1.1.1.1,8.8.8.8,8.8.4.4,2606:4700:4700::1111,2001:4860:4860::8888,2001:4860:4860::8844/g;7 s/^/PostDown = ip -4 rule delete from '$LAN4' lookup main\n/;7 s/^/PostUp = ip -4 rule add from '$LAN4' lookup main\n/;s/engage.cloudflareclient.com/162.159.193.10/g" wgcf-profile.conf'
	MODIFY114='sed -i "s/1.1.1.1/1.1.1.1,8.8.8.8,8.8.4.4,2606:4700:4700::1111,2001:4860:4860::8888,2001:4860:4860::8844/g;7 s/^/PostDown = ip -6 rule delete from '$LAN6' lookup main\n/;7 s/^/PostUp = ip -6 rule add from '$LAN6' lookup main\n/;7 s/^/PostDown = ip -4 rule delete from '$LAN4' lookup main\n/;7 s/^/PostUp = ip -4 rule add from '$LAN4' lookup main\n/;s/engage.cloudflareclient.com/162.159.193.10/g;s/^.*\:\:\/0/#&/g" wgcf-profile.conf'
	MODIFY116='sed -i "s/1.1.1.1/1.1.1.1,8.8.8.8,8.8.4.4,2606:4700:4700::1111,2001:4860:4860::8888,2001:4860:4860::8844/g;7 s/^/PostDown = ip -6 rule delete from '$LAN6' lookup main\n/;7 s/^/PostUp = ip -6 rule add from '$LAN6' lookup main\n/;7 s/^/PostDown = ip -4 rule delete from '$LAN4' lookup main\n/;7 s/^/PostUp = ip -4 rule add from '$LAN4' lookup main\n/;s/engage.cloudflareclient.com/162.159.193.10/g;s/^.*0\.\0\/0/#&/g" wgcf-profile.conf'
	MODIFY11D='sed -i "s/1.1.1.1/1.1.1.1,8.8.8.8,8.8.4.4,2606:4700:4700::1111,2001:4860:4860::8888,2001:4860:4860::8844/g;7 s/^/PostDown = ip -6 rule delete from '$LAN6' lookup main\n/;7 s/^/PostUp = ip -6 rule add from '$LAN6' lookup main\n/;7 s/^/PostDown = ip -4 rule delete from '$LAN4' lookup main\n/;7 s/^/PostUp = ip -4 rule add from '$LAN4' lookup main\n/;s/engage.cloudflareclient.com/162.159.193.10/g" wgcf-profile.conf'

	sh -c "$(eval echo "\$MODIFY$CONF")"

	if [[ $OCTEEP = 1 ]]; then
	# 默认 Endpoint 和 DNS 默认 IPv4 和 双栈的，如是 IPv6 修改默认值
	ENDPOINT='162.159.193.10' && DNS='1.1.1.1,8.8.8.8,8.8.4.4,2606:4700:4700::1111,2001:4860:4860::8888,2001:4860:4860::8844'
	[[ $m = 0 ]] && ENDPOINT='[2606:4700:d0::a29f:c001]' && DNS='2606:4700:4700::1111,2001:4860:4860::8888,2001:4860:4860::8844,1.1.1.1,8.8.8.8,8.8.4.4'
	
	# 创建 WirePorxy 配置文件
	cat > /etc/wireguard/proxy.conf << EOF
# The [Interface] and [Peer] configurations follow the same semantics and meaning
# of a wg-quick configuration. To understand what these fields mean, please refer to:
# https://wiki.archlinux.org/title/WireGuard#Persistent_configuration
# https://www.wireguard.com/#simple-network-interface
[Interface]
Address = 172.16.0.2/32 # The subnet should be /32 and /128 for IPv4 and v6 respectively
MTU = $(grep MTU wgcf-profile.conf | sed "s/MTU = //g")
PrivateKey = ${PRIVATEKEY:-"$(grep PrivateKey wgcf-profile.conf | sed "s/PrivateKey = //g")"}
DNS = $DNS

[Peer]
PublicKey = bmXOC+F1FxEMF9dyiK2H5/1SUtzH0JuVo51h2wPfgyo=
# PresharedKey = UItQuvLsyh50ucXHfjF0bbR4IIpVBd74lwKc8uIPXXs= (optional)
Endpoint = $ENDPOINT:2408
# PersistentKeepalive = 25 (optional)

# TCPClientTunnel is a tunnel listening on your machine,
# and it forwards any TCP traffic received to the specified target via wireguard.
# Flow:
# <an app on your LAN> --> localhost:25565 --(wireguard)--> play.cubecraft.net:25565
#[TCPClientTunnel]
#BindAddress = 127.0.0.1:25565
#Target = play.cubecraft.net:25565

# TCPServerTunnel is a tunnel listening on wireguard,
# and it forwards any TCP traffic received to the specified target via local network.
# Flow:
# <an app on your wireguard network> --(wireguard)--> 172.16.31.2:3422 --> localhost:25545
#[TCPServerTunnel]
#ListenPort = 3422
#Target = localhost:25545

# Socks5 creates a socks5 proxy on your LAN, and all traffic would be routed via wireguard.
[Socks5]
BindAddress = 127.0.0.1:$PORT

# Socks5 authentication parameters, specifying username and password enables
# proxy authentication.
#Username = ...
# Avoid using spaces in the password field
#Password = ...
EOF
	
	# 创建 WireProxy systemd 进程守护
	cat > /lib/systemd/system/wireproxy.service << EOF
[Unit]
Description=WireProxy for WARP
After=network.target
Documentation=https://github.com/fscarmen/warp
Documentation=https://github.com/octeep/wireproxy

[Service]
ExecStart=/usr/bin/wireproxy -c /etc/wireguard/proxy.conf
RemainAfterExit=yes
Restart=always

[Install]
WantedBy=multi-user.target
EOF

	# 运行 wireproxy
	systemctl enable --now wireproxy; sleep 1

	# 保存好配置文件, 把 wgcf-profile.conf 复制到/etc/wireguard/ 并命名为 wgcf.conf, 如有 Teams，改为 Teams 账户信息	
	mv -f wgcf-profile.conf /etc/wireguard/wgcf.conf >/dev/null 2>&1
	mv -f wgcf-account.toml menu.sh /etc/wireguard >/dev/null 2>&1
	[[ $CONFIRM = [Yy] ]] && teams_change && echo "$TEAMS" > /etc/wireguard/info.log 2>&1

	# 创建再次执行的软链接快捷方式，再次运行可以用 warp 指令,设置默认语言
	chmod +x /etc/wireguard/menu.sh >/dev/null 2>&1
	ln -sf /etc/wireguard/menu.sh /usr/bin/warp && green " ${T[${L}38]} "
	echo "$L" >/etc/wireguard/language

	# 结果提示，脚本运行时间，次数统计
	proxy_info
	end=$(date +%s)
	green " $(eval echo "${T[${L}149]}")\n $(eval echo "${T[${L}162]}") "
	red "\n==============================================================\n"
	yellow " ${T[${L}43]}\n " && help

	else [[ $ANEMONE = 1 ]] && iptables_solution

	# 特殊 VPS 的配置文件 DNS 次序
	[[ $(hostname 2>&1) = DiG9 ]] && sed -i "s/DNS.*/DNS = 8.8.8.8,8.8.4.4,2001:4860:4860::8888,2001:4860:4860::8844/g" wgcf-profile.conf

	# 把 wgcf-profile.conf 复制到/etc/wireguard/ 并命名为 wgcf.conf, 如有 Teams，改为 Teams 账户信息
	cp -f wgcf-profile.conf /etc/wireguard/wgcf.conf >/dev/null 2>&1

	[[ $CONFIRM = [Yy] ]] && teams_change && echo "$TEAMS" > /etc/wireguard/info.log 2>&1

	# 设置开机启动
	${SYSTEMCTL_ENABLE[int]}>/dev/null 2>&1
	type -P dnsmasq >/dev/null 2>&1 && systemctl restart dnsmasq >/dev/null 2>&1

	# 如是 LXC，安装 Wireguard-GO。部分较低内核版本的KVM，即使安装了wireguard-dkms, 仍不能正常工作，兜底使用 wireguard-go
	[[ $LXC = 1 ]] || ([[ $WG = 1 ]] && [[ $(systemctl is-active wg-quick@wgcf) != active || $(systemctl is-enabled wg-quick@wgcf) != enabled ]]) &&
	wget --no-check-certificate $CDN -N https://cdn.jsdelivr.net/gh/fscarmen/warp/wireguard-go/wireguard-go_linux_$ARCHITECTURE.tar.gz &&
	tar xzf wireguard-go_linux_$ARCHITECTURE.tar.gz -C /usr/bin/ && rm -f wireguard-go_linux_* && chmod +x /usr/bin/wireguard-go

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
	[[ $(curl -ksm8 https://ip.gs) = "$WAN6" ]] && PRIORITY=${T[${L}106]} || PRIORITY=${T[${L}107]}

	# 部分 LXC 内核已经包含 WireGuard 模块则会优先使用，此场景下删除 WireGuard-go
	[[ -e /usr/bin/wireguard-go ]] && ! pgrep -laf "wireguard-go" >/dev/null 2>&1 && rm -f /usr/bin/wireguard-go

	# 结果提示，脚本运行时间，次数统计
	end=$(date +%s)
	red "\n==============================================================\n"
	green " IPv4：$WAN4 $WARPSTATUS4 $COUNTRY4  $ASNORG4 "
	green " IPv6：$WAN6 $WARPSTATUS6 $COUNTRY6  $ASNORG6 "
	grep -sq 'Device name' /etc/wireguard/info.log 2>/dev/null && TYPE='+' || TYPE=' Teams'
	[[ $TRACE4$TRACE6 =~ plus ]] && green " $(eval echo "${T[${L}41]}") " && grep -sq 'Device name' /etc/wireguard/info.log && green " $(eval echo "${T[${L}133]}") "
	[[ $TRACE4$TRACE6 =~ on ]] && green " $(eval echo "${T[${L}42]}") "
	green " $PRIORITY "
	red "\n==============================================================\n"
	yellow " ${T[${L}43]}\n " && help
	[[ $TRACE4$TRACE6 = offoff ]] && red " ${T[${L}44]} "
	fi
	}

proxy(){
	settings(){
		# 设置为代理模式，如有 WARP+ 账户，修改 license 并升级
		green " ${T[${L}84]} "
		warp-cli --accept-tos register >/dev/null 2>&1
		[[ -n $LICENSE ]] && ( yellow " ${T[${L}35]} " &&
		warp-cli --accept-tos set-license "$LICENSE" >/dev/null 2>&1 && sleep 1 &&
		ACCOUNT=$(warp-cli --accept-tos account 2>/dev/null) &&
		[[ $ACCOUNT =~ Limited ]] && echo "$LICENSE" >/etc/wireguard/license && green " ${T[${L}62]} " ||
		red " ${T[${L}36]} " )
		if [[ $LUBAN = 1 ]]; then
			i=1; j=5; INTERFACE='--interface CloudflareWARP'
			yellow " $(eval echo "${T[${L}11]}")\n $(eval echo "${T[${L}12]}") "
			warp-cli --accept-tos add-excluded-route 0.0.0.0/0 >/dev/null 2>&1
			warp-cli --accept-tos add-excluded-route ::0/0 >/dev/null 2>&1
			warp-cli --accept-tos set-mode warp >/dev/null 2>&1
			warp-cli --accept-tos connect >/dev/null 2>&1
			warp-cli --accept-tos enable-always-on >/dev/null 2>&1
			sleep 5
			ip -4 rule add from 172.16.0.2 lookup 51820
			ip -4 route add default dev CloudflareWARP table 51820
			ip -4 rule add table main suppress_prefixlength 0
			ip4_info
			until [[ -n $IP4 ]]
			do	(( i++ )) || true
				yellow " $(eval echo "${T[${L}12]}") "
				warp-cli --accept-tos disconnect >/dev/null 2>&1
				warp-cli --accept-tos disable-always-on >/dev/null 2>&1
				ip -4 rule delete from 172.16.0.2 lookup 51820
				ip -4 rule delete table main suppress_prefixlength 0
				sleep 2
				warp-cli --accept-tos connect >/dev/null 2>&1
				warp-cli --accept-tos enable-always-on >/dev/null 2>&1
				sleep 5
				ip -4 rule add from 172.16.0.2 lookup 51820
				ip -4 route add default dev CloudflareWARP table 51820
				ip -4 rule add table main suppress_prefixlength 0
				ip4_info
				if [[ $i = "$j" ]]; then
					warp-cli --accept-tos disconnect >/dev/null 2>&1
					warp-cli --accept-tos disable-always-on >/dev/null 2>&1
					ip -4 rule delete from 172.16.0.2 lookup 51820
					ip -4 rule delete table main suppress_prefixlength 0
					red " $(eval echo "${T[${L}13]}") " && exit 1
				fi
			done
			green " ${T[${L}14]} "
		else
			warp-cli --accept-tos set-mode proxy >/dev/null 2>&1
			warp-cli --accept-tos set-proxy-port "$PORT" >/dev/null 2>&1
			warp-cli --accept-tos connect >/dev/null 2>&1
			warp-cli --accept-tos enable-always-on >/dev/null 2>&1
			sleep 2 && [[ ! $(ss -nltp) =~ 'warp-svc' ]] && red " ${T[${L}87]} " && exit 1 || green " $(eval echo "${T[${L}86]}") "
		fi
		}
	
	# 禁止安装的情况。重复安装，非 AMD64 CPU 架构，IPv4 是 WARP
	[[ $CLIENT -ge 2 ]] && red " ${T[${L}85]} " && exit 1
	[[ $ARCHITECTURE != amd64 ]] && red " ${T[${L}101]} " && exit 1
	[[ $TRACE4 != off ]] && red " ${T[${L}95]} " && exit 1

 	# 安装 WARP Linux Client
	input_license
	[[ $LUBAN != 1 ]] && input_port
	start=$(date +%s)
	mkdir -p /etc/wireguard/ >/dev/null 2>&1
	if [[ $CLIENT = 0 ]]; then green " ${T[${L}83]} "
		if [[ $SYSTEM = CentOS ]]; then
			rpm -ivh http://pkg.cloudflareclient.com/cloudflare-release-el8.rpm >/dev/null 2>&1
			#  CentOS 7，需要用 Cloudflare CentOS 8 的库以安装 Client，并在线编译升级 C 运行库 Glibc 2.28
			if	[[ $(expr "$SYS" : '.*\s\([0-9]\{1,\}\)\.*') = 7 && ! $(strings /lib64/libc.so.6 ) =~ GLIBC_2.28 ]]; then
				{ wget -O /usr/bin/make https://github.com/fscarmen/warp/releases/download/Glibc/make
				wget https://github.com/fscarmen/warp/releases/download/Glibc/glibc-2.28.tar.gz
				tar -xzvf glibc-2.28.tar.gz; }&
				sed -i "s/\$releasever/8/g" /etc/yum.repos.d/cloudflare.repo
				${PACKAGE_UPDATE[int]}; ${PACKAGE_INSTALL[int]} cloudflare-warp
				${PACKAGE_INSTALL[int]} gcc bison make centos-release-scl
				${PACKAGE_INSTALL[int]} devtoolset-8-gcc devtoolset-8-gcc-c++ devtoolset-8-binutils
				source /opt/rh/devtoolset-8/enable
				wait
				cd ./glibc-2.28/build
				../configure --prefix=/usr --disable-profile --enable-add-ons --with-headers=/usr/include --with-binutils=/usr/bin
				make install
				cd ../..; rm -rf glibc-2.28*
			else	${PACKAGE_UPDATE[int]}; ${PACKAGE_INSTALL[int]} cloudflare-warp
			fi

		else 	${PACKAGE_UPDATE[int]}; ${PACKAGE_INSTALL[int]} lsb-release
			[[ $SYSTEM = Debian && ! $(type -P gpg 2>/dev/null) ]] && ${PACKAGE_INSTALL[int]} gnupg
			[[ $SYSTEM = Debian && ! $(apt list 2>/dev/null | grep apt-transport-https ) =~ installed ]] && ${PACKAGE_INSTALL[int]} apt-transport-https
			if	[[ $(echo $SYS | sed "s/[^0-9.]//g" | cut -d. -f1) != 18 ]]; then
				curl https://pkg.cloudflareclient.com/pubkey.gpg | apt-key add -
				echo "deb http://pkg.cloudflareclient.com/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/cloudflare-client.list
			# Ubuntu 18.04 (Bionic)，需要欺骗系统为 20.04 (Focal)，以安装 Client
			else	curl https://pkg.cloudflare.com/cloudflare-main.gpg -o /usr/share/keyrings/cloudflare-main.gpg
				echo 'deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/ focal main' | tee /etc/apt/sources.list.d/cloudflare-main.list
			fi
			${PACKAGE_UPDATE[int]}; ${PACKAGE_INSTALL[int]} cloudflare-warp
		fi
		[[ $(systemctl is-active warp-svc) != active ]] && ( systemctl start warp-svc; sleep 2 )
		settings

	elif [[ $CLIENT = 2 && $(warp-cli --accept-tos status 2>/dev/null) =~ 'Registration missing' ]]; then settings

	else red " ${T[${L}85]} " 
	fi

	# 创建再次执行的软链接快捷方式，再次运行可以用 warp 指令,设置默认语言
	mv -f menu.sh /etc/wireguard >/dev/null 2>&1
	chmod +x /etc/wireguard/menu.sh >/dev/null 2>&1
	ln -sf /etc/wireguard/menu.sh /usr/bin/warp && green " ${T[${L}38]} "
	echo "$L" >/etc/wireguard/language

	# 结果提示，脚本运行时间，次数统计
	ACCOUNT=$(warp-cli --accept-tos account 2>/dev/null)
	if [[ $ACCOUNT =~ 'Limited' ]]; then
		QUOTA=$(expr "$ACCOUNT" : '.*Quota:\s\([0-9]\{1,\}\)\s.*')
		[[ $QUOTA -gt 10000000000000 ]] && QUOTA="$((QUOTA/1000000000000)) TiB" ||  QUOTA="$((QUOTA/1000000000)) GiB"
		AC='+'
	fi

	if [[ $LUBAN = 1 ]]; then
		[[ $L = C ]] && COUNTRY4=$(translate "$COUNTRY4")
		end=$(date +%s)
		red "\n==============================================================\n"
		green " $(eval echo "${T[${L}94]}")\n $(eval echo "${T[${L}169]}") "

	else	proxy_info
		end=$(date +%s)
		red "\n==============================================================\n"
		green " $(eval echo "${T[${L}94]}")\n $(eval echo "${T[${L}27]}") "
	fi
	[[ $ACCOUNT =~ 'Limited' ]] && green " ${T[${L}63]}：$QUOTA "
	red "\n==============================================================\n"
	yellow " ${T[${L}43]}\n " && help
	}

# iptables+dnsmasq+ipset 方案，IPv6 only 不适用
stream_solution(){
	[[ $m = 0 ]] && red " ${T[${L}147]} " && exit 1

	red "\n=============================================================="
	yellow " ${T[${L}139]}\n "
	green " 1.${T[${L}48]} "
	[[ $OPTION != e ]] && green " 2.${T[${L}49]} " || green " 2.${T[${L}76]} "
	red "=============================================================="
	reading " ${T[${L}50]} " IPTABLES
	case "$IPTABLES" in
		1 ) CONF=${CONF1[m]}; ANEMONE=1; install;;
		2 ) [[ $OPTION != e ]] && menu || exit;;
		* ) red " ${T[${L}51]} [1-2]"; sleep 1; stream_solution;;
	esac
	}

# wireproxy 方案
wireproxy_solution(){
	ss -nltp | grep -q wireproxy && red " ${T[${L}166]} " && exit 1
	
	red "\n=============================================================="
	yellow " ${T[${L}165]}\n "
	green " 1.${T[${L}48]} "
	[[ $OPTION != w ]] && green " 2.${T[${L}49]} " || green " 2.${T[${L}76]} "
	red "=============================================================="
	reading " ${T[${L}50]} " WIREPROXY_CHOOSE
	case "$WIREPROXY_CHOOSE" in
		1 ) OCTEEP=1; install;;
		2 ) [[ $OPTION != w ]] && menu || exit;;
		* ) red " ${T[${L}51]} [1-2]"; sleep 1; wireproxy_solution;;
	esac
	}

# 免费 WARP 账户升级 WARP+ 账户
update(){
	wgcf_account(){
	[[ $TRACE4$TRACE6 =~ plus ]] && red " ${T[${L}58]} " && exit 1
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
	[[ $(curl -ks4 https://www.cloudflare.com/cdn-cgi/trace | grep warp | sed "s/warp=//g") = plus || $(curl -ks6 https://www.cloudflare.com/cdn-cgi/trace | grep warp | sed "s/warp=//g") = plus ]] &&
	green " ${T[${L}62]}\n ${T[${L}25]}：$(grep 'Device name' /etc/wireguard/info.log | awk '{ print $NF }')\n ${T[${L}63]}：$(grep Quota /etc/wireguard/info.log | awk '{ print $(NF-1), $NF }')" ) || red " ${T[${L}36]} ";;

	2 ) input_url
	[[ $CONFIRM = [Yy] ]] && (echo "$TEAMS" > /etc/wireguard/info.log 2>&1
	teams_change
	wg-quick down wgcf >/dev/null 2>&1; net
	[[ $(curl -ks4 https://www.cloudflare.com/cdn-cgi/trace | grep warp | sed "s/warp=//g") = plus || $(curl -ks6 https://www.cloudflare.com/cdn-cgi/trace | grep warp | sed "s/warp=//g") = plus ]] && green " ${T[${L}128]} ");;

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
	
	wireproxy_account(){
	[[ $(eval echo "\$(curl -sx socks5h://localhost:$(ss -nltp | grep wireproxy | grep -oP '127.0*\S+' | cut -d: -f2) https://www.cloudflare.com/cdn-cgi/trace)") =~ plus ]] && red " ${T[${L}58]} " && exit 1
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
	sed -i "s#PrivateKey.*#PrivateKey = $(grep "PrivateKey.*" /etc/wireguard/wgcf.conf | sed "s#PrivateKey = ##g")#g" proxy.conf
	systemctl restart wireproxy
	[[ $(eval echo "\$(curl -sx socks5h://localhost:$(ss -nltp | grep wireproxy | grep -oP '127.0*\S+' | cut -d: -f2) https://www.cloudflare.com/cdn-cgi/trace)") =~ plus ]] &&
	green " ${T[${L}62]}\n ${T[${L}25]}：$(grep 'Device name' /etc/wireguard/info.log | awk '{ print $NF }')\n ${T[${L}63]}：$(grep Quota /etc/wireguard/info.log | awk '{ print $(NF-1), $NF }')" ) || red " ${T[${L}36]} ";;

	2 ) input_url
	[[ $CONFIRM = [Yy] ]] && (echo "$TEAMS" > /etc/wireguard/info.log 2>&1
	sed -i "s#PrivateKey.*#PrivateKey = $PRIVATEKEY#g" /etc/wireguard/proxy.conf
	systemctl restart wireproxy
	[[ $(eval echo "\$(curl -sx socks5h://localhost:$(ss -nltp | grep wireproxy | grep -oP '127.0*\S+' | cut -d: -f2) https://www.cloudflare.com/cdn-cgi/trace)") =~ plus ]] && green " ${T[${L}128]} ");;

	* ) red " ${T[${L}51]} [1-2] "; sleep 1; update
	esac
	}
	# 根据 WARP interface 、 Client 和 WirePorxy 的安装情况判断升级的对象
	INSTALL_CHECK=("wg-quick" "warp-cli" "wireproxy")
	CASE_RESAULT=("0 0 0"		"0 0 1"			"0 1 0"			"0 1 1"			"1 0 0"			"1 0 1"			"1 1 0"			"1 1 1")
	SHOW_CHOOSE=("${T[${L}150]}"	""			""			"${T[${L}151]}"		""			"${T[${L}152]}"		"${T[${L}153]}"		"${T[${L}154]}")
	ACCOUNT1=(""			"wireproxy_account"	"client_account"	"client_account"	"wgcf_account"		"wgcf_account"		"wgcf_account"		"wgcf_account")
	ACCOUNT2=(""			"" 			"" 			"wireproxy_account" 	""			"wireproxy_account" 	"client_account" 	"client_account")
	ACCOUNT3=(""			"" 			""			""			""			""			""			"wireproxy_account")

	for ((c=0; c<${#INSTALL_CHECK[@]}; c++)); do
		type -P ${INSTALL_CHECK[c]} >/dev/null 2>&1 && INSTALL_RESULT[c]=1 || INSTALL_RESULT[c]=0
	done

	for ((d=0; d<${#CASE_RESAULT[@]}; d++)); do
		[[ ${INSTALL_RESULT[@]} = "${CASE_RESAULT[d]}" ]] && break
	done

	case "$d" in
	0 ) red " ${T[${L}150]} " && exit 1;;
	1|2|4 ) ${ACCOUNT1[d]};;
	* ) yellow " ${SHOW_CHOOSE[d]} " && reading " ${T[${L}50]} " MODE
		case "$MODE" in
		[1-3] ) $(eval echo "\${ACCOUNT$MODE[d]}");;
		* ) red " ${T[${L}51]} [1-3] "; sleep 1; update;;
		esac;;
	esac
}

# 判断当前 WARP 网络接口及 Client 的运行状态，并对应的给菜单和动作赋值
menu_setting(){
	if [[ "$CLIENT" -gt 1 || "$WIREPROXY" -gt 1 ]]; then
		[[ "$CLIENT" -lt 3 ]] && OPTION1="${T[${L}88]}" || OPTION1="${T[${L}89]}"
		[[ "$WIREPROXY" -lt 3 ]] && OPTION2="${T[${L}163]}" || OPTION2="${T[${L}164]}"
		OPTION3="${T[${L}143]}"; OPTION4="${T[${L}78]}"

		ACTION1(){ proxy_onoff; }; ACTION2(){ wireproxy_onoff; }; ACTION3(){ change_port; }; ACTION4(){ update; };

	else check_stack
	case "$m" in
	[0-2] ) NATIVE=("IPv6 only"	"IPv4 only"	"${T[${L}69]}")
		CONF1=("014"		"104"		"114")
		CONF2=("016"		"106"		"116")
		CONF3=("01D"		"10D"		"11D")
		OPTION1="$(eval echo "${T[${L}66]}")"; OPTION2="$(eval echo "${T[${L}67]}")"; OPTION3="$(eval echo "${T[${L}68]}")"; OPTION4="${T[${L}71]}"
		ACTION1(){ CONF=${CONF1[m]}; install; }; ACTION2(){ CONF=${CONF2[m]}; install; }; ACTION3(){ CONF=${CONF3[m]}; install; }; ACTION4(){ OPTION=o; net; };;
	
	* )	OPTION1="$(eval echo "${T[${L}141]}")"; OPTION2="$(eval echo "${T[${L}142]}")"; OPTION3="${T[${L}78]}"; OPTION4="${T[${L}77]}"
		ACTION1(){ stack_switch; }; ACTION2(){ stack_switch; }; ACTION3(){ update; }; ACTION4(){ onoff; };;
	esac
	fi
	
	[[ -e /etc/dnsmasq.d/warp.conf ]] && IPTABLE_INSTALLED="${T[${L}92]}"
	
	OPTION5="$CLIENT_INSTALLED${T[${L}82]}"; OPTION6="${T[${L}123]}"; OPTION7="${T[${L}72]}"; OPTION8="${T[${L}74]}"; OPTION9="${T[${L}73]}"; OPTION10="${T[${L}75]}";
	OPTION11="${T[${L}80]}"; OPTION12="$IPTABLE_INSTALLED${T[${L}138]}"; OPTION13="$WIREPROXY_INSTALLED${T[${L}148]}"; OPTION14="$CLIENT_INSTALLED${T[${L}168]}"; OPTION0="${T[${L}76]}"

	ACTION5(){ proxy; }; ACTION6(){ change_ip; }; ACTION7(){ uninstall; }; ACTION8(){ plus; }; ACTION9(){ bbrInstall; }; ACTION10(){ ver; }; 
	ACTION11(){ bash <(curl -sSL https://raw.githubusercontent.com/fscarmen/warp_unlock/main/unlock.sh) -$L; }; 
	ACTION12(){ ANEMONE=1 ;install; }; 
	ACTION13(){ OCTEEP=1; install; };
	ACTION14(){ LUBAN=1; proxy; };
	ACTION0(){ exit; }
	}

# 显示菜单
menu(){
	grep -sq 'Device name' /etc/wireguard/info.log 2>/dev/null && TYPE='+' && PLUSINFO="${T[${L}25]}：$(grep 'Device name' /etc/wireguard/info.log 2>/dev/null | awk '{ print $NF }')" || TYPE=' Teams'
	
	clear
	yellow " ${T[${L}16]} "
	red "======================================================================================================================\n"
	green " ${T[${L}17]}：$VERSION  ${T[${L}18]}：${T[${L}1]}\n ${T[${L}19]}：\n	${T[${L}20]}：$SYS\n	${T[${L}21]}：$(uname -r)\n	${T[${L}22]}：$ARCHITECTURE\n	${T[${L}23]}：$VIRT "
	green "	IPv4：$WAN4 $WARPSTATUS4 $COUNTRY4  $ASNORG4 "
	green "	IPv6：$WAN6 $WARPSTATUS6 $COUNTRY6  $ASNORG6 "
	[[ $TRACE4$TRACE6 =~ plus ]] && green "	$(eval echo "${T[${L}114]}")	$PLUSINFO "
	[[ $TRACE4$TRACE6 =~ on ]] && green "	${T[${L}115]} " 	
	[[ $PLAN != 3 ]] && green "	${T[${L}116]} "
	[[ $CLIENT = 0 ]] && green "	${T[${L}112]} "
	[[ $CLIENT = 2 ]] && green "	$(eval echo "${T[${L}113]}") "
	[[ $CLIENT = 3 ]] && green "	WARP$AC ${T[${L}24]}	$(eval echo "${T[${L}27]}") "
	[[ $CLIENT = 5 ]] && green "	WARP$AC ${T[${L}24]}	$(eval echo "${T[${L}169]}") "
	[[ $WIREPROXY = 0 ]] && green "	${T[${L}160]} "
	[[ $WIREPROXY = 2 ]] && green "	${T[${L}161]} "
	[[ $WIREPROXY = 3 ]] && green "	WARP$AC2 ${T[${L}159]}	$(eval echo "${T[${L}162]}") "	
 	red "\n======================================================================================================================\n"
	green " 1.  $OPTION1\n 2.  $OPTION2\n 3.  $OPTION3\n 4.  $OPTION4\n 5.  $OPTION5\n 6.  $OPTION6\n 7.  $OPTION7\n 8.  $OPTION8\n 9.  $OPTION9 \n 10. $OPTION10\n 11. $OPTION11\n 12. $OPTION12\n 13. $OPTION13\n 14. $OPTION14\n 0. $OPTION0\n "
	reading " ${T[${L}50]} " CHOOSE1
		case "$CHOOSE1" in
		1 ) ACTION1;; 2 ) ACTION2;; 3 ) ACTION3;; 4 ) ACTION4;; 5 ) ACTION5;;
		6 ) ACTION6;; 7 ) ACTION7;; 8 ) ACTION8;; 9 ) ACTION9;; 10 ) ACTION10;;
		11 ) ACTION11;; 12 ) ACTION12;; 13 ) ACTION13;; 14 ) ACTION14;;
		0 ) ACTION0;; * ) red " ${T[${L}51]} [0-10] "; sleep 1; menu;;
		esac
	}

# 传参选项 OPTION：1=为 IPv4 或者 IPv6 补全另一栈WARP; 2=安装双栈 WARP; u=卸载 WARP; b=升级内核、开启BBR及DD; o=WARP开关；p=刷 WARP+ 流量; 其他或空值=菜单界面
[[ $1 != '[option]' ]] && OPTION=$(tr '[:upper:]' '[:lower:]' <<< "$1")

# 参数选项 URL 或 License 或转换 WARP 单双栈

if [[ $2 != '[lisence]' ]]; then
	if [[ $2 =~ 'http' ]]; then LICENSETYPE=2 && URL=$2
	elif [[ $2 =~ ^[A-Z0-9a-z]{8}-[A-Z0-9a-z]{8}-[A-Z0-9a-z]{8}$ ]]; then LICENSETYPE=1 && LICENSE=$2
	elif [[ $2 = [46Dd] ]]; then SWITCHCHOOSE=$(tr '[:lower:]' '[:upper:]' <<< "$2")
	elif [[ $2 =~ ^[A-Za-z]{2}$ ]]; then EXPECT=$2
	fi
fi

# 自定义 WARP+ 设备名
NAME=$3

# 主程序运行 1/3
statistics_of_run-times
select_language
check_operating_system

# 设置部分后缀 1/3
case "$OPTION" in
h ) help; exit 0;;
p ) plus; exit 0;;
i ) change_ip; exit 0;;
esac

# 主程序运行 2/3
check_root_virt

# 设置部分后缀 2/3
case "$OPTION" in
b ) bbrInstall; exit 0;;
u ) uninstall; exit 0;;
v ) ver; exit 0;;
n ) net; exit 0;;
o ) onoff; exit 0;;
r ) proxy_onoff; exit 0;;
s ) stack_switch; exit 0;;
y ) wireproxy_onoff; exit 0;;
esac

# 主程序运行 3/3
check_dependencies
check_system_info
menu_setting

# 设置部分后缀 3/3
case "$OPTION" in
# 在已运行 Linux Client 前提下，不能安装 WARP IPv4 或者双栈网络接口。如已经运行 WARP ，参数 4,6,d 从原来的安装改为切换
[46d] )	if [[ -n $(wg 2>/dev/null) ]]; then
	SWITCHCHOOSE="$(tr '[:lower:]' '[:upper:]' <<< "$OPTION")"; OPTION='s'
	yellow " ${T[${L}79]} " && stack_switch
	else
		case "$OPTION" in
		4 ) [[ $CLIENT = [35] ]] && red " ${T[${L}110]} " && exit 1
		    CONF=${CONF1[m]};; 
		6 ) CONF=${CONF2[m]};;
		d ) [[ $CLIENT = [35] ]] && red " ${T[${L}110]} " && exit 1
		    CONF=${CONF3[m]};;
		esac
		install
	fi;;
c )	proxy;;
l )	LUBAN=1 && proxy;;
a )	update;;
e )	stream_solution;;
w )	wireproxy_solution;;
* )	menu;;
esac
