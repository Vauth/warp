##### 解决 Euserv 访问不了IPv4的问题，已在 Ubuntu 20.04 、 Debian 10 和 CentOS 8 测试通过 #####

# 还原 EUserv 初始的 resolv.conf
echo -e "search blue.kundencontroller.de\noptions rotate\nnameserver 2a02:180:6:5::1c\nnameserver 2a02:180:6:5::4\nnameserver 2a02:180:6:5::1e\nnameserver 2a02:180:6:5::1d" > /etc/resolv.conf

# 判断系统

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
	apt -y --no-install-recommends install openresolv dnsutils wireguard-tools

# Ubuntu 运行以下脚本
  elif grep -q -E -i "ubuntu" /etc/issue; then

	# 更新源
	apt update

	# 安装一些必要的网络工具包和wireguard-tools (Wire-Guard 配置工具：wg、wg-quick)
	apt -y --no-install-recommends install openresolv dnsutils wireguard-tools

# CentOS 运行以下脚本
  elif grep -q -E -i "kernel" /etc/issue; then

 	# 替换为中国科技大学的elrepo源
	wget -6 -N -P /etc/yum.repos.d/ https://cdn.jsdelivr.net/gh/fscarmen/warp/DiG9/elrepo.repo
	

	# 安装一些必要的网络工具包和wireguard-tools (Wire-Guard 配置工具：wg、wg-quick)
	yum -6 -y install net-tools wireguard-tools


# 如都不符合，提示,删除临时文件并中止脚本
  else 
	# 提示找不到相应操作系统
	echo -e "\033[32m 抱歉，我不认识此系统！\033[0m"
	
	# 删除临时目录和文件，退出脚本
	rm -f DiG9*
	exit 0

fi

# 以下为3类系统公共部分

# 安装 wireguard-go
wget -nc -6 -P /usr/bin https://cdn.jsdelivr.net/gh/fscarmen/warp/DiG9/wireguard-go

# 安装 wgcf
wget -nc -6 -O /usr/local/bin/wgcf https://cdn.jsdelivr.net/gh/fscarmen/warp/DiG9/wgcf

# 添加执行权限
chmod +x /usr/bin/wireguard-go /usr/local/bin/wgcf

# 注册 WARP 账户 (将生成 wgcf-account.toml 文件保存账户信息)
echo | wgcf register
until [ $? -eq 0 ]  
  do
   echo -e "\033[32m warp 注册接口繁忙，3秒后自动重试直到成功。 \033[0m"
   sleep 3
   echo | wgcf register
done

# 生成 Wire-Guard 配置文件 (wgcf-profile.conf)
wgcf generate
  
# 修改配置文件 wgcf-profile.conf 的内容,使得 IPv4 的流量均被 WireGuard 接管，让 IPv4 的流量通过 WARP IPv6 节点以 NAT 的方式访问外部 IPv4 网络
sed -i '/\:\:\/0/d' wgcf-profile.conf | sed -i 's/engage.cloudflareclient.com/[2606:4700:d0::a29f:c001]/g' wgcf-profile.conf

# 把 wgcf-profile.conf 复制到/etc/wireguard/ 并命名为 wgcf.conf
cp wgcf-profile.conf /etc/wireguard/wgcf.conf

# 自动刷直至成功（ warp bug，有时候获取不了ip地址）
wg-quick up wgcf >/dev/null 2>&1
until [[ -n $(wget -T1 -t1 -qO- -4 ip.gs) ]]
  do
   wg-quick down wgcf >/dev/null 2>&1
   wg-quick up wgcf >/dev/null 2>&1
done

# 设置开机启动
systemctl enable wg-quick@wgcf

# 优先使用 IPv4 网络
grep -qE '^[ ]*precedence[ ]*::ffff:0:0/96[ ]*100' /etc/gai.conf || echo 'precedence ::ffff:0:0/96  100' | tee -a /etc/gai.conf

# 删除临时文件
rm -f DiG9* wgcf*

# 结果提示
echo -e "\033[32m 恭喜！为 IPv6 only VPS 添加 warp 已成功，IPv4地址为:$(wget -qO- ipv4.ip.sb) \033[0m"
