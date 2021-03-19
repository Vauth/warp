# 创建安装暂时目录
mkdir warp && cd warp

# 判断系统，安装差异部分

# Ubuntu 运行以下脚本
if grep -q -E -i "ubuntu" /etc/issue; then

	# 更新源
	sudo apt update

	# 安装一些必要的网络工具包和 wireguard内核模块、wireguard-tools (Wire-Guard 配置工具：wg、wg-quick)
	sudo apt -y --no-install-recommends install curl net-tools iproute2 openresolv dnsutils wireguard-dkms wireguard-tools

	# 安装 wgcf
	curl -fsSL git.io/wgcf.sh | sudo bash

	# 注册 WARP 账户 (将生成 wgcf-account.toml 文件保存账户信息)
	echo | sudo wgcf register

	# 生成 Wire-Guard 配置文件 (wgcf-profile.conf)
	sudo wgcf generate

# CentOS 运行以下脚本
     elif grep -q -E -i "kernel" /etc/issue; then

        # 安装一些必要的网络工具包和wireguard-tools (Wire-Guard 配置工具：wg、wg-quick)
	sudo yum -y install curl net-tools wireguard-tools

	# 安装 wireguard-go（如安装了wireguard 内核模块，则不需要此步)
	sudo wget -P /usr/bin https://github.com/bernardkkt/wg-go-builder/releases/latest/download/wireguard-go

	# 安装 wgcf
	sudo wget -O wgcf https://github.com/ViRb3/wgcf/releases/download/v2.2.3/wgcf_2.2.3_linux_amd64

	# 添加执行权限
	sudo chmod +x /usr/bin/wireguard-go wgcf

	# 注册 WARP 账户 (将生成 wgcf-account.toml 文件保存账户信息)
	echo | sudo ./wgcf register

	# 生成 Wire-Guard 配置文件 (wgcf-profile.conf)
	sudo ./wgcf generate

# 如都不符合，提示,删除临时文件并中止脚本
     else 
	# 提示找不到相应操作系统
	echo -e "Sorry，I don't know this operating system!"
	
	# 删除临时目录和文件，退出脚本
	cd .. && rm -rf ./warp warp*
	exit 0

fi


# 以下为2个系统公共部分

# 修改配置文件 wgcf-profile.conf 的内容,使得 IPv6 的流量均被 WireGuard 接管，让 IPv6 的流量通过 WARP IPv4 节点以 NAT 的方式访问外部 IPv6 网络，为了防止当节点发生故障时 DNS 请求无法发出，修改为 IPv4 地址的 DNS
sudo sed -i '/0\.\0\/0/d' wgcf-profile.conf | sudo sed -i 's/engage.cloudflareclient.com/162.159.192.1/g' wgcf-profile.conf | sudo sed -i 's/1.1.1.1/9.9.9.10,8.8.8.8,1.1.1.1/g' wgcf-profile.conf

# 把 wgcf-profile.conf 复制到/etc/wireguard/ 并命名为 wgcf.conf
sudo cp wgcf-profile.conf /etc/wireguard/wgcf.conf

# 启用 Wire-Guard 网络接口守护进程
sudo systemctl start wg-quick@wgcf

# 设置开机启动
sudo systemctl enable wg-quick@wgcf

# 优先使用 IPv4 网络
echo 'precedence  ::ffff:0:0/96   100' | sudo tee -a /etc/gai.conf

# 删除临时目录和文件
cd .. && rm -rf ./warp warp*

# 有 wgcf 的网络接口即为成功
ip a
