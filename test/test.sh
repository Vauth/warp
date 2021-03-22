##### 为 IPv6 only VPS 添加 WGCF #####
##### LXC 非完整虚拟化 VPS 主机，选择 "wireguard-go" 方案。##### 

# 判断系统，安装差异部分依赖包

# Debian 运行以下脚本
if grep -q -E -i "debian" /etc/issue; then
	
	# 更新源
	apt update

	# 添加 backports 源,之后才能安装 wireguard-tools 
	apt -y install lsb-release
	echo "deb http://deb.debian.org/debian $(lsb_release -sc)-backports main" | tee /etc/apt/sources.list.d/backports.list

	# 再次更新源
	apt update

	# 安装一些必要的网络工具包和wireguard-tools (Wire-Guard 配置工具：wg、wg-quick)
	apt -y --no-install-recommends install net-tools iproute2 openresolv dnsutils wireguard-tools

# Ubuntu 运行以下脚本
  elif grep -q -E -i "ubuntu" /etc/issue; then

	# 更新源
	apt update

	# 安装一些必要的网络工具包和wireguard-tools (Wire-Guard 配置工具：wg、wg-quick)
	apt -y --no-install-recommends install net-tools iproute2 openresolv dnsutils wireguard-tools

# CentOS 运行以下脚本
  elif grep -q -E -i "kernel" /etc/issue; then

  # 安装一些必要的网络工具包和wireguard-tools (Wire-Guard 配置工具：wg、wg-quick)
	yum -y install curl net-tools wireguard-tools

# 如都不符合，提示,删除临时文件并中止脚本
  else 
	# 提示找不到相应操作系统
	echo -e "Sorry，I don't know this operating system!"
	
	# 删除临时目录和文件，退出脚本
	rm -f warp*
	exit 0

fi


# 以下为3类系统公共部分

# 安装 wireguard-go
wget -N -P /usr/bin https://github.com/fscarmen/warp/raw/main/wireguard-go

# 安装 wgcf
wget -N -O /usr/local/bin/wgcf https://github.com/ViRb3/wgcf/releases/download/v2.2.3/wgcf_2.2.3_linux_amd64

# 添加执行权限
chmod +x /usr/bin/wireguard-go /usr/local/bin/wgcf

# 注册 WARP 账户 (将生成 wgcf-account.toml 文件保存账户信息)
echo | wgcf register

# 生成 Wire-Guard 配置文件 (wgcf-profile.conf)
wgcf generate
  
# 修改配置文件 wgcf-profile.conf 的内容,使得 IPv4 的流量均被 WireGuard 接管，让 IPv4 的流量通过 WARP IPv6 节点以 NAT 的方式访问外部 IPv4 网络，为了防止当节点发生故障时 DNS 请求无法发出，修改为 IPv6 地址的 DNS
sed -i '/\:\:\/0/d' wgcf-profile.conf | sed -i 's/engage.cloudflareclient.com/[2606:4700:d0::a29f:c001]/g' wgcf-profile.conf | sed -i 's/1.1.1.1/2620:fe::10,2001:4860:4860::8888,2606:4700:4700::1111/g' wgcf-profile.conf

# 把 wgcf-profile.conf 复制到/etc/wireguard/ 并命名为 wgcf.conf
cp wgcf-profile.conf /etc/wireguard/wgcf.conf

# 启用 Wire-Guard 网络接口守护进程
systemctl start wg-quick@wgcf

# 设置开机启动
systemctl enable wg-quick@wgcf

# 优先使用 IPv4 网络
echo 'precedence  ::ffff:0:0/96   100' | tee -a /etc/gai.conf

# 删除临时文件
rm -f warp* wgcf*

# 结果提示
ip a
echo -e "\033[32m 有 wgcf 的网络接口即为成功。如报错 429 Too Many Requests ，可多次运行脚本直至成功。 \033[0m"
