# 创建安装暂时目录
mkdir /root/warp/ && cd /root/warp/

# Debian添加unstable源
echo "deb http://deb.debian.org/debian/ unstable main" > /etc/apt/sources.list.d/unstable-wireguard.list
printf 'Package: *\nPin: release a=unstable\nPin-Priority: 150\n' > /etc/apt/preferences.d/limit-unstable

# 更新源
apt update

# 安装一些必要的网络工具包和 wireguard-dkms 、 wireguard-tools (Wire-Guard 配置工具：wg、wg-quick)
apt -y --no-install-recommends install curl net-tools iproute2 openresolv dnsutils wireguard-dkms wireguard-tools

# 安装 wireguard-go（如安装了wireguard 内核模块，则不需要此步）
curl -fsSL git.io/wireguard-go.sh | bash

# 安装 wgcf
curl -fsSL git.io/wgcf.sh | bash

# 注册 WARP 账户 (将生成 wgcf-account.toml 文件保存账户信息)
echo | wgcf register

# 生成 Wire-Guard 配置文件 (wgcf-profile.conf)
wgcf generate

# 修改配置文件 wgcf-profile.conf 的内容,使得 IPv4 的流量均被 Wire­Guard 接管，让 IPv4 的流量通过 WARP IPv6 节点以 NAT 的方式访问外部 IPv4 网络
sed -i 10d wgcf-profile.conf | sed -i 's#engage.cloudflareclient.com#[2606:4700:d0::a29f:c001]#g' wgcf-profile.conf

# 把 wgcf-profile.conf 复制到/etc/wireguard/ 并命名为 wgcf.conf
cp wgcf-profile.conf /etc/wireguard/wgcf.conf

# 启用 Wire-Guard 网络接口守护进程
systemctl start wg-quick@wgcf

# 设置开机启动
systemctl enable wg-quick@wgcf

# 优先使用 IPv4 网络
echo 'precedence  ::ffff:0:0/96   100' | tee -a /etc/gai.conf

# 删除临时目录和文件
cd /root/ && rm -rf /root/warp/ /root/debian.sh
