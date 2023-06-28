#!/usr/bin/env bash

# 当前脚本版本号和新增功能
VERSION=1.1.4

# IP API 服务商
IP_API=("http://ip-api.com/json/" "https://api.ip.sb/geoip" "https://ifconfig.co/json" "https://www.cloudflare.com/cdn-cgi/trace")
ISP=("isp" "isp" "asn_org")
IP=("query" "ip" "ip")

# 判断 Teams token 最少字符数
TOKEN_LENGTH=800

# 环境变量用于在Debian或Ubuntu操作系统中设置非交互式（noninteractive）安装模式
export DEBIAN_FRONTEND=noninteractive

trap "rm -f /tmp/warp-go*; exit 1" INT

E[0]="Language:\n  1.English (default) \n  2.简体中文"
C[0]="${E[0]}"
E[1]="1. Docking the warp-go official account pool api; 2. Change non-global from ipv4 only to dualstacks; 3. Fix the bug that the native IPv6 cannot login when using dualstacks; 4. Update the Best-enpoint app; 5. Change ip api"
C[1]="1. 对接 warp-go 官方账户池 api; 2. 非全局从ipv4 only 改为双栈; 3. 修复双栈时使用原生 IPv6 不能登陆的 bug; 4. 更新最佳 Endpoint 应用; 5. 更换 ip api"
E[2]="warp-go h (help)\n warp-go o (temporary warp-go switch)\n warp-go u (uninstall WARP web interface and warp-go)\n warp-go v (sync script to latest version)\n warp-go i (replace IP with Netflix support)\n warp-go 4/6 ( WARP IPv4/IPv6 single-stack)\n warp-go d (WARP dual-stack)\n warp-go n (WARP IPv4 non-global)\n warp-go g (WARP global/non-global switching)\n warp-go e (output wireguard and sing-box configuration file)\n warp-go a (Change to Free, WARP+ or Teams account)"
C[2]="warp-go h (帮助）\n warp-go o (临时 warp-go 开关)\n warp-go u (卸载 WARP 网络接口和 warp-go)\n warp-go v (同步脚本至最新版本)\n warp-go i (更换支持 Netflix 的IP)\n warp-go 4/6 (WARP IPv4/IPv6 单栈)\n warp-go d (WARP 双栈)\n warp-go n (WARP IPv4 非全局)\n warp-go g (WARP 全局 / 非全局相互切换)\n warp-go e (输出 wireguard 和 sing-box 配置文件)\n warp-go a (更换到 Free，WARP+ 或 Teams 账户)"
E[3]="This project is designed to add WARP network interface for VPS, using warp-go core, using various interfaces of CloudFlare-WARP, integrated wireguard-go, can completely replace WGCF. Save Hong Kong, Toronto and other VPS, can also get WARP IP. Thanks again @CoiaPrant and his team. Project address: https://gitlab.com/ProjectWARP/warp-go/-/tree/master/"
C[3]="本项目专为 VPS 添加 WARP 网络接口，使用 wire-go 核心程序，利用CloudFlare-WARP 的各类接口，集成 wireguard-go，可以完全替代 WGCF。 救活了香港、多伦多等 VPS 也可以获取 WARP IP。再次感谢 @CoiaPrant 及其团队。项目地址: https://gitlab.com/ProjectWARP/warp-go/-/tree/master/"
E[4]="Choose:"
C[4]="请选择:"
E[5]="You must run the script as root. You can type sudo -i and then download and run it again. Feedback:[https://github.com/fscarmen/warp/issues]"
C[5]="必须以root方式运行脚本，可以输入 sudo -i 后重新下载运行，问题反馈:[https://github.com/fscarmen/warp/issues]"
E[6]="This script only supports Debian, Ubuntu, CentOS, Arch or Alpine systems, Feedback: [https://github.com/fscarmen/warp/issues]"
C[6]="本脚本只支持 Debian、Ubuntu、CentOS、Arch 或 Alpine 系统,问题反馈:[https://github.com/fscarmen/warp/issues]"
E[7]="Curren operating system is \$SYS.\\\n The system lower than \$SYSTEM \${MAJOR[int]} is not supported. Feedback: [https://github.com/fscarmen/warp/issues]"
C[7]="当前操作是 \$SYS\\\n 不支持 \$SYSTEM \${MAJOR[int]} 以下系统,问题反馈:[https://github.com/fscarmen/warp/issues]"
E[8]="Install dependence-list:"
C[8]="安装依赖列表:"
E[9]="Step 3/3: Best MTU and Endpoint found."
C[9]="进度 3/3: 已找到最佳 MTU 和 Endpoint"
E[10]="No suitable solution was found for modifying the warp-go configuration file warp.conf and the script aborted. When you see this message, please send feedback on the bug to:[https://github.com/fscarmen/warp/issues]"
C[10]="没有找到适合的方案用于修改 warp-go 配置文件 warp.conf，脚本中止。当你看到此信息，请把该 bug 反馈至:[https://github.com/fscarmen/warp/issues]"
E[11]="Warp-go is not installed yet."
C[11]="还没有安装 warp-go"
E[12]="To install, press [y] and other keys to exit:"
C[12]="如需安装，请按[y]，其他键退出:"
E[13]="\$(date +'%F %T') Try \${i}. Failed. IPv\$NF: \$WAN  \$COUNTRY  \$ASNORG. Retry after \${l} seconds. Brush ip runing time:\$DAY days \$HOUR hours \$MIN minutes \$SEC seconds"
C[13]="\$(date +'%F %T') 尝试第\${i}次，解锁失败，IPv\$NF: \$WAN  \$COUNTRY  \$ASNORG，\${l}秒后重新测试，刷 IP 运行时长: \$DAY 天 \$HOUR 时 \$MIN 分 \$SEC 秒"
E[14]="1. Brush WARP IPv4 (default)\n 2. Brush WARP IPv6"
C[14]="1. 刷 WARP IPv4 (默认)\n 2. 刷 WARP IPv6"
E[15]="The current Netflix region is:\$REGION. To unlock the current region please press [y]. For other addresses please enter two regional abbreviations \(e.g. hk,sg, default:\$REGION\):"
C[15]="当前 Netflix 地区是:\$REGION，需要解锁当前地区请按 y , 如需其他地址请输入两位地区简写 \(如 hk ,sg，默认:\$REGION\):"
E[16]="\$(date +'%F %T') Region: \$REGION Done. IPv\$NF: \$WAN  \$COUNTRY  \$ASNORG. Retest after 1 hour. Brush ip runing time:\$DAY days \$HOUR hours \$MIN minutes \$SEC seconds"
C[16]="\$(date +'%F %T') 区域 \$REGION 解锁成功，IPv\$NF: \$WAN  \$COUNTRY  \$ASNORG，1 小时后重新测试，刷 IP 运行时长: \$DAY 天 \$HOUR 时 \$MIN 分 \$SEC 秒"
E[17]="WARP network interface and warp-go have been completely removed!"
C[17]="WARP 网络接口及 warp-go 已彻底删除!"
E[18]="Successfully synchronized the latest version"
C[18]="成功！已同步最新脚本，版本号"
E[19]="New features"
C[19]="功能新增"
E[20]="Maximum \${j} attempts to get WARP IP..."
C[20]="后台获取 WARP IP 中, 最大尝试\${j}次……"
E[21]="Can't find the account file: /opt/warp-go/warp.conf.You can uninstall and reinstall it."
C[21]="找不到账户文件：/opt/warp-go/warp.conf，可以卸载后重装"
E[22]="Current Teams account is not available. Switch back to free account automatically."
C[22]="当前 Teams 账户不可用，自动切换回免费账户"
E[23]="Failed more than \${j} times, script aborted. Feedback: [https://github.com/fscarmen/warp/issues]"
C[23]="失败已超过\${j}次，脚本中止，问题反馈:[https://github.com/fscarmen/warp/issues]"
E[24]="non-"
C[24]="非"
E[25]="Successfully got WARP \$ACCOUNT_TYPE network.\\\n Running in \${GLOBAL_TYPE}global mode."
C[25]="已成功获取 WARP \$ACCOUNT_TYPE 网络\\\n 运行在 \${GLOBAL_TYPE}全局 模式"
E[26]="WARP+ quota"
C[26]="剩余流量"
E[27]="WARP is turned off. It could be turned on again by [warp-go o]"
C[27]="已暂停 WARP，再次开启可以用 warp-go o"
E[28]="WARP Non-global mode cannot switch between single and double stacks."
C[28]="WARP 非全局模式下不能切换单双栈"
E[29]="To switch to global mode, press [y] and other keys to exit:"
C[29]="如需更换为全局模式，请按[y]，其他键退出:"
E[30]="Cannot switch to the same form as the current one."
C[30]="不能切换为当前一样的形态"
E[31]="Switch \${WARP_BEFORE[m]} to \${WARP_AFTER1[m]}"
C[31]="\${WARP_BEFORE[m]} 转为 \${WARP_AFTER1[m]}"
E[32]="Switch \${WARP_BEFORE[m]} to \${WARP_AFTER2[m]}"
C[32]="\${WARP_BEFORE[m]} 转为 \${WARP_AFTER2[m]}"
E[33]="WARP network interface can be switched as follows:\\\n 1. \${OPTION[1]}\\\n 2. \${OPTION[2]}\\\n 0. Exit script"
C[33]="WARP 网络接口可以切换为以下方式:\\\n 1. \${OPTION[1]}\\\n 2. \${OPTION[2]}\\\n 0. 退出脚本"
E[34]="Please enter the correct number"
C[34]="请输入正确数字"
E[35]="Checking VPS infomation..."
C[35]="检查环境中……"
E[36]="The TUN module is not loaded. You should turn it on in the control panel. Ask the supplier for more help. Feedback: [https://github.com/fscarmen/warp/issues]"
C[36]="没有加载 TUN 模块，请在管理后台开启或联系供应商了解如何开启，问题反馈:[https://github.com/fscarmen/warp/issues]"
E[37]="Curren architecture \$(uname -m) is not supported. Feedback: [https://github.com/fscarmen/warp/issues]"
C[37]="当前架构 \$(uname -m) 暂不支持,问题反馈:[https://github.com/fscarmen/warp/issues]"
E[38]="If there is a WARP+ License, please enter it, otherwise press Enter to continue:"
C[38]="如有 WARP+ License 请输入，没有可回车继续:"
E[39]="Input errors up to 5 times.The script is aborted."
C[39]="输入错误达5次，脚本退出"
E[40]="License should be 26 characters, please re-enter WARP+ License. Otherwise press Enter to continue. \(\${i} times remaining\):"
C[40]="License 应为26位字符，请重新输入 WARP+ License，没有可回车继续\(剩余\${i}次\):"
E[41]="Please customize the device name (Default is [warp-go] if left blank):"
C[41]="请自定义设备名 (如果不输入，默认为 [warp-go]):"
E[42]="Please Input WARP+ license:"
C[42]="请输入WARP+ License:"
E[43]="License should be 26 characters, please re-enter WARP+ License. Otherwise press Enter to continue. \(\${i} times remaining\): "
C[43]="License 应为26位字符,请重新输入 WARP+ License \(剩余\${i}次\): "
E[44]="Please enter the Teams Token (You can easily available at https://web--public--warp-team-api--coia-mfs4.code.run. Or use the one provided by the script if left blank):"
C[44]="请输入 Teams Token (可通过 https://web--public--warp-team-api--coia-mfs4.code.run 轻松获取，如果留空，则使用脚本提供的):"
E[45]="Token error, please re-enter Teams token \(remaining \${i} times\):"
C[45]="Token 错误,请重新输入 Teams token \(剩余\${i}次\):"
E[46]="Current account type is: \$ACCOUNT_TYPE\\\t \$PLUS_QUOTA\\\n \$CHANGE_TYPE"
C[46]="当前账户类型是: \$ACCOUNT_TYPE\\\t \$PLUS_QUOTA\\\n \$CHANGE_TYPE"
E[47]="1. Continue using the free account without changing.\n 2. Change to WARP+ account.\n 3. Change to Teams account. (You can easily available at https://web--public--warp-team-api--coia-mfs4.code.run. Or use the one provided by the script if left blank)\n 0. Return to the main menu."
C[47]="1. 继续使用 free 账户，不变更\n 2. 变更为 WARP+ 账户\n 3. 变更为 Teams 账户 (可通过 https://web--public--warp-team-api--coia-mfs4.code.run 轻松获取，如果留空，则使用脚本提供的)\n 0. 返回主菜单"
E[48]="1. Change to free account.\n 2. Change to WARP+ account.\n 3. Change to another WARP Teams account. (You can easily available at https://web--public--warp-team-api--coia-mfs4.code.run. Or use the one provided by the script if left blank)\n 0. Return to the main menu."
C[48]="1. 变更为 free 账户\n 2. 变更为 WARP+ 账户\n 3. 更换为另一个 Teams 账户 (可通过 https://web--public--warp-team-api--coia-mfs4.code.run 轻松获取，如果留空，则使用脚本提供的)\n 0. 返回主菜单"
E[49]="1. Change to free account.\n 2. Change to another WARP+ account.\n 3. Change to Teams account. (You can easily available at https://web--public--warp-team-api--coia-mfs4.code.run. Or use the one provided by the script if left blank)\n 0. Return to the main menu."
C[49]="1. 变更为 free 账户\n 2. 变更为另一个 WARP+ 账户\n 3. 变更为 Teams 账户 (可通过 https://web--public--warp-team-api--coia-mfs4.code.run 轻松获取，如果留空，则使用脚本提供的)\n 0. 返回主菜单"
E[50]="Registration of WARP\${k} account failed, script aborted. Feedback: [https://github.com/fscarmen/warp/issues]"
C[50]="注册 WARP\${k} 账户失败，脚本中止，问题反馈: [https://github.com/fscarmen/warp/issues]"
E[51]="Warp-go not yet installed. No account registered. Script aborted. Feedback: [https://github.com/fscarmen/warp/issues]"
C[51]="warp-go 还没有安装，没有注册账户，脚本中止，问题反馈: [https://github.com/fscarmen/warp/issues]"
E[52]="Wireguard configuration file: /opt/warp-go/wgcf.conf\n"
C[52]="Wireguard 配置文件: /opt/warp-go/wgcf.conf\n"
E[53]="Warp-go installed. Script aborted. Feedback: [https://github.com/fscarmen/warp/issues]"
C[53]="warp-go 已安装，脚本中止，问题反馈: [https://github.com/fscarmen/warp/issues]"
E[54]="Is there a WARP+ or Teams account?\n  1. WARP+\n  2. Teams\n  3. Use free account (default)"
C[54]="如有 WARP+ 或 Teams 账户请选择\n  1. WARP+\n  2. Teams\n  3. 使用免费账户 (默认)"
E[55]="Please choose the priority:\n  1. IPv4\n  2. IPv6\n  3. Use initial settings (default)"
C[55]="请选择优先级别:\n  1. IPv4\n  2. IPv6\n  3. 使用 VPS 初始设置 (默认)"
E[56]="Download warp-go zip file unsuccessful. Script exits. Feedback: [https://github.com/fscarmen/warp/issues]"
C[56]="下载 warp-go 压缩文件不成功，脚本退出，问题反馈: [https://github.com/fscarmen/warp/issues]"
E[57]="Warp-go file does not exist, script exits. Feedback: [https://github.com/fscarmen/warp/issues]"
C[57]="Warp-go 文件不存在，脚本退出，问题反馈: [https://github.com/fscarmen/warp/issues]"
E[58]="Maximum \${j} attempts to registe WARP\${k} account..."
C[58]="注册 WARP\${k} 账户中, 最大尝试\${j}次……"
E[59]="Try \${i}"
C[59]="第\${i}次尝试"
E[60]="Step 1/3: Install dependencies..."
C[60]="进度 1/3: 安装系统依赖……"
E[61]="Step 2/3: Install warp-go..."
C[61]="进度 2/3: 已安装 warp-go"
E[62]="Congratulations! WARP \$ACCOUNT_TYPE has been turn on. Total time spent:\$(( end - start )) seconds.\\\n Number of script runs in the day: \$TODAY. Total number of runs: \$TOTAL."
C[62]="恭喜！WARP \$ACCOUNT_TYPE 已开启，总耗时:\$(( end - start ))秒\\\n 脚本当天运行次数: \$TODAY，累计运行次数：\$TOTAL"
E[63]="Warp-go installation failed. Feedback: [https://github.com/fscarmen/warp/issues]"
C[63]="warp-go 安装失败，问题反馈: [https://github.com/fscarmen/warp/issues]"
E[64]="Add WARP IPv4 global network interface for \${NATIVE[n]}, IPv4 priority \(bash warp-go.sh 4\)"
C[64]="为 \${NATIVE[n]} 添加 WARP IPv4 全局 网络接口，IPv4 优先 \(bash warp-go.sh 4\)"
E[65]="Add WARP IPv4 global network interface for \${NATIVE[n]}, IPv6 priority \(bash warp-go.sh 4\)"
C[65]="为 \${NATIVE[n]} 添加 WARP IPv4 全局 网络接口，IPv6 优先 \(bash warp-go.sh 4\)"
E[66]="Add WARP IPv6 global network interface for \${NATIVE[n]}, IPv4 priority \(bash warp-go.sh 6\)"
C[66]="为 \${NATIVE[n]} 添加 WARP IPv6 全局 网络接口，IPv4 优先 \(bash warp-go.sh 6\)"
E[67]="Add WARP IPv6 global network interface for \${NATIVE[n]}, IPv6 priority \(bash warp-go.sh 6\)"
C[67]="为 \${NATIVE[n]} 添加 WARP IPv6 全局 网络接口，IPv6 优先 \(bash warp-go.sh 6\)"
E[68]="Add WARP dual-stacks global network interface for \${NATIVE[n]}, IPv4 priority \(bash warp-go.sh d\)"
C[68]="为 \${NATIVE[n]} 添加 WARP 双栈 全局 网络接口，IPv4 优先 \(bash warp-go.sh d\)"
E[69]="Add WARP dual-stacks global network interface for \${NATIVE[n]}, IPv6 priority \(bash warp-go.sh d\)"
C[69]="为 \${NATIVE[n]} 添加 WARP 双栈 全局 网络接口，IPv6 优先 \(bash warp-go.sh d\)"
E[70]="Add WARP dual-stacks non-global network interface for \${NATIVE[n]}, IPv4 priority \(bash warp-go.sh n\)"
C[70]="为 \${NATIVE[n]} 添加 WARP 双栈 非全局 网络接口，IPv4 优先 \(bash warp-go.sh n\)"
E[71]="Add WARP dual-stacks non-global network interface for \${NATIVE[n]}, IPv6 priority \(bash warp-go.sh n\)"
C[71]="为 \${NATIVE[n]} 添加 WARP 双栈 非全局 网络接口，IPv6 优先 \(bash warp-go.sh n\)"
E[72]="Turn off warp-go (warp-go o)"
C[72]="关闭 warp-go (warp-go o)"
E[73]="Turn on warp-go (warp-go o)"
C[73]="打开 warp-go (warp-go o)"
E[74]="\${WARP_BEFORE[m]} switch to \${WARP_AFTER1[m]} \${SHORTCUT1[m]}"
C[74]="\${WARP_BEFORE[m]} 转为 \${WARP_AFTER1[m]} \${SHORTCUT1[m]}"
E[75]="\${WARP_BEFORE[m]} switch to \${WARP_AFTER2[m]} \${SHORTCUT2[m]}"
C[75]="\${WARP_BEFORE[m]} 转为 \${WARP_AFTER2[m]} \${SHORTCUT2[m]}"
E[76]="Switch to WARP \${GLOBAL_AFTER}global network interface  \(warp-go g\)"
C[76]="转为 WARP \${GLOBAL_AFTER}全局 网络接口  \(warp-go g\)"
E[77]="Change to Free, WARP+ or Teams account \(warp-go a\)"
C[77]="更换为 Free，WARP+ 或 Teams 账户 \(warp-go a\)"
E[78]="Change the WARP IP to support Netflix (warp-go i)"
C[78]="更换支持 Netflix 的 IP (warp-go i)"
E[79]="Export wireguard and sing-box configuration file (warp-go e)"
C[79]="输出 wireguard 和 sing-box 配置文件 (warp-go e)"
E[80]="Uninstall the WARP interface and warp-go (warp-go u)"
C[80]="卸载 WARP 网络接口和 warp-go (warp-go u)"
E[81]="Exit"
C[81]="退出脚本"
E[82]="Sync the latest version"
C[82]="同步最新版本"
E[83]="Device Name"
C[83]="设备名"
E[84]="Version"
C[84]="脚本版本"
E[85]="New features"
C[85]="功能新增"
E[86]="System infomation"
C[86]="系统信息"
E[87]="Operating System"
C[87]="当前操作系统"
E[88]="Kernel"
C[88]="内核"
E[89]="Architecture"
C[89]="处理器架构"
E[90]="Virtualization"
C[90]="虚拟化"
E[91]="WARP \$TYPE Interface is on"
C[91]="WARP \$TYPE 网络接口已开启"
E[92]="Running in \${GLOBAL_TYPE}global mode"
C[92]="运行在 \${GLOBAL_TYPE}全局 模式"
E[93]="WARP network interface is not turned on"
C[93]="WARP 网络接口未开启"
E[94]="Native dualstack"
C[94]="原生双栈"
E[95]="Run again with warp-go [option] [lisence], such as"
C[95]="再次运行用 warp-go [option] [lisence]，如"
E[96]="dualstack"
C[96]="双栈"
E[97]="The account type is Teams and does not support changing IP\n 1. Change to free (default)\n 2. Change to plus\n 3. Quit"
C[97]="账户类型为 Teams，不支持更换 IP\n 1. 更换为 free (默认)\n 2. 更换为 plus\n 3. 退出"
E[98]="Non-global"
C[98]="非全局"
E[99]="global"
C[99]="全局"
E[100]="IPv\$PRIO priority"
C[100]="IPv\$PRIO 优先"
E[101]="Sing-box configuration file: /opt/warp-go/singbox.json\n"
C[101]="Sing-box 配置文件: /opt/warp-go/singbox.json\n"
E[102]="WAN interface network protocol must be [static] on OpenWrt."
C[102]="OpenWrt 系统的 WAN 接口的网络传输协议必须为 [静态地址]"
E[103]="Unlimited"
C[103]="无限制"
E[104]="Failed to get the registration information from API. Script exits. Feedback: [https://github.com/fscarmen/warp/issues]"
C[104]="API 获取不到注册信息，脚本退出，问题反馈: [https://github.com/fscarmen/warp/issues]"
E[105]="upgrade successful."
C[105]="升级成功"
E[106]="upgrade failed. The free account will remain in use."
C[106]="升级失败，将保持使用 free 账户。"

