# 创建安装暂时目录
mkdir /root/warp/ && cd /root/warp/

# 更新源
apt update

# 安装一些必要的网络工具包和wireguard-tools (Wire-Guard 配置工具：wg、wg-quick)
apt -y --no-install-recommends install net-tools iproute2 openresolv dnsutils wireguard-tools

# 安装 wireguard-go（如安装了wireguard 内核模块，则不需要此步)
wget -P /usr/bin https://github.com/bernardkkt/wg-go-builder/releases/latest/download/wireguard-go

# 安装 wgcf
wget -O wgcf https://github.com/ViRb3/wgcf/releases/download/v2.2.3/wgcf_2.2.3_linux_amd64

# 添加执行权限
chmod +x /usr/bin/wireguard-go wgcf

# 注册 WARP 账户 (将生成 wgcf-account.toml 文件保存账户信息)
echo | ./wgcf register

# 生成 Wire-Guard 配置文件 (wgcf-profile.conf)
./wgcf generate

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

# 删除临时目录和文件
cd /root/ && rm -rf /root/warp/ /root/ubuntu*

# 有 wgcf 的网络接口即为成功
ip a