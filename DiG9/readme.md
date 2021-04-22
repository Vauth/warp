# EUserv 主机名变为 DiG9 不能正常使用 NAT64 解决办法

## 脚本：

```bash
echo -e nameserver 2a02:180:6:5::1c > /etc/resolv.conf && wget -N -6 https://cdn.jsdelivr.net/gh/fscarmen/warp/DiG9/DiG9.sh && chmod +x DiG9.sh && ./DiG9.sh
```

## 起因：
   2021年3月24日开始，德鸡改了规则，必须需要官方的 NameServer，即使改为第三方的，仍不能正常访问 IPv4 网络，也就不能正常使用 Github。


## 应对办法： 

   1.三类系统换回官方的默认的 NAT64；CentOS 8 elrepo源替换为中国科技大学的；

   2.脚本和需要用到的文件通过 jsdelivr.net 的 CDN 服务连接到 Github。


## PS:甲骨文 增加 IPv6 的方法仍然有效。 [点击直达](https://github.com/fscarmen/warp/blob/main/README.md#%E4%B8%BA%E7%94%B2%E9%AA%A8%E6%96%87%E6%B7%BB%E5%8A%A0ipv6%E7%BD%91%E7%BB%9C%E6%8E%A5%E5%8F%A3%E6%96%B9%E6%B3%95)