# 自定义字体彩色，read 函数，友道翻译函数
warning() { echo -e "\033[31m\033[01m$*\033[0m"; }  # 红色
error() { echo -e "\033[31m\033[01m$*\033[0m"; rm -f /tmp/warp-go*; exit 1; }  # 红色
info() { echo -e "\033[32m\033[01m$*\033[0m"; }   # 绿色
hint() { echo -e "\033[33m\033[01m$*\033[0m"; }   # 黄色
reading() { read -rp "$(info "$1")" "$2"; }
text() { eval echo "\${${L}[$*]}"; }
text_eval() { eval echo "\$(eval echo "\${${L}[$*]}")"; }
translate() { [ -n "$1" ] && curl -ksm8 "http://fanyi.youdao.com/translate?&doctype=json&type=EN2ZH_CN&i=${1//[[:space:]]/}" | cut -d \" -f18 2>/dev/null; }

# 脚本当天及累计运行次数统计
statistics_of_run-times() {
  local COUNT=$(curl --retry 2 -ksm2 "https://hits.seeyoufarm.com/api/count/incr/badge.svg?url=https%3A%2F%2Fraw.githubusercontent.com%2Ffscarmen%2Fwarp%2Fmain%2Fwarp-go.sh&count_bg=%2379C83D&title_bg=%23555555&icon=&icon_color=%23E7E7E7&title=hits&edge_flat=false" 2>&1 | grep -m1 -oE "[0-9]+[ ]+/[ ]+[0-9]+") &&
  TODAY=$(cut -d " " -f1 <<< "$COUNT") &&
  TOTAL=$(cut -d " " -f3 <<< "$COUNT")
}

# 选择语言，先判断 /opt/warp-go/language 里的语言选择，没有的话再让用户选择，默认英语。处理中文显示的问题
select_language() {
  UTF8_LOCALE=$(locale -a 2>/dev/null | grep -iEm1 "UTF-8|utf8")
  [ -n "$UTF8_LOCALE" ] && export LC_ALL="$UTF8_LOCALE" LANG="$UTF8_LOCALE" LANGUAGE="$UTF8_LOCALE"

  case "$(cat /opt/warp-go/language 2>&1)" in
    E )
      L=E
      ;;
    C )
      L=C
      ;;
    * )
      L=E && [[ -z "$OPTION" || "$OPTION" = [ahvi46d] ]] && hint "\n $(text 0) \n" && reading " $(text 4) " LANGUAGE
      [ "$LANGUAGE" = 2 ] && L=C
  esac
}

