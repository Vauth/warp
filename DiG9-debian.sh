# 更新源
apt update

# 添加 backports 源,之后才能安装 wireguard-tools 
apt -y install lsb-release
echo "deb http://deb.debian.org/debian $(lsb_release -sc)-backports main" | tee /etc/apt/sources.list.d/backports.list

# 再次更新源
apt update

# 安装一些必要的网络工具包和 wireguard-tools (Wire-Guard 配置工具：wg、wg-quick)
apt -y --no-install-recommends install net-tools iproute2 openresolv dnsutils wireguard-tools

# 把两个必要文件复制到相应路径
cp wireguard-go /usr/bin
cp wgcf /usr/local/bin/wgcf

# 添加执行权限
chmod +x /usr/bin/wireguard-go wgcf

# 注册 WARP 账户 (将生成 wgcf-account.toml 文件保存账户信息)
echo | ./wgcf register

# 生成 Wire-Guard 配置文件 (wgcf-profile.conf)
./wgcf generate

# 修改配置文件 wgcf-profile.conf 的内容,使得 IPv4 的流量均被 WireGuard 接管，让 IPv4 的流量通过 WARP IPv6 节点以 NAT 的方式访问外部 IPv4 网络
sed -i '/\:\:\/0/d' wgcf-profile.conf | sed -i 's/engage.cloudflareclient.com/[2606:4700:d0::a29f:c001]/g' wgcf-profile.conf

# 把 wgcf-profile.conf 复制到/etc/wireguard/ 并命名为 wgcf.conf
cp wgcf-profile.conf /etc/wireguard/wgcf.conf

# 启用 Wire-Guard 网络接口守护进程
systemctl start wg-quick@wgcf

# 设置开机启动
systemctl enable wg-quick@wgcf

# 优先使用 IPv4 网络
echo 'precedence  ::ffff:0:0/96   100' | tee -a /etc/gai.conf

# 结果提示
ip a
echo -e "\033[32m 结果：上面有 wgcf 的网络接口即为成功。如报错 429 Too Many Requests ，可再次运行 ./DiG9-debian.sh 直至成功。 \033[0m"
