##### 为 IPv4 only 或 原生双栈 VPS 添加 WGCF，双栈走 warp #####
##### KVM 属于完整虚拟化的 VPS 主机，网络性能方面：内核集成WireGuard＞内核模块＞wireguard-go。#####

# 输入 Warp+ 账户（如有），限制位数为空或者26位以防输入错误
read -p "如有 Warp+ License 请输入，没有可回车继续:" LICENSE

# 在KVM的前提下，判断 Linux 版本是否小于等于 5.6，如是则安装 wireguard 内核模块，变量 wg=1
if  [[ $(uname  -r | awk -F . '{print $1 }') -lt 5 ]]; then wg=1
	elif [[ $(uname  -r | awk -F . '{print $1 }') -eq 5 ]]
		then if [[ $(uname  -r | awk -F . '{print $2 }') -lt 6 ]]; then wg=1; fi
fi

# 判断系统，安装差异部分依赖包
echo -e "\033[32m (1/3) 安装系统依赖和 wireguard 内核模块 \033[0m"

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
	if [[ $wg == 1 ]]; then curl -Lo /etc/yum.repos.d/wireguard.repo https://copr.fedorainfracloud.org/coprs/jdoss/wireguard/repo/epel-7/jdoss-wireguard-epel-7.repo; yum -y install epel-release wireguard-dkms; fi

	# 升级所有包同时也升级软件和系统内核
	yum -y update

	# 添加执行文件环境变量
	if [[ $PATH =~ /usr/local/bin ]]; then export PATH=$PATH; else export PATH=$PATH:/usr/local/bin; fi

# 如都不符合，提示,删除临时文件并中止脚本
     else 
	# 提示找不到相应操作系统
	echo -e "\033[31m 本脚本只支持 Debian、Ubuntu 和 CentOS 系统 \033[0m"
	
	# 删除临时目录和文件，退出脚本
	rm -f dualstack6.sh menu.sh
	exit 0

fi

# 以下为3类系统公共部分
echo -e "\033[32m (2/3) 安装 WGCF \033[0m"

# 判断系统架构是 AMD 还是 ARM
if [[ $(hostnamectl) =~ .*arm.* ]]
        then architecture=arm64
        else architecture=amd64
fi

# 判断 wgcf 的最新版本
latest=$(wget --no-check-certificate -qO- -t1 -T2 "https://api.github.com/repos/ViRb3/wgcf/releases/latest" | grep "tag_name" | head -n 1 | awk -F ":" '{print $2}' | sed 's/\"//g;s/v//g;s/,//g;s/ //g')

# 安装 wgcf
sudo wget --no-check-certificate -N -4 -O /usr/local/bin/wgcf https://github.com/ViRb3/wgcf/releases/download/v$latest/wgcf_${latest}_linux_$architecture

# 添加执行权限
sudo chmod +x /usr/local/bin/wgcf

# 注册 WARP 账户 (将生成 wgcf-account.toml 文件保存账户信息，为避免文件已存在导致出错，先尝试删掉原文件)
rm -f wgcf-account.toml
echo -e "\033[33m wgcf 注册中…… \033[0m"
until [[ -a wgcf-account.toml ]]
  do
   echo | wgcf register >/dev/null 2>&1
done

# 如有 Warp+ 账户，修改 license 并升级
[[ -n $LICENSE ]] && echo -e "\033[33m 升级 Warp+ 账户 \033[0m" && sed -i "s/license_key.*/license_key = \"$LICENSE\"/g" wgcf-account.toml &&
( wgcf update || echo -e "\033[31m 升级失败，Warp+ 账户错误或者已激活超过5台设备，自动更换免费 Warp 账户继续\033[0m " )

# 生成 Wire-Guard 配置文件 (wgcf-profile.conf)
wgcf generate >/dev/null 2>&1

# 修改配置文件 wgcf-profile.conf 的内容,使得 IPv6 的流量均被 WireGuard 接管，让 IPv6 的流量通过 WARP IPv4 节点以 NAT 的方式访问外部 IPv6 网络，为了防止当节点发生故障时 DNS 请求无法发出，修改为 IPv4 地址的 DNS
sudo sed -i "7 s/^/PostUp = ip -4 rule add from $(ip route get 114.114.114.114 | grep -oP 'src \K\S+') lookup main\n/" wgcf-profile.conf && sudo sed -i "8 s/^/PostDown = ip -4 rule delete from $(ip route get 114.114.114.114 | grep -oP 'src \K\S+') lookup main\n/" wgcf-profile.conf && sudo sed -i 's/engage.cloudflareclient.com/162.159.192.1/g' wgcf-profile.conf && sudo sed -i 's/1.1.1.1/9.9.9.9,8.8.8.8,1.1.1.1/g' wgcf-profile.conf

# 如果系统原来是双栈，则需要添加 IPv6 的处理
if [[ -n $(wget -T1 -t1 -qO- -6 ip.gs) ]]; then
	sudo sed -i "9 s/^/PostUp = ip -6 rule add from $(ip route get 2400:3200::1 | grep -oP 'src \K\S+') lookup main\n/" wgcf-profile.conf && sudo sed -i "10 s/^/PostDown = ip -6 rule delete from $(ip route get 2400:3200::1 | grep -oP 'src \K\S+') lookup main\n/" wgcf-profile.conf
fi

# 把 wgcf-profile.conf 复制到/etc/wireguard/ 并命名为 wgcf.conf
sudo cp wgcf-profile.conf /etc/wireguard/wgcf.conf

# 自动刷直至成功（ warp bug，有时候获取不了ip地址）
echo -e "\033[32m (3/3) 运行 WGCF \033[0m"
echo -e "\033[33m 后台获取 warp IP 中…… \033[0m"
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
echo -e "\033[32m 恭喜！WARP已开启，IPv4地址为:$(wget -qO- -4 ip.gs)，IPv6地址为:$(wget -qO- -6 ip.gs) \033[0m"

# 删除临时文件
rm -f dualstack6.sh wgcf-account.toml wgcf-profile.conf menu.sh