# 必须以root运行脚本
check_root_virt() {
  [ "$(id -u)" != 0 ] && error " $(text 5) "

  # 判断虚拟化，选择 Wireguard内核模块 还是 Wireguard-Go
  VIRT=$(systemd-detect-virt 2>/dev/null | tr 'A-Z' 'a-z')
  [ -z "$VIRT" ] && VIRT=$(hostnamectl 2>/dev/null | tr 'A-Z' 'a-z' | grep virtualization | sed "s/.*://g")
}

# 多方式判断操作系统，试到有值为止。只支持 Debian 9/10/11、Ubuntu 18.04/20.04/22.04 或 CentOS 7/8 ,如非上述操作系统，退出脚本
check_operating_system() {
  if [ -s /etc/os-release ]; then
    SYS="$(grep -i pretty_name /etc/os-release | cut -d \" -f2)"
  elif [ $(type -p hostnamectl) ]; then
    SYS="$(hostnamectl | grep -i system | cut -d : -f2)"
  elif [ $(type -p lsb_release) ]; then
    SYS="$(lsb_release -sd)"
  elif [ -s /etc/lsb-release ]; then
    SYS="$(grep -i description /etc/lsb-release | cut -d \" -f2)"
  elif [ -s /etc/redhat-release ]; then
    SYS="$(grep . /etc/redhat-release)"
  elif [ -s /etc/issue ]; then
    SYS="$(grep . /etc/issue | cut -d '\' -f1 | sed '/^[ ]*$/d')"
  fi

  # 自定义 Alpine 系统若干函数
  alpine_warp_restart() { kill -15 $(pgrep warp-go) 2>/dev/null; /opt/warp-go/warp-go --config=/opt/warp-go/warp.conf; }
  alpine_wgcf_enable() { echo -e "/opt/warp-go/tun.sh\n/opt/warp-go/warp-go --config=/opt/warp-go/warp.conf" > /etc/local.d/warp-go.start; chmod +x /etc/local.d/warp-go.start; rc-update add local; }
  openwrt_wgcf_enable() { echo -e "@reboot /opt/warp-go/warp-go --config=/opt/warp-go/warp.conf" >> /etc/crontabs/root; }

  REGEX=("debian" "ubuntu" "centos|red hat|kernel|oracle linux|alma|rocky|amazon linux" "alpine" "arch linux" "openwrt")
  RELEASE=("Debian" "Ubuntu" "CentOS" "Alpine" "Arch" "OpenWrt")
  EXCLUDE=("bookworm")
  MAJOR=("9" "16" "7" "3" "" "")
  PACKAGE_UPDATE=("apt -y update" "apt -y update" "yum -y update" "apk update -f" "pacman -Sy" "opkg update")
  PACKAGE_INSTALL=("apt -y install" "apt -y install" "yum -y install" "apk add -f" "pacman -S --noconfirm" "opkg install")
  PACKAGE_UNINSTALL=("apt -y autoremove" "apt -y autoremove" "yum -y autoremove" "apk del -f" "pacman -Rcnsu --noconfirm" "opkg remove --force-depends")
  SYSTEMCTL_START=("systemctl start warp-go" "systemctl start warp-go" "systemctl start warp-go" "/opt/warp-go/warp-go --config=/opt/warp-go/warp.conf" "systemctl start warp-go" "/opt/warp-go/warp-go --config=/opt/warp-go/warp.conf")
  SYSTEMCTL_STOP=("systemctl stop warp-go" "systemctl stop warp-go" "systemctl stop warp-go" "kill -15 $(pgrep warp-go)" "systemctl stop warp-go" "kill -15 $(pgrep warp-go)")
  SYSTEMCTL_RESTART=("systemctl restart warp-go" "systemctl restart warp-go" "systemctl restart warp-go" "alpine_warp_restart" "systemctl restart wg-quick@wgcf" "alpine_warp_restart")
  SYSTEMCTL_ENABLE=("systemctl enable --now warp-go" "systemctl enable --now warp-go" "systemctl enable --now warp-go" "alpine_wgcf_enable" "systemctl enable --now warp-go")

  for ((int=0; int<${#REGEX[@]}; int++)); do
    [[ $(echo "$SYS" | tr 'A-Z' 'a-z') =~ ${REGEX[int]} ]] && SYSTEM="${RELEASE[int]}" && COMPANY="${COMPANY[int]}" && break
  done
  [ -z "$SYSTEM" ] && error "$(text 6)"
  [ "$SYSTEM" = OpenWrt ] && [[ ! $(uci show network.wan.proto 2>/dev/null | cut -d \' -f2)$(uci show network.lan.proto 2>/dev/null | cut -d \' -f2) =~ 'static' ]] && error " $(text 102) "

  # 先排除 EXCLUDE 里包括的特定系统，其他系统需要作大发行版本的比较
  for ex in "${EXCLUDE[@]}"; do [[ ! $(echo "$SYS" | tr 'A-Z' 'a-z')  =~ $ex ]]; done &&
  [[ "$(echo "$SYS" | sed "s/[^0-9.]//g" | cut -d. -f1)" -lt "${MAJOR[int]}" ]] && error " $(text_eval 7) "
}

check_arch() {
  # 判断处理器架构
  case "$(uname -m)" in
    aarch64 )
      ARCHITECTURE=arm64
      ;;
    x86)
      ARCHITECTURE=386
      ;;
    x86_64 )
      CPU_FLAGS=$(cat /proc/cpuinfo | grep flags | head -n 1 | cut -d: -f2)
      case "$CPU_FLAGS" in
        *avx512* )
          ARCHITECTURE=amd64v4
          ;;
        *avx2* )
          ARCHITECTURE=amd64v3
          ;;
        *sse3* )
          ARCHITECTURE=amd64v2
          ;;
        * )
          ARCHITECTURE=amd64
      esac
      ;;
    s390x )
      ARCHITECTURE=s390x
      ;;
    * )
      error " $(text_eval 37) "
  esac
}

# 安装系统依赖及定义 ping 指令
check_dependencies() {
  # 对于 Alpine 和 OpenWrt 系统，升级库并重新安装依赖
  if echo "$SYSTEM" | grep -qE "Alpine|OpenWrt"; then
    [ ! -s /opt/warp-go/warp-go ] && ( ${PACKAGE_UPDATE[int]}; ${PACKAGE_INSTALL[int]} curl wget grep bash tar )
  else
    DEPS_CHECK=("ping" "wget" "curl" "systemctl" "ip" "python3")
    DEPS_INSTALL=("iputils-ping" "wget" "curl" "systemctl" "iproute2" "python3")
    for ((c=0;c<${#DEPS_CHECK[@]};c++)); do [ ! $(type -p ${DEPS_CHECK[c]}) ] && [[ ! "${DEPS[@]}" =~ "${DEPS_INSTALL[c]}" ]] && DEPS+=(${DEPS_INSTALL[c]}); done
    if [ "${#DEPS[@]}" -ge 1 ]; then
      info "\n $(text 8) ${DEPS[@]} \n"
      ${PACKAGE_UPDATE[int]} >/dev/null 2>&1
      ${PACKAGE_INSTALL[int]} ${DEPS[@]} >/dev/null 2>&1
    fi
  fi
  PING6='ping -6' && [ $(type -p ping6) ] && PING6='ping6'
}

# 检测 warp-go 的安装状态。STATUS: 0-未安装; 1-已安装未启动; 2-已安装启动中; 3-脚本安装中
check_install() {
  if [ -s /opt/warp-go/warp.conf ]; then
    [[ "$(ip link show | awk -F': ' '{print $2}')" =~ "WARP" ]] && STATUS=2 || STATUS=1
  else
    STATUS=0
    {
      # 预下载 warp-go，使用 githubusercontent，以更好的支持双栈。并添加执行权限，如因 gitlab 接口问题未能获取，默认 v1.0.8
      latest=$(wget -qO- -T1 -t1 https://gitlab.com/api/v4/projects/ProjectWARP%2Fwarp-go/releases | awk -F '"' '{for (i=0; i<NF; i++) if ($i=="tag_name") {print $(i+2); exit}}' | sed "s/v//")
      latest=${latest:-'1.0.8'}
      wget --no-check-certificate -qO /tmp/warp-go.tar.gz https://raw.githubusercontent.com/fscarmen/warp/main/warp-go/warp-go_"$latest"_linux_"$ARCHITECTURE".tar.gz
      tar xzf /tmp/warp-go.tar.gz -C /tmp/ warp-go
      chmod +x /tmp/warp-go
      rm -f /tmp/warp-go.tar.gz
    }&
  fi
}

# 检测 IPv4 IPv6 信息，WARP Ineterface 开启，普通还是 Plus账户 和 IP 信息
ip4_info() {
  unset IP4 COUNTRY4 ASNORG4 TRACE4 PLUS4 WARPSTATUS4 ERROR4
  IP4_API=${IP_API[0]} && ISP4=${ISP[0]} && IP4_KEY=${IP[0]}
  TRACE4=$(curl --retry 5 -ks4m5 ${IP_API[3]} $INTERFACE4 | grep warp | sed "s/warp=//g")
  if [ -n "$TRACE4" ]; then
    IP4=$(curl --retry 7 -ks4m5 -A Mozilla $IP4_API $INTERFACE4)
    [[ -z "$IP4" || "$IP4" =~ 'error code' ]] && IP4_API=${IP_API[2]} && ISP4=${ISP[2]} && IP4_KEY=${IP[2]} && IP4=$(curl --retry 3 -ks4m5 -A Mozilla $IP4_API $INTERFACE4)
    if [[ -n "$IP4" && ! "$IP4" =~ 'error code' ]]; then
      WAN4=$(expr "$IP4" : '.*'$IP4_KEY'\":[ ]*\"\([^"]*\).*')
      COUNTRY4=$(expr "$IP4" : '.*country\":[ ]*\"\([^"]*\).*')
      ASNORG4=$(expr "$IP4" : '.*'$ISP4'\":[ ]*\"\([^"]*\).*')
    fi
  fi
}

ip6_info() {
  unset IP6 COUNTRY6 ASNORG6 TRACE6 PLUS6 WARPSTATUS6 ERROR6
  IP6_API=${IP_API[1]} && ISP6=${ISP[1]} && IP6_KEY=${IP[1]}
  TRACE6=$(curl --retry 5 -ks6m5 ${IP_API[3]} $INTERFACE6 | grep warp | sed "s/warp=//g")
  if [ -n "$TRACE6" ]; then
    IP6=$(curl --retry 7 -ks6m5 -A Mozilla $IP6_API $INTERFACE6)
    [[ -z "$IP6" || "$IP6" =~ 'error code' ]] && IP6_API=${IP_API[2]} && ISP6=${ISP[2]} && IP6_KEY=${IP[2]} && IP6=$(curl --retry 3 -ks6m5 -A Mozilla $IP6_API $INTERFACE6)
    if [[ -n "$IP6" && ! "$IP6" =~ 'error code' ]]; then
      WAN6=$(expr "$IP6" : '.*'$IP6_KEY'\":[ ]*\"\([^"]*\).*')
      COUNTRY6=$(expr "$IP6" : '.*country\":[ ]*\"\([^"]*\).*')
      ASNORG6=$(expr "$IP6" : '.*'$ISP6'\":[ ]*\"\([^"]*\).*')
    fi
  fi
}

# 帮助说明
help() { hint " $(text 2) "; }

# IPv4 / IPv6 优先设置
stack_priority() {
  if [ "$SYSTEM" != OpenWrt ]; then
    [ "$OPTION" = s ] && case "$PRIORITY_SWITCH" in
      4 )
        PRIORITY=1
        ;;
      6 )
        PRIORITY=2
        ;;
      d )
        :
        ;;
      * )
        hint "\n $(text 55) \n" && reading " $(text 4) " PRIORITY
    esac

    [ -s /etc/gai.conf ] && sed -i '/^precedence \:\:ffff\:0\:0/d;/^label 2002\:\:\/16/d' /etc/gai.conf
    case "$PRIORITY" in
      1 )
        echo "precedence ::ffff:0:0/96  100" >> /etc/gai.conf
        ;;
      2 )
        echo "label 2002::/16   2" >> /etc/gai.conf
    esac
  fi
}

