起因：2021年3月25日开始，部分德鸡即使添加了nat64后，仍不能正常访问ipv4网络，也就不能正常使用github了，最明显表现为登陆时主机名不再显示 srv12345，即是显示为 DiG9。

应对办法：经测试，暂只有 Debian 10 通过 wgcf 救活，另外两个系统 Ubuntu 20.04 和 CentOS 8 甚至连 apt update 都报错。

步骤：下载本文件夹下的3个文件到本地：DiG9-debian.sh、wgcf、wireguard-go，上传到德鸡 /root 目录下,执行下面指令。
     
     chmod +x DiG9-debian.sh && ./DiG9-debian.sh


上级目录 甲骨文 增加 IPv4 的方法仍然有效。
