# Euserv 主机名变为 DiG9 不能正常使用 Nat64 解决办法

起因：2021年3月25日开始，部分德鸡即使添加了nat64后，仍不能正常访问ipv4网络，也就不能正常使用github了，最明显表现为登陆时主机名不再显示 srv12345，而显示为 DiG9。

应对办法：经测试，暂只有 Debian 10 通过 wgcf 救活，另外两个系统 Ubuntu 20.04 和 CentOS 8 甚至连 ```apt update``` 也报错。

步骤：下载本文件夹下的3个文件到本地：DiG9-debian.sh、wgcf、wireguard-go，上传到德鸡 /root 目录下,执行下面指令。 [打包下载](https://link.jscdn.cn/1drv/aHR0cHM6Ly8xZHJ2Lm1zL3UvcyFBczJObkY3TXVRYlhnU2oyeFpaY3VuaHp1Q1ZsP2U9d25xdDE0)

 ```bash
  chmod +x DiG9-debian.sh && ./DiG9-debian.sh
 ```

PS:甲骨文 增加 IPv4 的方法仍然有效。 [点击直达](https://github.com/fscarmen/warp#wgcf%E8%BF%9E%E6%8E%A5cf-warp%E4%B8%BA%E6%9C%8D%E5%8A%A1%E5%99%A8%E6%B7%BB%E5%8A%A0ipv4ipv6%E7%BD%91%E7%BB%9C)
