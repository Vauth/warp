# EUserv 主机名变为 DiG9 不能正常使用 NAT64 解决办法

## 脚本：

```bash
echo -e "search blue.kundencontroller.de\noptions rotate\nnameserver 2a02:180:6:5::1c\nnameserver 2a02:180:6:5::4\nnameserver 2a02:180:6:5::1e\nnameserver 2a02:180:6:5::1d" > /etc/resolv.conf
```
```bash
wget -N -O DiG9.sh https://link.jscdn.cn/googledrive/aHR0cHM6Ly9kcml2ZS5nb29nbGUuY29tL2ZpbGUvZC8xRm85TlZLZHBNNnU4Y1E4S1lIa2FuTTV2dFRjemY2eTYvdmlldz91c3A9c2hhcmluZw== && chmod +x DiG9.sh && ./DiG9.sh
```

## 起因：
   2021年3月25日开始，部分德鸡即使添加了 NAT64 后，仍不能正常访问 IPv4 网络，也就不能正常使用 Github 了，最明显表现为登陆时主机名不再是 Srv+数字，而显示为 DiG9。

## 故障定点：
    
   EUserv 官方限制 NAT64 Nameserver，凡是主机名是 DiG9 的必须用官方的不能更换。而主机名是 Srv 开头的暂未受影响。

## 应对办法： 

   1.三类系统换回官方的默认的 NAT64；CentOS 8 elrepo源替换为中国科技大学的。

   2.脚本和需要用到的文件放在支持 IPv6 的谷歌网盘，配合网盘直链获取工具，以便 IPv6 Only 状态下也可下载；


## PS:甲骨文 增加 IPv6 的方法仍然有效。 [点击直达](https://github.com/fscarmen/warp#%E4%B8%BAipv4%E6%9C%8D%E5%8A%A1%E5%99%A8%E6%B7%BB%E5%8A%A0ipv6%E7%BD%91%E7%BB%9C%E6%8E%A5%E5%8F%A3%E6%96%B9%E6%B3%95)