# IPv4 / IPv6 优先结果
result_priority() {
  PRIO=(0 0)
  if [ -s /etc/gai.conf ]; then
    grep -qsE "^precedence[ ]+::ffff:0:0/96[ ]+100" /etc/gai.conf && PRIO[0]=1
    grep -qsE "^label[ ]+2002::/16[ ]+2" /etc/gai.conf && PRIO[1]=1
  fi
  case "${PRIO[*]}" in
    '1 0' )
      PRIO=4
      ;;
    '0 1' )
      PRIO=6
      ;;
    * )
      [[ "$(curl -ksm8 -A Mozilla ${IP_API[3]} | grep 'ip=' | cut -d= -f2)" =~ ^([0-9]{1,3}\.){3} ]] && PRIO=4 || PRIO=6
  esac
  PRIORITY_NOW=$(text_eval 100)

  # 如是快捷方式切换优先级别的话，显示结果
  [ "$OPTION" = s ] && hint "\n $PRIORITY_NOW \n"
}

need_install() {
  [ "$STATUS" = 0 ] && warning " $(text 11) " && reading " $(text 12) " TO_INSTALL
  [[ $TO_INSTALL = [Yy] ]] && install
}

# 更换支持 Netflix WARP IP 改编自 [luoxue-bot] 的成熟作品，地址[https://github.com/luoxue-bot/warp_auto_change_ip]
change_ip() {
  need_install
  warp_restart() {
    warning " $(text_eval 13) "
    cp -f /opt/warp-go/warp.conf{,.tmp1}
    [ -s /opt/warp-go/License ] && k='+' || k=' free'
    registe_api warp.conf.tmp2
    sed -i '1,6!d' /opt/warp-go/warp.conf.tmp2
    tail -n +7 /opt/warp-go/warp.conf.tmp1 >> /opt/warp-go/warp.conf.tmp2
    mv /opt/warp-go/warp.conf.tmp2 /opt/warp-go/warp.conf
    bash <(curl -m8 -sSL https://raw.githubusercontent.com/fscarmen/warp/main/api.sh) --file /opt/warp-go/warp.conf.tmp1 --cancle >/dev/null 2>&1
    rm -f /opt/warp-go/warp.conf.tmp*
    ${SYSTEMCTL_RESTART[int]}
    sleep $l
  }

  # 检测账户类型为 Team 的不能更换
  if grep -qE 'Type[ ]+=[ ]+team' /opt/warp-go/warp.conf; then
    hint "\n $(text 97) \n" && reading " $(text 4) " CHANGE_ACCOUNT
    case "$CHANGE_ACCOUNT" in
      2 ) 
        update_license
        echo "$LICENSE" > /opt/warp-go/License
        echo "$NAME" > /opt/warp-go/Device_Name
        ;;
      3 ) exit 0
    esac
  fi

  # 设置时区，让时间戳时间准确，显示脚本运行时长，中文为 GMT+8，英文为 UTC; 设置 UA
  ip_start=$(date +%s)
  echo "$SYSTEM" | grep -qE "Alpine" && ( [ "$L" = C ] && timedatectl set-timezone Asia/Shanghai || timedatectl set-timezone UTC )
  UA_Browser="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.87 Safari/537.36"

  # 根据 lmc999 脚本检测 Netflix Title，如获取不到，使用兜底默认值
  local LMC999=($(curl -sSLm4 https://raw.githubusercontent.com/lmc999/RegionRestrictionCheck/main/check.sh | awk -F 'title/' '/netflix.com\/title/{print $2'}  | cut -d\" -f1))
  RESULT_TITLE=(${LMC999[*]:0:2})
  REGION_TITLE=${LMC999[2]}
  [[ ! "${RESULT_TITLE[0]}" =~ ^[0-9]+$ ]] && RESULT_TITLE[0]='81280792'
  [[ ! "${RESULT_TITLE[1]}" =~ ^[0-9]+$ ]] && RESULT_TITLE[1]='70143836'
  [[ ! "$REGION_TITLE" =~ ^[0-9]+$ ]] && REGION_TITLE='80018499'

  # 检测 WARP 单双栈服务
  unset T4 T6
  if grep -q "#AllowedIPs" /opt/warp-go/warp.conf; then
    T4=1; T6=1
  else
    grep -q "0\.\0\/0" /opt/warp-go/warp.conf && T4=1 || T4=0
    grep -q "\:\:\/0" /opt/warp-go/warp.conf && T6=1 || T6=0
  fi
  case "$T4$T6" in
    01 )
      NF='6'
      ;;
    10 )
      NF='4'
      ;;
    11 )
      hint "\n $(text 14) \n" && reading " $(text 4) " NETFLIX
      NF='4' && [ "$NETFLIX" = 2 ] && NF='6'
  esac

  # 输入解锁区域
  if [ -z "$EXPECT" ]; then
    [ -n "$NF" ] && REGION=$(tr 'a-z' 'A-Z' <<< "$(curl --user-agent "${UA_Browser}" --interface WARP -$NF -fs --max-time 10 --write-out %{redirect_url} --output /dev/null "https://www.netflix.com/title/$REGION_TITLE" | sed 's/.*com\/\([^-/]\{1,\}\).*/\1/g')")
    REGION=${REGION:-'US'}
    reading " $(text_eval 15) " EXPECT
    until [[ -z "$EXPECT" || "$EXPECT" = [Yy] || "$EXPECT" =~ ^[A-Za-z]{2}$ ]]; do
      reading " $(text_eval 15) " EXPECT
    done
    [[ -z "$EXPECT" || "$EXPECT" = [Yy] ]] && EXPECT="$REGION"
  fi

  # 解锁检测程序。 i=尝试次数; b=当前账户注册次数; j=注册账户失败的最大次数; l=账户注册失败后等待重试时间;
  i=0; j=10; l=8
  while true; do
    b=0
    (( i++ )) || true
    ip_now=$(date +%s); RUNTIME=$((ip_now - ip_start)); DAY=$(( RUNTIME / 86400 )); HOUR=$(( (RUNTIME % 86400 ) / 3600 )); MIN=$(( (RUNTIME % 86400 % 3600) / 60 )); SEC=$(( RUNTIME % 86400 % 3600 % 60 ))
    ip${NF}_info
    WAN=$(eval echo \$WAN$NF) && ASNORG=$(eval echo \$ASNORG$NF)
    [ "$L" = C ] && COUNTRY=$(translate "$(eval echo \$COUNTRY$NF)") || COUNTRY=$(eval echo \$COUNTRY$NF)
    unset RESULT REGION
    for ((p=0; p<${#RESULT_TITLE[@]}; p++)); do
      RESULT[p]=$(curl --user-agent "${UA_Browser}" --interface WARP -$NF -fsL --write-out %{http_code} --output /dev/null --max-time 10 "https://www.netflix.com/title/${RESULT_TITLE[p]}")
      [ "${RESULT[p]}" = 200 ] && break
    done
    
    if [[ "${RESULT[@]}" =~ 200 ]]; then
      REGION=$(tr 'a-z' 'A-Z' <<< "$(curl --user-agent "${UA_Browser}" --interface WARP -$NF -fs --max-time 10 --write-out %{redirect_url} --output /dev/null "https://www.netflix.com/title/$REGION_TITLE" | sed 's/.*com\/\([^-/]\{1,\}\).*/\1/g')")
      REGION=${REGION:-'US'}
      echo "$REGION" | grep -qi "$EXPECT" && info " $(text_eval 16) " && rm -f /opt/warp-go/warp.conf.tmp1 && i=0 && sleep 1h || warp_restart
    else
      warp_restart
    fi
  done
}

# 关闭 WARP 网络接口，并删除 warp-go
uninstall() {
  unset IP4 IP6 WAN4 WAN6 COUNTRY4 COUNTRY6 ASNORG4 ASNORG6 INTERFACE4 INTERFACE6

  # 如已安装 warp_unlock 项目，先行卸载
  [ -s /etc/wireguard/warp_unlock.sh ] && bash <(curl -sSL https://raw.githubusercontent.com/fscarmen/warp_unlock/main/unlock.sh) -U -$L

  # 卸载
  systemctl disable --now warp-go >/dev/null 2>&1
  kill -15 $(pgrep warp-go) >/dev/null 2>&1
  bash <(curl -m8 -sSL https://raw.githubusercontent.com/fscarmen/warp/main/api.sh) --file /opt/warp-go/warp.conf --cancle >/dev/null 2>&1
  rm -rf /opt/warp-go /lib/systemd/system/warp-go.service /usr/bin/warp-go /tmp/warp-go*
  [ -s /opt/warp-go/tun.sh ] && rm -f /opt/warp-go/tun.sh && sed -i '/tun.sh/d' /etc/crontab

  # 显示卸载结果
  ip4_info; [[ "$L" = C && -n "$COUNTRY4" ]] && COUNTRY4=$(translate "$COUNTRY4")
  ip6_info; [[ "$L" = C && -n "$COUNTRY6" ]] && COUNTRY6=$(translate "$COUNTRY6")
  info " $(text 17)\n IPv4: $WAN4 $COUNTRY4 $ASNORG4\n IPv6: $WAN6 $COUNTRY6 $ASNORG6 "
}

# 同步脚本至最新版本
ver() {
  mkdir -p /tmp; rm -f /tmp/warp-go.sh
  wget -O /tmp/warp-go.sh https://raw.githubusercontent.com/fscarmen/warp/main/warp-go.sh
  if [ -s /tmp/warp-go.sh ]; then
    mv /tmp/warp-go.sh /opt/warp-go/
    chmod +x /opt/warp-go/warp-go.sh
    ln -sf /opt/warp-go/warp-go.sh /usr/bin/warp-go
    info " $(text 18): $(grep ^VERSION /opt/warp-go/warp-go.sh | sed "s/.*=//g")  $(text 19): $(grep "${L}\[1\]" /opt/warp-go/warp-go.sh | cut -d \" -f2) "
  fi
  exit
}

# i=当前尝试次数，j=要尝试的次数
net() {
  unset IP4 IP6 WAN4 WAN6 COUNTRY4 COUNTRY6 ASNORG4 ASNORG6 WARPSTATUS4 WARPSTATUS6
  i=1; j=5
  grep -qE "^AllowedIPs[ ]+=.*0\.\0\/0|#AllowedIPs" /opt/warp-go/warp.conf && INTERFACE4='--interface WARP'
  grep -qE "^AllowedIPs[ ]+=.*\:\:\/0|#AllowedIPs" /opt/warp-go/warp.conf && INTERFACE6='--interface WARP'
  hint " $(text_eval 20)\n $(text_eval 59) "
  [ "$KEEP_FREE" != 1 ] && ${SYSTEMCTL_RESTART[int]}
  grep -q "#AllowedIPs" /opt/warp-go/warp.conf && sleep 8 || sleep 1
  ip4_info; ip6_info
  until [[ "$TRACE4$TRACE6" =~ on|plus ]]; do
    (( i++ )) || true
    hint " $(text_eval 59) "
    ${SYSTEMCTL_RESTART[int]}
    grep -q "#AllowedIPs" /opt/warp-go/warp.conf && sleep 8 || sleep 1
    ip4_info; ip6_info
      if [[ "$i" = "$j" ]]; then
        if [ -s /opt/warp-go/warp.conf.tmp1 ]; then 
          i=0 && info " $(text 22) " &&
          mv -f /opt/warp-go/warp.conf.tmp1 /opt/warp-go/warp.conf
      else
          ${SYSTEMCTL_STOP[int]} >/dev/null 2>&1
          error " $(text_eval 23) "
        fi
      fi
  done

  ACCOUNT_TYPE=$(grep "Type" /opt/warp-go/warp.conf | cut -d= -f2 | sed "s# ##g")
  [ "$ACCOUNT_TYPE" = 'plus' ] && check_quota
  grep -q '#AllowedIPs' /opt/warp-go/warp.conf && GLOBAL_TYPE="$(text 24)"

  info " $(text_eval 25) "
  [ "$L" = C ] && COUNTRY4=$(translate "$COUNTRY4")
  [ "$L" = C ] && COUNTRY6=$(translate "$COUNTRY6")
  [ "$OPTION" = o ] && info " IPv4: $WAN4 $WARPSTATUS4 $COUNTRY4 $ASNORG4\n IPv6: $WAN6 $WARPSTATUS6 $COUNTRY6 $ASNORG6 "
  [ -n "$QUOTA" ] && info " $(text 26): $QUOTA "
}

# api 注册账户, 使用官方 api 脚本
registe_api() {
  local REGISTE_FILE="$1"
  local i=0; local j=5
  [ -n "$2" ] && hint " $(text_eval $2) "
  until [ -s /opt/warp-go/$REGISTE_FILE ]; do
    ((i++)) || true
    [ "$i" -gt "$j" ] && rm -f /opt/warp-go/warp.conf.tmp* && error " $(text_eval 50) "
    [ -n "$3" ] && hint " $(text_eval $3) "
    if ! grep -sq 'PrivateKey' /opt/warp-go/$REGISTE_FILE; then
      unset CF_API_REGISTE API_DEVICE_ID API_ACCESS_TOKEN API_PRIVATEKEY API_TYPE
      rm -f /opt/warp-go/$REGISTE_FILE
      CF_API_REGISTE="$(bash <(curl -m8 -sSL https://raw.githubusercontent.com/fscarmen/warp/main/api.sh | sed 's# > $registe_path##g') --registe --token $TOKEN 2>/dev/null)"
      [[ -n "$NF" && -n "$EXPECT" && -s /opt/warp-go/License ]] && LICENSE=$(cat /opt/warp-go/License) && NAME=$(cat /opt/warp-go/Device_Name)
      [[ -z "$LICENSE" && -s /opt/warp-go/License ]] && rm -f /opt/warp-go/License /opt/warp-go/Device_Name
      if grep -q 'private_key' <<< "$CF_API_REGISTE"; then
        local API_DEVICE_ID=$(expr "$CF_API_REGISTE " | grep -m1 'id' | cut -d\" -f4)
        local API_ACCESS_TOKEN=$(expr "$CF_API_REGISTE " | grep '"token' | cut -d\" -f4)
        local API_PRIVATEKEY=$(expr "$CF_API_REGISTE " | grep 'private_key' | cut -d\" -f4)
        local API_TYPE=$(expr "$CF_API_REGISTE " | grep 'account_type' | cut -d\" -f4)
        [[ -z "$NF" && -z "$EXPECT" && -n "$TOKEN" ]] && ( [ "$API_TYPE" = 'team' ] && info "\n teams $(text_eval 105) \n" || warning "\n teams $(text_eval 106) \n" )
        cat > /opt/warp-go/$REGISTE_FILE << EOF
[Account]
Device = $API_DEVICE_ID
PrivateKey = $API_PRIVATEKEY
Token = $API_ACCESS_TOKEN
Type = $API_TYPE

[Device]
Name = WARP
MTU  = 1280

[Peer]
PublicKey = bmXOC+F1FxEMF9dyiK2H5/1SUtzH0JuVo51h2wPfgyo=
Endpoint = 162.159.193.10:1701
KeepAlive = 30
# AllowedIPs = 0.0.0.0/0
# AllowedIPs = ::/0

EOF
      fi
    fi

    if grep -sq 'Account' /opt/warp-go/$REGISTE_FILE; then
      echo -e "\n[Script]\nPostUp =\nPostDown =" >> /opt/warp-go/$REGISTE_FILE && sed -i 's/\r//' /opt/warp-go/$REGISTE_FILE
      if [ -n "$LICENSE" ]; then
        local RESULT=$(bash <(curl -m8 -sSL https://raw.githubusercontent.com/fscarmen/warp/main/api.sh) --file /opt/warp-go/$REGISTE_FILE --license $LICENSE)
        if [[ "$RESULT" =~ '"warp_plus": true' ]]; then
          bash <(curl -m8 -sSL https://raw.githubusercontent.com/fscarmen/warp/main/api.sh) --file /opt/warp-go/$REGISTE_FILE --name $NAME >/dev/null 2>&1
          echo "$LICENSE" > /opt/warp-go/License
          echo "$NAME" > /opt/warp-go/Device_Name
          sed -i "s/Type =.*/Type = plus/g" /opt/warp-go/$REGISTE_FILE
          [[ -z "$NF" && -z "$EXPECT" ]] && info "\n License: $LICENSE $(text_eval 105) \n"
        else
          warning "\n License: $LICENSE $(text_eval 106) \n"
        fi
      elif [[ -s /opt/warp-go/License && -s /opt/warp-go/Device_Name ]]; then
        if [ -s /opt/warp-go/warp.conf.tmp ]; then
          bash <(curl -m8 -sSL https://raw.githubusercontent.com/fscarmen/warp/main/api.sh) --file /opt/warp-go/$REGISTE_FILE --license $(cat /opt/warp-go/License 2>/dev/null) >/dev/null 2>&1
          bash <(curl -m8 -sSL https://raw.githubusercontent.com/fscarmen/warp/main/api.sh) --file /opt/warp-go/$REGISTE_FILE --name $(cat /opt/warp-go/Device_Name 2>/dev/null) >/dev/null 2>&1
        fi
      fi
    else
      rm -f /opt/warp-go/$REGISTE_FILE
    fi
 done
}

# WARP 开关，先检查是否已安装，再根据当前状态转向相反状态
onoff() {
  case "$STATUS" in
    0 )
      need_install
      ;;
    1 )
      net
      ;;
    2 )
      ${SYSTEMCTL_STOP[int]}; info " $(text 27) "
  esac
}

# 检查系统 WARP 单双栈情况。为了速度，先检查 warp-go 配置文件里的情况，再判断 trace
check_stack() {
  if [ -s /opt/warp-go/warp.conf ]; then
    if grep -q "^#AllowedIPs" /opt/warp-go/warp.conf; then
      T4=2
    else
      grep -q ".*0\.\0\/0" /opt/warp-go/warp.conf && T4=1 || T4=0 
      grep -q ".*\:\:\/0" /opt/warp-go/warp.conf && T6=1 || T6=0
    fi
  else
    case "$TRACE4" in
      off )
        T4='0'
        ;;
      'on'|'plus' )
        T4='1'
    esac
    case "$TRACE6" in
      off )
        T6='0'
        ;;
      'on'|'plus' )
        T6='1'
    esac
  fi
  CASE=("@0" "0@" "0@0" "@1" "0@1" "1@" "1@0" "1@1" "2@")
  for ((m=0;m<${#CASE[@]};m++)); do [[ "$T4@$T6" = "${CASE[m]}" ]] && break; done
  WARP_BEFORE=("" "" "" "WARP $(text 99) IPv6 only" "WARP $(text 99) IPv6" "WARP $(text 99) IPv4 only" "WARP $(text 99) IPv4" "WARP $(text 99) $(text 96)" "WARP $(text 98) $(text 96)")
  WARP_AFTER1=("" "" "" "WARP $(text 99) IPv4" "WARP $(text 99) IPv4" "WARP $(text 99) IPv6" "WARP $(text 99) IPv6" "WARP $(text 99) IPv4" "WARP $(text 99) IPv4")
  WARP_AFTER2=("" "" "" "WARP $(text 99) $(text 96)" "WARP $(text 99) $(text 96)" "WARP $(text 99) $(text 96)" "WARP $(text 99) $(text 96)" "WARP $(text 99) IPv6" "WARP $(text 99) $(text 96)")
  TO1=("" "" "" "014" "014" "106" "106" "114" "014")
  TO2=("" "" "" "01D" "01D" "10D" "10D" "116" "01D")
  SHORTCUT1=("" "" "" "(warp-go 4)" "(warp-go 4)" "(warp-go 6)" "(warp-go 6)" "(warp-go 4)" "(warp-go 4)")
  SHORTCUT2=("" "" "" "(warp-go d)" "(warp-go d)" "(warp-go d)" "(warp-go d)" "(warp-go 6)" "(warp-go d)") 

  # 判断用于检测 NAT VSP，以选择正确配置文件
  if [ "$m" -le 3 ]; then
    NAT=("0@1@" "1@0@1" "1@1@1" "0@1@1")
    for ((n=0;n<${#NAT[@]};n++)); do [ "$IPV4@$IPV6@$INET4" = "${NAT[n]}" ] && break; done
    NATIVE=("IPv6 only" "IPv4 only" "$(text 94)" "NAT IPv4")
    CONF1=("014" "104" "114" "11N4")
    CONF2=("016" "106" "116" "11N6")
    CONF3=("01D" "10D" "11D" "11ND")
  fi
}

# 检查全局状态
check_global() {
  [ -s /opt/warp-go/warp.conf ] && grep -q '#AllowedIPs' /opt/warp-go/warp.conf && NON_GLOBAL=1
}

# 单双栈在线互换。先看菜单是否有选择，再看传参数值，再没有显示2个可选项
stack_switch() {
  need_install
  check_global
  if [ "$NON_GLOBAL" = 1 ]; then
    if [[ "$CHOOSE" != [12] ]]; then
      warning " $(text 28) " && reading " $(text 29) " TO_GLOBAL
      [[ "$TO_GLOBAL" != [Yy] ]] && exit 0 || global_switch
    else
      global_switch
    fi
  fi

  # WARP 单双栈切换选项
  SWITCH014="s#AllowedIPs.*#AllowedIPs = 0.0.0.0/0#g"
  SWITCH01D="s#AllowedIPs.*#AllowedIPs = 0.0.0.0/0,::/0#g"
  SWITCH106="s#AllowedIPs.*#AllowedIPs = ::/0#g"
  SWITCH10D="s#AllowedIPs.*#AllowedIPs = 0.0.0.0/0,::/0#g"
  SWITCH114="s#AllowedIPs.*#AllowedIPs = 0.0.0.0/0#g"
  SWITCH116="s#AllowedIPs.*#AllowedIPs = ::/0#g"

  check_stack

  if [[ "$CHOOSE" = [12] ]]; then
    TO=$(eval echo \${TO$CHOOSE[m]})
  elif [[ "$SWITCHCHOOSE" = [46D] ]]; then
    if [[ "$TO_GLOBAL" = [Yy] ]]; then
      if [[ "$T4@$T6@$SWITCHCHOOSE" =~ '1@0@4'|'0@1@6'|'1@1@D' ]]; then
        grep -q "^AllowedIPs.*0\.\0\/0" /opt/warp-go/warp.conf || unset INTERFACE4 INTERFACE6
        OPTION=o && net
        exit 0
      else
        TO="$T4$T6$SWITCHCHOOSE"
      fi
    else
      [[ "$T4@$T6@$SWITCHCHOOSE" =~ '1@0@4'|'0@1@6'|'1@1@D' ]] && error " $(text 30) " || TO="$T4$T6$SWITCHCHOOSE"
    fi
  else
    STACK_OPTION[1]="$(text_eval 31)"; STACK_OPTION[2]="$(text_eval 32)"
    hint "\n $(text_eval 33) \n" && reading " $(text 4) " SWITCHTO
    case "$SWITCHTO" in
      1 )
        TO=${TO1[m]}
        ;;
      2 )
        TO=${TO2[m]}
        ;;
      0 )
        exit
        ;;
      * )
        warning " $(text 34) [0-2] "; sleep 1; stack_switch
    esac
  fi

  [ "${#TO}" != 3 ] && error " $(text 10) " || sed -i "$(eval echo "\$SWITCH$TO")" /opt/warp-go/warp.conf
  case "$TO" in
    014|114 )
      INTERFACE4='--interface WARP'; unset INTERFACE6
      ;;
    106|116 )
      INTERFACE6='--interface WARP'; unset INTERFACE4
      ;;
    01D|10D )
      INTERFACE4='--interface WARP'; INTERFACE6='--interface WARP'
  esac

  OPTION=o && net
}

# 全局 / 非全局在线互换
global_switch() {
  # 如状态不是安装中，则检测是否已安装 warp-go，如已安装，则停止 systemd
  if [ "$STATUS" != 3 ]; then
    need_install
    ${SYSTEMCTL_STOP[int]}
  fi

  if grep -q "^Allowed" /opt/warp-go/warp.conf; then
    sed -i "s/^#//g; s/^AllowedIPs.*/#&/g" /opt/warp-go/warp.conf
    sleep 2
  else
    sed -i "s/^#//g; s/.*NonGlobal/#&/g" /opt/warp-go/warp.conf
    unset GLOBAL_TYPE
  fi

  # 如状态不是安装中，不是非全局转换到全局时的快捷或菜单选择情况。则开始 systemd,
  if [[ "$STATUS" != 3 && "$TO_GLOBAL" != [Yy] && "$CHOOSE" != [12] ]]; then
    ${SYSTEMCTL_START[int]}
    OPTION=o && net
  fi
}

# 检测系统信息
check_system_info() {
  info " $(text 35) "

  # 必须加载 TUN 模块，先尝试在线打开 TUN。尝试成功放到启动项，失败作提示并退出脚本
  TUN=$(cat /dev/net/tun 2>&1 | tr 'A-Z' 'a-z')
  if [[ ! "$TUN" =~ 'in bad state' ]] && [[ ! "$TUN" =~ '处于错误状态' ]] && [[ ! "$TUN" =~ 'Die Dateizugriffsnummer ist in schlechter Verfassung' ]]; then
    mkdir -p /opt/warp-go/ >/dev/null 2>&1
    cat >/opt/warp-go/tun.sh << EOF
#!/usr/bin/env bash
mkdir -p /dev/net
mknod /dev/net/tun c 10 200
chmod 0666 /dev/net/tun
EOF
    bash /opt/warp-go/tun.sh
    TUN=$(cat /dev/net/tun 2>&1 | tr 'A-Z' 'a-z')
    if [[ ! "$TUN" =~ 'in bad state' ]] && [[ ! "$TUN" =~ '处于错误状态' ]] && [[ ! "$TUN" =~ 'Die Dateizugriffsnummer ist in schlechter Verfassung' ]]; then
      rm -f /opt/warp-go/tun.sh && error "$(text 36)"
    else
      chmod +x /opt/warp-go/tun.sh
      echo "$SYSTEM" | grep -qvE "Alpine|OpenWrt" && echo "@reboot root bash /opt/warp-go/tun.sh" >> /etc/crontab
    fi
  fi

  # 判断机器原生状态类型
  IPV4=0; IPV6=0
  LAN4=$(ip route get 192.168.193.10 2>/dev/null | awk '{for (i=0; i<NF; i++) if ($i=="src") {print $(i+1)}}')
  LAN6=$(ip route get 2606:4700:d0::a29f:c001 2>/dev/null | awk '{for (i=0; i<NF; i++) if ($i=="src") {print $(i+1)}}')
  [[ "$LAN4" =~ ^([0-9]{1,3}\.){3} ]] && INET4=1
  [[ "$LAN6" != "::1" && "$LAN6" =~ ^([a-f0-9]{1,4}:){2,4}[a-f0-9]{1,4} ]] && INET6=1
  [ "$INET6" = 1 ] && $PING6 -c2 -w10 2606:4700:d0::a29f:c001 >/dev/null 2>&1 && IPV6=1 && CDN=-6
  [ "$INET4" = 1 ] && ping -c2 -W3 162.159.193.10 >/dev/null 2>&1 && IPV4=1 && CDN=-4

  if [ "$STATUS" != 0 ]; then
    if grep -qE "^AllowedIPs.*\.0/0,::/0|^#AllowedIPs" /opt/warp-go/warp.conf; then
      INTERFACE4='--interface WARP'; INTERFACE6='--interface WARP'
    elif grep -q '^AllowedIPs.*\.0/0$' /opt/warp-go/warp.conf; then
      INTERFACE4='--interface WARP'; unset INTERFACE6
    elif grep -q '^AllowedIPs.*::/0$' /opt/warp-go/warp.conf; then
      INTERFACE6='--interface WARP'; unset INTERFACE4
    fi
  fi

  [ "$IPV4" = 1 ] && ip4_info
  [ "$IPV6" = 1 ] && ip6_info

  if [ "$L" = C ]; then
    [ -n "$COUNTRY4" ] && COUNTRY4=$(translate "$COUNTRY4")
    [ -n "$COUNTRY6" ] && COUNTRY6=$(translate "$COUNTRY6")
  fi
}

# 输入 WARP+ 账户（如有），限制位数为空或者26位以防输入错误
input_license() {
  [ -z "$LICENSE" ] && reading " $(text 38) " LICENSE
  i=5
  until [[ -z "$LICENSE" || "$LICENSE" =~ ^[A-Z0-9a-z]{8}-[A-Z0-9a-z]{8}-[A-Z0-9a-z]{8}$ ]]; do
    (( i-- )) || true
    [ "$i" = 0 ] && error "$(text 39)" || reading " $(text_eval 40) " LICENSE
  done
  [[ -n "$LICENSE" && -z "$NAME" ]] && reading " $(text 41) " NAME
  [ -n "$NAME" ] && NAME="${NAME//[[:space:]]/_}" || NAME="${NAME:-warp-go}"
}

# 升级 WARP+ 账户（如有），限制位数为空或者26位以防输入错误，WARP interface 可以自定义设备名(不允许字符串间有空格，如遇到将会以_代替)
update_license() {
  [ -z "$LICENSE" ] && reading " $(text 42) " LICENSE
  i=5
  until [[ "$LICENSE" =~ ^[A-Z0-9a-z]{8}-[A-Z0-9a-z]{8}-[A-Z0-9a-z]{8}$ ]]; do
  (( i-- )) || true
    [ "$i" = 0 ] && error "$(text 39)" || reading " $(text_eval 43) " LICENSE
  done
  [[ -n "$LICENSE" && -z "$NAME" ]] && reading " $(text 41) " NAME
  [ -n "$NAME" ] && NAME="${NAME//[[:space:]]/_}" || NAME="${NAME:-warp-go}"
}

# 输入 Teams 账户 token（如有）,如果 TOKEN 以 com.cloudflare.warp 开头，将自动删除多余部分
input_token() {
  [ -z "$TOKEN" ] && reading " $(text 44) " TOKEN
  i=5
  until [[ -z "$TOKEN" || "${#TOKEN}" -ge "$TOKEN_LENGTH" ]]; do
    (( i-- )) || true
    [ "$i" = 0 ] && error "$(text 39)" || reading " $(text_eval 45) " TOKEN
  done
  [[ -n "$TOKEN" && -z "$NAME" ]] && reading " $(text 41) " NAME
  [ -n "$NAME" ] && NAME="${NAME//[[:space:]]/_}" || NAME="${NAME:-warp-go}"  
}

# 免费 WARP 账户升级 WARP+ 或 Teams 账户
update() {
  need_install
  [ ! -s /opt/warp-go/warp.conf ] && error "$(text 21)"

  ACCOUNT_TYPE=$(grep "Type" /opt/warp-go/warp.conf | cut -d= -f2 | sed "s# ##g")
  case "$ACCOUNT_TYPE" in
    free )
      CHANGE_TYPE=$(text 47)
      ;;
    team )
      CHANGE_TYPE=$(text 48)
      ;;
    plus )
      CHANGE_TYPE=$(text 49)
      check_quota
      [[ "$QUOTA" =~ '.' ]] && PLUS_QUOTA="\\n $(text 26): $QUOTA"
  esac

  [ -z "$LICENSETYPE" ] && hint "\n $(text_eval 46) \n" && reading " $(text 4) " LICENSETYPE
  case "$LICENSETYPE" in
    1|2 )
      unset QUOTA
      case "$LICENSETYPE" in
        1 )
          k=' free'
          [ "$ACCOUNT_TYPE" = free ] && KEEP_FREE='1'
          [ -s /opt/warp-go/Device_Name ] && rm -f /opt/warp-go/Device_Name
          if [ "$ACCOUNT_TYPE" = free ]; then
            OPTION=o && net
            exit 0
          fi
          ;;
        2 )
          k='+'
          update_license
      esac
      cp -f /opt/warp-go/warp.conf{,.tmp1}
      bash <(curl -m8 -sSL https://raw.githubusercontent.com/fscarmen/warp/main/api.sh) --file /opt/warp-go/warp.conf --cancle >/dev/null 2>&1
      [ -s /opt/warp-go/warp.conf ] && rm -f /opt/warp-go/warp.conf
      registe_api warp.conf 58 59
      head -n +6 /opt/warp-go/warp.conf > /opt/warp-go/warp.conf.tmp2
      tail -n +7 /opt/warp-go/warp.conf.tmp1 >> /opt/warp-go/warp.conf.tmp2
      rm -f /opt/warp-go/warp.conf.tmp1
      mv -f /opt/warp-go/warp.conf.tmp2 /opt/warp-go/warp.conf
      OPTION=o && net
      ;;
    3 )
      unset QUOTA
      input_token
      if [ -n "$TOKEN" ]; then
        k=' teams'
        registe_api warp.conf.tmp 58 59
        for a in {2..5}; do
          sed -i "${a}s#.*#$(sed -ne ${a}p /opt/warp-go/warp.conf.tmp)#" /opt/warp-go/warp.conf
        done
        rm -f /opt/warp-go/warp.conf.tmp
      else
        sed -i "s#^Device.*#Device = FSCARMEN-WARP-SHARE-TEAM#g; s#.*PrivateKey.*#PrivateKey = SHVqHEGI7k2+OQ/oWMmWY2EQObbRQjRBdDPimh0h1WY=#g; s#.*Token.*#Token = PROTECTED_PLACEHOLDER#g; s#.*Type.*#Type = team#g" /opt/warp-go/warp.conf
      fi
      grep -qE 'Type[ ]+=[ ]+team' /opt/warp-go/warp.conf && echo "$NAME" > /opt/warp-go/Device_Name
      OPTION=o && net
      ;;
    0 ) 
      unset LICENSETYPE
      menu
      ;;
    * )
      warning " $(text 34) [0-3] "; sleep 1; unset LICENSETYPE; update
  esac
}

