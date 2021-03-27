# EUserv 主机名变为 DiG9 不能正常使用 NAT64 解决办法

起因：2021年3月25日开始，部分德鸡即使添加了 NAT64 后，仍不能正常访问 IPv4 网络，也就不能正常使用 Github 了，最明显表现为登陆时主机名不再是 Srv+数字 开头，而显示为 DiG9。

故障定点：EUserv 官方限制 NAT64 Nameserver，凡是主机名是 DiG9 的必须用官方的不能更换。而主机名是 Srv开头的暂未受影响。

应对办法：Ubuntu 20.04 和 Debian 10，换回官方的默认的 NAT64；
        CentOS 8， elrepo源替换为中国科技大学的。

复活步骤：下载本路径的4个文件到本地：DiG9.sh、wgcf、wireguard-go、elrepo.repo，上传到德鸡 /root 目录下,执行下面指令。 [打包下载](https://link.jscdn.cn/1drv/aHR0cHM6Ly8xZHJ2Lm1zL3UvcyFBczJObkY3TXVRYlhnU2oyeFpaY3VuaHp1Q1ZsP2U9d25xdDE0)

 ```bash
  chmod +x DiG9.sh && ./DiG9.sh
 ```

PS:甲骨文 增加 IPv4 的方法仍然有效。 [点击直达](https://github.com/fscarmen/warp#wgcf%E8%BF%9E%E6%8E%A5cf-warp%E4%B8%BA%E6%9C%8D%E5%8A%A1%E5%99%A8%E6%B7%BB%E5%8A%A0ipv4ipv6%E7%BD%91%E7%BB%9C)
