# 【WGCF】连接CF WARP为服务器添加IPv4/IPv6网络

好处：能让像EUserv这样的IPv6 only VPS上做的节点支持tg，解锁奈飞流媒体，可调用IPv4接口使京*docker和V2P等正确运行。

WARP是CloudFlare提供的一项基于WireGuard的网络流量安全及加速服务，能够让你通过连接到CloudFlare的边缘节点实现隐私保护及链路优化。

其连接入口为双栈（IPv4/IPv6均可），且连接后能够获取到由CF提供基于NAT的IPv4和IPv6地址，因此我们的单栈服务器可以尝试连接到WARP来获取额外的网络连通性支持。这样我们就可以让仅具有IPv6的服务器访问IPv4，也能让仅具有IPv4的服务器获得IPv6的访问能力。

## 为仅IPv6服务器添加IPv4


原理如图，IPv4的流量均被WARP网卡接管，实现了让IPv4的流量通过WARP访问外部网络。

![](https://cdn.luotianyi.vc/wp-content/uploads/2021-02-04_21-45-45.png)

## 为仅IPv4服务器添加IPv6

原理如图，IPv6的流量均被WARP网卡接管，实现了让IPv6的流量通过WARP访问外部网络。

![](https://cdn.luotianyi.vc/wp-content/uploads/2021-02-04_21-45-44.png)

## 双栈服务器置换网络

有时我们的服务器本身就是双栈的，但是由于种种原因我们可能并不想使用其中的某一种网络，这时也可以通过WARP接管其中的一部分网络连接隐藏自己的IP地址。至于这样做的目的，最大的意义是减少一些滥用严重机房出现验证码的概率；同时部分内容提供商将WARP的落地IP视为真实用户的原生IP对待，能够解除一些基于IP识别的封锁。

![](https://cdn.luotianyi.vc/wp-content/uploads/2021-02-04_21-45-45-1.png)

## 为IPv6服务器添加IPv4网络接口方法
EUserv 以下三个系统用 hostnamectl 查内核都是: Linux 4.20.8-1.el7.elrepo.x86_64，脚本测试通过。

Ubuntu 20.04
```bash
echo -e "nameserver 2a00:1098:2b::1\nnameserver 2a03:7900:2:0:31:3:104:161" > /etc/resolv.conf
```
```bash
wget -P /root --no-check-certificate "https://raw.githubusercontent.com/fscarmen/warp/main/ubuntu.sh" && chmod +x /root/ubuntu.sh && /root/ubuntu.sh
```
Debian 10
```bash
echo -e "nameserver 2a00:1098:2b::1\nnameserver 2a03:7900:2:0:31:3:104:161" > /etc/resolv.conf
```
```bash
wget -P /root --no-check-certificate "https://raw.githubusercontent.com/fscarmen/warp/main/debian.sh" && chmod +x /root/debian.sh && /root/debian.sh
```
CentOS 8
```bash
echo -e "nameserver 2a00:1098:2b::1\nnameserver 2a03:7900:2:0:31:3:104:161" > /etc/resolv.conf
```
```bash
wget -P /root --no-check-certificate "https://raw.githubusercontent.com/fscarmen/warp/main/centos.sh" && chmod +x /root/centos.sh && /root/centos.sh
```
查看安装是否成功 ```ip a```，有wgcf的网络接口即为成功。

## 临时、永久关闭和开启

临时关闭 wgcf（reboot重启后恢复开启） ```wg-quick down wgcf``` ，恢复启动 ```wg-quick up wgcf```

禁止开机启动 ```systemctl disable wg-quick@wgcf```,恢复开机启动 ```systemctl enable wg-quick@wgcf```


## 参考文章，文件、图片引用（排名不分先后）： 
作业是全抄以下作者:P3terx和甬哥探世界，我稍作优化,整理并加上系统判断方便安装。
* https://p3terx.com/archives/use-cloudflare-warp-to-add-extra-ipv4-or-ipv6-network-support-to-vps-servers-for-free.html
* https://www.youtube.com/watch?v=78dZgYFS-Qo
* https://luotianyi.vc/5252.html
* https://github.com/ViRb3/wgcf