# 输出 wireguard 和 sing-box 配置文件
export_file() {
  if [ -s /opt/warp-go/warp-go ]; then
    PY=("python3" "python" "python2")
    for g in "${PY[@]}"; do [ $(type -p $g) ] && PYTHON=$g && break; done
    [ -z "$PYTHON" ] && PYTHON=python3 && ${PACKAGE_INSTALL[int]} $PYTHON
    [ ! -s /opt/warp-go/warp.conf ] && registe_api warp.conf
    /opt/warp-go/warp-go --config=/opt/warp-go/warp.conf --export-wireguard=/opt/warp-go/wgcf.conf >/dev/null 2>&1
    /opt/warp-go/warp-go --config=/opt/warp-go/warp.conf --export-singbox=/opt/warp-go/singbox.json >/dev/null 2>&1
  else
    error "$(text 51)"
  fi

  info "\n $(text 52) "
  cat /opt/warp-go/wgcf.conf
  echo -e "\n\n"

  info " $(text 101) "
  cat /opt/warp-go/singbox.json | $PYTHON -m json.tool
  echo -e "\n\n"
}

# warp-go 安装
install() {
  # 已经状态码不为 0， 即已安装， 脚本退出
  [ "$STATUS" != 0 ] && error "$(text 53)"

  # CONF 参数如果不是3位或4位， 即检测不出正确的配置参数， 脚本退出
  [[ "${#CONF}" != [34] ]] && error " $(text 10) "

  # 先删除之前安装，可能导致失败的文件
  rm -rf /opt/warp-go/warp-go /opt/warp-go/warp.conf

  # 询问是否有 WARP+ 或 Teams 账户
  [ -z "$LICENSETYPE" ] && hint "\n $(text 54) \n" && reading " $(text 4) " LICENSETYPE
  case "$LICENSETYPE" in
    1 )
      input_license
      ;;
    2 )
      input_token
  esac

  # 选择优先使用 IPv4 /IPv6 网络
  [ -z "$PRIORITY" ] && hint "\n $(text 55) \n" && reading " $(text 4) " PRIORITY

  # 脚本开始时间
  start=$(date +%s)

  # 寻找最佳 MTU 和 Endpoint 值
  {
    # 详细说明:<[WireGuard] Header / MTU sizes for Wireguard>:https://lists.zx2c4.com/pipermail/wireguard/2017-December/002201.html
    MTU=$((1500-28))
    [ "$IPV4$IPV6" = 01 ] && $PING6 -c1 -W1 -s $MTU -Mdo 2606:4700:d0::a29f:c001 >/dev/null 2>&1 || ping -c1 -W1 -s $MTU -Mdo 162.159.193.10 >/dev/null 2>&1
    until [[ $? = 0 || $MTU -le $((1280+80-28)) ]]; do
      MTU=$((MTU-10))
      [ "$IPV4$IPV6" = 01 ] && $PING6 -c1 -W1 -s $MTU -Mdo 2606:4700:d0::a29f:c001 >/dev/null 2>&1 || ping -c1 -W1 -s $MTU -Mdo 162.159.193.10 >/dev/null 2>&1
    done

    if [ "$MTU" -eq $((1500-28)) ]; then
      MTU=$MTU
    elif [ "$MTU" -le $((1280+80-28)) ]; then
      MTU=$((1280+80-28))
    else
      for ((i=0; i<9; i++)); do
        (( MTU++ ))
        ( [ "$IPV4$IPV6" = 01 ] && $PING6 -c1 -W1 -s $MTU -Mdo 2606:4700:d0::a29f:c001 >/dev/null 2>&1 || ping -c1 -W1 -s $MTU -Mdo 162.159.193.10 >/dev/null 2>&1 ) || break
      done
      (( MTU-- ))
    fi

    MTU=$((MTU+28-80))

    echo "$MTU" > /tmp/warp-go-mtu

    # 寻找最佳 Endpoint，根据 v4 / v6 情况下载 endpoint 库
    wget $CDN -qO /tmp/endpoint https://raw.githubusercontent.com/fscarmen/warp/main/endpoint/warp-linux-${ARCHITECTURE//amd64*/amd64} && chmod +x /tmp/endpoint
    [ "$IPV4$IPV6" = 01 ] && wget $CDN -qO /tmp/ip https://raw.githubusercontent.com/fscarmen/warp/main/endpoint/ipv6 || wget $CDN -qO /tmp/ip https://raw.githubusercontent.com/fscarmen/warp/main/endpoint/ipv4

    if [[ -s /tmp/endpoint && -s /tmp/ip ]]; then
      /tmp/endpoint -file /tmp/ip -output /tmp/endpoint_result >/dev/null 2>&1
      ENDPOINT=$(grep -sE '[0-9]+[ ]+ms$' /tmp/endpoint_result | awk -F, 'NR==1 {print $1}')
      rm -f /tmp/{endpoint,ip,endpoint_result}
    fi

    # 如果失败，会有默认值 162.159.193.10:2408 或 [2606:4700:d0::a29f:c001]:2408
    [ "$IPV4$IPV6" = 01 ] && ENDPOINT=${ENDPOINT:-'[2606:4700:d0::a29f:c001]:2408'} || ENDPOINT=${ENDPOINT:-'162.159.193.10:2408'}

    echo "$ENDPOINT" > /tmp/warp-go-endpoint

    info "\n $(text 9) \n"
  }&

  # 注册 Teams 账户 (将生成 warp 文件保存账户信息)
  {
    mkdir -p /opt/warp-go/ >/dev/null 2>&1
    wait
    [ ! -s /tmp/warp-go ] && error "$(text 56)" || mv -f /tmp/warp-go /opt/warp-go/
    [ ! -s /opt/warp-go/warp-go ] && error "$(text 57)"

    # 注册用户自定义 token 的 Teams 账户
    if [ "$LICENSETYPE" = 2 ]; then
      if [ -n "$TOKEN" ]; then
        k=' teams'
        registe_api warp.conf 58

    # 注册公用 token 的 Teams 账户
      else
        cat > /opt/warp-go/warp.conf << EOF
[Account]
Device = FSCARMEN-WARP-SHARE-TEAM
PrivateKey = SHVqHEGI7k2+OQ/oWMmWY2EQObbRQjRBdDPimh0h1WY=
Token = PROTECTED_PLACEHOLDER
Type = team

[Device]
Name = WARP
MTU  = 1280

[Peer]
PublicKey = bmXOC+F1FxEMF9dyiK2H5/1SUtzH0JuVo51h2wPfgyo=
Endpoint = 162.159.193.10:1701
KeepAlive = 30
# AllowedIPs = 0.0.0.0/0
# AllowedIPs = ::/0

[Script]
#PostUp = 
#PostDown =
EOF
      fi

    # 注册免费和 Plus 账户
    else
      [ -n "$LICENSE" ] && k='+' || k=' free'
      registe_api warp.conf 58 59
    fi

    # 如为 Plus 或 Team 账户，把设备名记录到文件 /opt/warp-go/Device_Name; Plus 账户的话，把 License 保存到 /opt/warp-go/License;
    grep -qE 'Type[ ]+=[ ]+plus' /opt/warp-go/warp.conf && echo "$NAME" > /opt/warp-go/Device_Name && echo "$LICENSE" > /opt/warp-go/License
    grep -qE 'Type[ ]+=[ ]+team' /opt/warp-go/warp.conf && echo "$NAME" > /opt/warp-go/Device_Name

    # 生成非全局执行文件并赋权
    cat > /opt/warp-go/NonGlobalUp.sh << EOF
sleep 5
ip -4 rule add oif WARP lookup 60000
ip -4 rule add table main suppress_prefixlength 0
ip -4 route add default dev WARP table 60000
ip -6 rule add oif WARP lookup 60000
ip -6 rule add table main suppress_prefixlength 0
ip -6 route add default dev WARP table 60000
EOF

    cat > /opt/warp-go/NonGlobalDown.sh << EOF
ip -4 rule delete oif WARP lookup 60000
ip -4 rule delete table main suppress_prefixlength 0
ip -6 rule delete oif WARP lookup 60000
ip -6 rule delete table main suppress_prefixlength 0
EOF

    chmod +x /opt/warp-go/NonGlobalUp.sh /opt/warp-go/NonGlobalDown.sh

    info "\n $(text 61) \n"
  }&

  # 对于 IPv4 only VPS 开启 IPv6 支持
  {
    [ "$IPV4$IPV6" = 10 ] && [[ $(sysctl -a 2>/dev/null | grep 'disable_ipv6.*=.*1') || $(grep -s "disable_ipv6.*=.*1" /etc/sysctl.{conf,d/*} ) ]] &&
    (sed -i '/disable_ipv6/d' /etc/sysctl.{conf,d/*}
    echo 'net.ipv6.conf.all.disable_ipv6 = 0' >/etc/sysctl.d/ipv6.conf
    sysctl -w net.ipv6.conf.all.disable_ipv6=0)
  }&

  # 优先使用 IPv4 /IPv6 网络
  { stack_priority; }&

  # 根据系统选择需要安装的依赖, 安装一些必要的网络工具包
  info "\n $(text 60) \n"

  case "$SYSTEM" in
    Alpine )
      ${PACKAGE_INSTALL[int]} openrc
      ;;
    Arch )
      ${PACKAGE_INSTALL[int]} openresolv
  esac

  wait

  # 如没有注册成功，脚本退出
  [ ! -s /opt/warp-go/warp.conf ] && error " $(text 104) " 

  # warp-go 配置修改，其中用到的 162.159.193.10 和 2606:4700:d0::a29f:c001 均是 engage.cloudflareclient.com 的 IP
  MTU=$(cat /tmp/warp-go-mtu) && rm -f /tmp/warp-go-mtu
  ENDPOINT=$(cat /tmp/warp-go-endpoint) && rm -f /tmp/warp-go-endpoint
  MODIFY014="/Endpoint6/d; /PreUp/d; /::\/0/d; s/162.159.*/$ENDPOINT/g; s#.*AllowedIPs.*#AllowedIPs = 0.0.0.0/0#g; s#.*PostUp.*#PostUp = ip -6 rule add from $LAN6 lookup main#g; s#.*PostDown.*#PostDown = ip -6 rule delete from $LAN6 lookup main\n\#PostUp = /opt/warp-go/NonGlobalUp.sh\n\#PostDown = /opt/warp-go/NonGlobalDown.sh#g; s#\(MTU.*\)1280#\1$MTU#g"
  MODIFY016="/Endpoint6/d; /PreUp/d; /::\/0/d; s/162.159.*/$ENDPOINT/g; s#.*AllowedIPs.*#AllowedIPs = ::/0#g; s#.*PostUp.*#PostUp   = ip -6 rule add from $LAN6 lookup main#g; s#.*PostDown.*#PostDown = ip -6 rule delete from $LAN6 lookup main\n\#PostUp = /opt/warp-go/NonGlobalUp.sh\n\#PostDown = /opt/warp-go/NonGlobalDown.sh#g; s#\(MTU.*\)1280#\1$MTU#g"
  MODIFY01D="/Endpoint6/d; /PreUp/d; /::\/0/d; s/162.159.*/$ENDPOINT/g; s#.*AllowedIPs.*#AllowedIPs = 0.0.0.0/0,::/0#g; s#.*PostUp.*#PostUp = ip -6 rule add from $LAN6 lookup main#g; s#.*PostDown.*#PostDown = ip -6 rule delete from $LAN6 lookup main\n\#PostUp = /opt/warp-go/NonGlobalUp.sh\n\#PostDown = /opt/warp-go/NonGlobalDown.sh#g; s#\(MTU.*\)1280#\1$MTU#g"
  MODIFY104="/Endpoint6/d; /PreUp/d; /::\/0/d; s/162.159.*/$ENDPOINT/g; s#.*AllowedIPs.*#AllowedIPs = 0.0.0.0/0#g; s#.*PostUp.*#PostUp = ip -4 rule add from $LAN4 lookup main#g; s#.*PostDown.*#PostDown = ip -4 rule delete from $LAN4 lookup main\n\#PostUp = /opt/warp-go/NonGlobalUp.sh\n\#PostDown = /opt/warp-go/NonGlobalDown.sh#g; s#\(MTU.*\)1280#\1$MTU#g"
  MODIFY106="/Endpoint6/d; /PreUp/d; /::\/0/d; s/162.159.*/$ENDPOINT/g; s#.*AllowedIPs.*#AllowedIPs = ::/0#g; s#.*PostUp.*#PostUp = ip -4 rule add from $LAN4 lookup main#g; s#.*PostDown.*#PostDown = ip -4 rule delete from $LAN4 lookup main\n\#PostUp = /opt/warp-go/NonGlobalUp.sh\n\#PostDown = /opt/warp-go/NonGlobalDown.sh#g; s#\(MTU.*\)1280#\1$MTU#g"
  MODIFY10D="/Endpoint6/d; /PreUp/d; /::\/0/d; s/162.159.*/$ENDPOINT/g; s#.*AllowedIPs.*#AllowedIPs = 0.0.0.0/0,::/0#g; s#.*PostUp.*#PostUp = ip -4 rule add from $LAN4 lookup main#g; s#.*PostDown.*#PostDown = ip -4 rule delete from $LAN4 lookup main\n\#PostUp = /opt/warp-go/NonGlobalUp.sh\n\#PostDown = /opt/warp-go/NonGlobalDown.sh#g; s#\(MTU.*\)1280#\1$MTU#g"
  MODIFY114="/Endpoint6/d; /PreUp/d; /::\/0/d; s/162.159.*/$ENDPOINT/g; s#.*AllowedIPs.*#AllowedIPs = 0.0.0.0/0#g; s#.*PostUp.*#PostUp = ip -4 rule add from $LAN4 lookup main\nPostUp = ip -6 rule add from $LAN6 lookup main#g; s#.*PostDown.*#PostDown = ip -4 rule delete from $LAN4 lookup main\nPostDown = ip -6 rule delete from $LAN6 lookup main\n\#PostUp = /opt/warp-go/NonGlobalUp.sh\n\#PostDown = /opt/warp-go/NonGlobalDown.sh#g; s#\(MTU.*\)1280#\1$MTU#g"
  MODIFY116="/Endpoint6/d; /PreUp/d; /::\/0/d; s/162.159.*/$ENDPOINT/g; s#.*AllowedIPs.*#AllowedIPs = ::/0#g; s#.*PostUp.*#PostUp = ip -4 rule add from $LAN4 lookup main\nPostUp = ip -6 rule add from $LAN6 lookup main#g; s#.*PostDown.*#PostDown = ip -4 rule delete from $LAN4 lookup main\nPostDown = ip -6 rule delete from $LAN6 lookup main\n\#PostUp = /opt/warp-go/NonGlobalUp.sh\n\#PostDown = /opt/warp-go/NonGlobalDown.sh#g; s#\(MTU.*\)1280#\1$MTU#g"
  MODIFY11D="/Endpoint6/d; /PreUp/d; /::\/0/d; s/162.159.*/$ENDPOINT/g; s#.*AllowedIPs.*#AllowedIPs = 0.0.0.0/0,::/0#g; s#.*PostUp.*#PostUp = ip -4 rule add from $LAN4 lookup main\nPostUp = ip -6 rule add from $LAN6 lookup main#g; s#.*PostDown.*#PostDown = ip -4 rule delete from $LAN4 lookup main\nPostDown = ip -6 rule delete from $LAN6 lookup main\n\#PostUp = /opt/warp-go/NonGlobalUp.sh\n\#PostDown = /opt/warp-go/NonGlobalDown.sh#g; s#\(MTU.*\)1280#\1$MTU#g"
  MODIFY11N4="/Endpoint6/d; /PreUp/d; /::\/0/d; s/162.159.*/$ENDPOINT/g; s#.*AllowedIPs.*#AllowedIPs = 0.0.0.0/0#g; s#.*PostUp.*#PostUp = ip -4 rule add from $LAN4 lookup main\nPostUp = ip -6 rule add from $LAN6 lookup main#g; s#.*PostDown.*#PostDown = ip -4 rule delete from $LAN4 lookup main\nPostDown = ip -6 rule delete from $LAN6 lookup main\n\#PostUp = /opt/warp-go/NonGlobalUp.sh\n\#PostDown = /opt/warp-go/NonGlobalDown.sh#g; s#\(MTU.*\)1280#\1$MTU#g"
  MODIFY11N6="/Endpoint6/d; /PreUp/d; /::\/0/d; s/162.159.*/$ENDPOINT/g; s#.*AllowedIPs.*#AllowedIPs = ::/0#g; s#.*PostUp.*#PostUp = ip -4 rule add from $LAN4 lookup main\nPostUp = ip -6 rule add from $LAN6 lookup main#g; s#.*PostDown.*#PostDown = ip -4 rule delete from $LAN4 lookup main\nPostDown = ip -6 rule delete from $LAN6 lookup main\n\#PostUp = /opt/warp-go/NonGlobalUp.sh\n\#PostDown = /opt/warp-go/NonGlobalDown.sh#g; s#\(MTU.*\)1280#\1$MTU#g"
  MODIFY11ND="/Endpoint6/d; /PreUp/d; /::\/0/d; s/162.159.*/$ENDPOINT/g; s#.*AllowedIPs.*#AllowedIPs = 0.0.0.0/0,::/0#g; s#.*PostUp.*#PostUp = ip -4 rule add from $LAN4 lookup main\nPostUp = ip -6 rule add from $LAN6 lookup main#g; s#.*PostDown.*#PostDown = ip -4 rule delete from $LAN4 lookup main\nPostDown = ip -6 rule delete from $LAN6 lookup main\n\#PostUp = /opt/warp-go/NonGlobalUp.sh\n\#PostDown = /opt/warp-go/NonGlobalDown.sh#g; s#\(MTU.*\)1280#\1$MTU#g"

  sed -i "$(eval echo "\$MODIFY$CONF")" /opt/warp-go/warp.conf

  # 如为 WARP IPv4 非全局，修改配置文件，在路由表插入规则
  [ "$OPTION" = n ] && STATUS=3 && global_switch

  # 创建 warp-go systemd 进程守护(Alpine 系统除外)
  if echo "$SYSTEM" | grep -qvE "Alpine|OpenWrt"; then
    cat > /lib/systemd/system/warp-go.service << EOF
[Unit]
Description=warp-go service
After=network.target
Documentation=https://github.com/fscarmen/warp
Documentation=https://gitlab.com/ProjectWARP/warp-go

[Service]
RestartSec=2s
WorkingDirectory=/opt/warp-go/
ExecStart=/opt/warp-go/warp-go --config=/opt/warp-go/warp.conf
Environment="LOG_LEVEL=verbose"
RemainAfterExit=yes
Restart=always

[Install]
WantedBy=multi-user.target
EOF
  fi

  # 运行 warp-go
  net

  # 设置开机启动
  ${SYSTEMCTL_ENABLE[int]} >/dev/null 2>&1

  # 创建软链接快捷方式，再次运行可以用 warp-go 指令，设置默认语言
  mv $0 /opt/warp-go/warp-go.sh
  chmod +x /opt/warp-go/warp-go.sh
  ln -sf /opt/warp-go/warp-go.sh /usr/bin/warp-go
  echo "$L" > /opt/warp-go/language

  # 结果提示，脚本运行时间，次数统计，IPv4 / IPv6 优先级别
  [ "$(curl -ksm8 -A Mozilla ${IP_API[3]} | grep 'ip=' | cut -d= -f2)" = "$WAN6" ] && PRIO=6 || PRIO=4
  end=$(date +%s)
  ACCOUNT_TYPE=$(grep "Type" /opt/warp-go/warp.conf | cut -d= -f2 | sed "s# ##g")
  [ "$ACCOUNT_TYPE" = 'plus' ] && check_quota
  result_priority

  echo -e "\n==============================================================\n"
  info " IPv4: $WAN4 $WARPSTATUS4 $COUNTRY4  $ASNORG4 "
  info " IPv6: $WAN6 $WARPSTATUS6 $COUNTRY6  $ASNORG6 "
  info " $(text_eval 62) "
  [ "$ACCOUNT_TYPE" = 'plus' ] && info " $(text 83): $(cat /opt/warp-go/Device_Name)\t $(text 26): $QUOTA "
  [ "$ACCOUNT_TYPE" = 'team' ] && info " $(text 83): $(cat /opt/warp-go/Device_Name)\t $(text 26): $(text 103) "
  info " $PRIORITY_NOW "
  echo -e "\n==============================================================\n"
  hint " $(text 95)\n " && help
  [ "$TRACE4$TRACE6" = offoff ] && warning " $(text 63) "
  exit
}

# 查 WARP+ 余额流量接口
check_quota() {
  if [ -s /opt/warp-go/warp.conf ]; then
    ACCESS_TOKEN=$(grep 'Token' /opt/warp-go/warp.conf | cut -d= -f2 | sed 's# ##g')
    DEVICE_ID=$(grep -m1 'Device' /opt/warp-go/warp.conf | cut -d= -f2 | sed 's# ##g')
    API=$(curl -s "https://api.cloudflareclient.com/v0a884/reg/$DEVICE_ID" -H "User-Agent: okhttp/3.12.1" -H "Authorization: Bearer $ACCESS_TOKEN")
    QUOTA=$(sed 's/.*quota":\([^,]\+\).*/\1/g' <<< $API)
  fi

  # 部分系统没有依赖 bc，所以两个小数不能用 $(echo "scale=2; $QUOTA/1000000000000000" | bc)，改为从右往左数字符数的方法
  if [[ "$QUOTA" != 0 && "$QUOTA" =~ ^[0-9]+$ && "$QUOTA" -ge 1000000000 ]]; then  
    CONVERSION=("1000000000000000000" "1000000000000000" "1000000000000" "1000000000")
    UNIT=("EB" "PB" "TB" "GB")
    for ((o=0; o<${#CONVERSION[*]}; o++)); do
      [[ "$QUOTA" -ge "${CONVERSION[o]}" ]] && break
    done

    QUOTA_INTEGER=$(( $QUOTA / ${CONVERSION[o]} ))
    QUOTA_DECIMALS=${QUOTA:0-$(( ${#CONVERSION[o]} - 1 )):2}
    QUOTA="$QUOTA_INTEGER.$QUOTA_DECIMALS ${UNIT[o]}"
  fi
}

# 判断当前 WARP 网络接口及 Client 的运行状态，并对应的给菜单和动作赋值
menu_setting() {
  if [ "$STATUS" = 0 ]; then
    MENU_OPTION[1]="$(text_eval 64)"
    MENU_OPTION[2]="$(text_eval 65)"
    MENU_OPTION[3]="$(text_eval 66)"
    MENU_OPTION[4]="$(text_eval 67)"
    MENU_OPTION[5]="$(text_eval 68)"
    MENU_OPTION[6]="$(text_eval 69)"
    MENU_OPTION[7]="$(text_eval 70)"
    MENU_OPTION[8]="$(text_eval 71)"
    ACTION[1]() { CONF=${CONF1[n]}; PRIORITY=1; install; }
    ACTION[2]() { CONF=${CONF1[n]}; PRIORITY=2; install; }
    ACTION[3]() { CONF=${CONF2[n]}; PRIORITY=1; install; }
    ACTION[4]() { CONF=${CONF2[n]}; PRIORITY=2; install; }
    ACTION[5]() { CONF=${CONF3[n]}; PRIORITY=1; install; }
    ACTION[6]() { CONF=${CONF3[n]}; PRIORITY=2; install; }
    ACTION[7]() { CONF=${CONF3[n]}; PRIORITY=1; OPTION=n; install; }
    ACTION[8]() { CONF=${CONF3[n]}; PRIORITY=2; OPTION=n; install; }
  else
    [ "$NON_GLOBAL" = 1 ] || GLOBAL_AFTER="$(text 24)"
    [ "$STATUS" = 2 ] && ON_OFF="$(text 72)" || ON_OFF="$(text 73)"
    MENU_OPTION[1]="$(text_eval 74)"
    MENU_OPTION[2]="$(text_eval 75)"
    MENU_OPTION[3]="$(text_eval 76)"
    MENU_OPTION[4]="$ON_OFF"
    MENU_OPTION[5]="$(text_eval 77)"

    MENU_OPTION[6]="$(text 78)"
    MENU_OPTION[7]="$(text 79)"
    MENU_OPTION[8]="$(text 80)"
    ACTION[1]() { stack_switch; }
    ACTION[2]() { stack_switch; }
    ACTION[3]() { global_switch; }
    ACTION[4]() { OPTION=o; onoff; }
    ACTION[5]() { update; }
    ACTION[6]() { change_ip; }
    ACTION[7]() { export_file; }
    ACTION[8]() { uninstall; }
  fi

  MENU_OPTION[0]="$(text 81)"
  MENU_OPTION[9]="$(text 82) (warp-go v)"
  ACTION[0]() { rm -f /tmp/warp-go*; exit; }
  ACTION[9]() { ver; }

  [ -s /opt/warp-go/warp.conf ] && TYPE=$(grep "Type" /opt/warp-go/warp.conf | cut -d= -f2 | sed "s# ##g")
  [ "$TYPE" = 'plus' ] && check_quota && PLUSINFO="$(text 83): $(cat /opt/warp-go/Device_Name)\t $(text 26): $QUOTA"
  [ "$TYPE" = 'team' ] && PLUSINFO="$(text 83): $(cat /opt/warp-go/Device_Name)\t $(text 26): $(text 103)"
}

# 显示菜单
menu() {
	clear
	hint " $(text 3) "
	echo -e "======================================================================================================================\n"
	info " $(text 84): $VERSION\n $(text 85): $(text 1)\n $(text 86):\n\t $(text 87): $SYS\n\t $(text 88): $(uname -r)\n\t $(text 89): $ARCHITECTURE\n\t $(text 90): $VIRT "
	info "\t IPv4: $WAN4 $WARPSTATUS4 $COUNTRY4  $ASNORG4 "
	info "\t IPv6: $WAN6 $WARPSTATUS6 $COUNTRY6  $ASNORG6 "
  if [ "$STATUS" = 2 ]; then
    info "\t $(text_eval 91) "
    grep -q '#AllowedIPs' /opt/warp-go/warp.conf && GLOBAL_TYPE="$(text 24)"
    info "\t $(text_eval 92) "
  else
    info "\t $(text 93) "
  fi
  [ -n "$PLUSINFO" ] && info "\t $PLUSINFO "
 	echo -e "\n======================================================================================================================\n"
	for ((d=1; d<=${#MENU_OPTION[*]}; d++)); do [ "$d" = "${#MENU_OPTION[*]}" ] && d=0 && hint " $d. ${MENU_OPTION[d]} " && break || hint " $d. ${MENU_OPTION[d]} "; done
  reading "\n $(text 4) " CHOOSE

  # 输入必须是数字且少于等于最大可选项
  if [[ "$CHOOSE" =~ ^[0-9]+$ ]] && (( $CHOOSE >= 0 && $CHOOSE < ${#MENU_OPTION[*]} )); then
    ACTION[$CHOOSE]
  else
    warning " $(text 34) [0-$((${#MENU_OPTION[*]}-1))] " && sleep 1 && menu
  fi
}

# 传参选项 OPTION：1=为 IPv4 或者 IPv6 补全另一栈WARP; 2=安装双栈 WARP; u=卸载 WARP
[ "$1" != '[option]' ] && OPTION=$(tr 'A-Z' 'a-z' <<< "$1")

# 参数选项 URL 或 License 或转换 WARP 单双栈
if [ "$2" != '[lisence]' ]; then
  if [[ "$2" =~ ^[A-Z0-9a-z]{8}-[A-Z0-9a-z]{8}-[A-Z0-9a-z]{8}$ ]]; then
    LICENSETYPE='2' && LICENSE="$2"
  elif [[ "${#2}" -ge "$TOKEN_LENGTH" ]]; then LICENSETYPE='3' && TOKEN="$2"
  elif [[ "$2" =~ ^[A-Za-z]{2}$ ]]; then EXPECT="$2"
  elif [[ "$1" = s && "$2" = [46Dd] ]]; then PRIORITY_SWITCH=$(tr 'A-Z' 'a-z' <<< "$2")
  fi
fi

# 自定义 WARP+ 设备名
NAME="$3"

# 主程序运行 1/3
statistics_of_run-times
select_language
check_operating_system
check_arch
check_dependencies
check_install

# 设置部分后缀 1/3
case "$OPTION" in
  h )
    help; exit 0
    ;;
  i )
    change_ip; exit 0
    ;;
  e )
    export_file; exit 0
    ;;
  s )
    stack_priority; result_priority; exit 0
esac

# 主程序运行 2/3
check_root_virt

# 设置部分后缀 2/3
case "$OPTION" in
  u )
    uninstall; exit 0
    ;;
  v )
    ver; exit 0
    ;;
  o )
    onoff; exit 0
    ;;
  g )
    global_switch; exit 0
esac

# 主程序运行 3/3
check_system_info
check_global
check_stack
menu_setting

# 设置部分后缀 3/3
case "$OPTION" in
  [46dn] )	
    if [[ $STATUS != 0 ]]; then
      SWITCHCHOOSE="$(tr 'a-z' 'A-Z' <<< "$OPTION")"
      stack_switch
    else
      case "$OPTION" in
        4 ) CONF=${CONF1[n]} ;; 
        6 ) CONF=${CONF2[n]} ;;
        d|n ) CONF=${CONF3[n]} ;;
      esac
      install
    fi
    ;;
  a )
    update
    ;;
  * ) menu
esac