# 【WGCF】连接CF WARP为服务器添加IPv4/IPv6网络

* * *

# 目录

- [脚本特点](README.md#脚本特点)
- [WARP好处](README.md#WARP好处)
- [菜单选择（推荐）](README.md#菜单选择推荐)
- [为 KVM IPv4 only 添加 IPv6 网络接口方法](README.md#为-kvm-ipv4-only-添加-ipv6-网络接口方法)
- [为 KVM IPv4 only 或原生双栈 添加双栈网络接口方法](README.md#为-kvm-ipv4-only-或原生双栈-添加双栈网络接口方法)
- [为 KVM IPv6 only 添加 IPv4 网络接口方法](README.md#为-kvm-ipv6-only-添加-ipv4-网络接口方法)
- [为 KVM IPv6 only 添加双栈网络接口方法](README.md#为-kvm-ipv6-only-添加双栈网络接口方法)
- [为 LXC IPv6 only 添加 IPv4 网络接口方法](README.md#为-lxc-ipv6-only-添加-ipv4-网络接口方法)
- [为 LXC IPv6 only 添加双栈网络接口方法](README.md#为-lxc-ipv6-only-添加双栈网络接口方法)
- [临时、永久关闭和开启WGCF网络接口](README.md#临时永久关闭和开启WGCF网络接口)
- [EUserv 主机名变为 DiG9 不能正常使用 NAT64 解决办法](https://github.com/fscarmen/warp/tree/main/DiG9#euserv-主机名变为-dig9-不能正常使用-nat64-解决办法)
- [WARP原理](README.md#WARP原理)
- [致谢](README.md#致谢下列作者和项目排名不分先后)

* * *

## 脚本特点

* 根据不同系统综合情况显示不同的窗口，没有不必要的选项，避免出错
* 结合 Linux 版本和虚拟化方式，自动优选三个 WireGuard 方案。网络性能方面：内核集成 WireGuard＞安装内核模块＞wireguard-go
* 智能判断 wgcf 作者 github库的最新版本 （Latest release），
* 智能判断vps操作系统：Ubuntu 18.04、Ubuntu 20.04、Debian 10、Debian 11、CentOS 7、CentOS 8，请务必选择 LTS 系统
* 智能判断硬件结构类型：Architecture 为 AMD 或者 ARM
* 智能分析内网和公网IP生成 WGCF 配置文件
* 结束后会有结果提示，并自动清理安装时的临时文件

## WARP好处

* 解锁奈飞流媒体
* 避免 Google 验证码或是使用 Google 学术搜索
* 可调用IPv4接口使京* docker 和 V2P 等正常运行
* 由于可以双向转输数据，能做对方VPS的跳板和探针，替代 HE tunnelbroker
* 能让像EUserv这样的 IPv6 only VPS 上做的节点支持Telegram
* IPv6 建的节点能在只支持 IPv4 的 PassWall、ShadowSocksR Plus+ 上使用

![menu.jpg](https://i.loli.net/2021/09/08/kmq816Vpl5Us9ng.jpg)

## 菜单选择（推荐）

```bash
wget -N https://cdn.jsdelivr.net/gh/fscarmen/warp/menu.sh && chmod +x menu.sh && ./menu.sh
```

## 为 KVM IPv4 only 添加 IPv6 网络接口方法

```bash
wget -N "https://raw.githubusercontent.com/fscarmen/warp/main/warp6.sh" && chmod +x warp6.sh && ./warp6.sh
```

## 为 KVM IPv4 only 或原生双栈 添加双栈网络接口方法

```bash
wget -N "https://raw.githubusercontent.com/fscarmen/warp/main/dualstack6.sh" && chmod +x dualstack6.sh && ./dualstack6.sh
```

## 为 KVM IPv6 only 添加 IPv4 网络接口方法

```bash
echo nameserver 2a00:1098:2b::1 > /etc/resolv.conf && wget -N -6 "https://raw.githubusercontent.com/fscarmen/warp/main/warp4.sh" && chmod +x warp4.sh && ./warp4.sh
```

## 为 KVM IPv6 only 添加双栈网络接口方法

```bash
echo nameserver 2a00:1098:2b::1 > /etc/resolv.conf && wget -N -6 "https://raw.githubusercontent.com/fscarmen/warp/main/dualstack46.sh" && chmod +x dualstack46.sh && ./dualstack46.sh
```

## 为 LXC IPv6 only 添加 IPv4 网络接口方法

```bash
echo nameserver 2a00:1098:2b::1 > /etc/resolv.conf && wget -N -6 "https://raw.githubusercontent.com/fscarmen/warp/main/warp.sh" && chmod +x warp.sh && ./warp.sh
```

## 为 LXC IPv6 only 添加双栈网络接口方法

```bash
echo nameserver 2a00:1098:2b::1 > /etc/resolv.conf && wget -N -6 "https://raw.githubusercontent.com/fscarmen/warp/main/dualstack.sh" && chmod +x dualstack.sh && ./dualstack.sh
```

## 临时、永久关闭和开启WGCF网络接口

临时关闭 wgcf（reboot重启后恢复开启） ```wg-quick down wgcf``` ，恢复启动 ```wg-quick up wgcf```

禁止开机启动 ```systemctl disable wg-quick@wgcf```,恢复开机启动 ```systemctl enable wg-quick@wgcf```


## WARP原理

WARP是CloudFlare提供的一项基于WireGuard的网络流量安全及加速服务，能够让你通过连接到CloudFlare的边缘节点实现隐私保护及链路优化。

其连接入口为双栈（IPv4/IPv6均可），且连接后能够获取到由CF提供基于NAT的IPv4和IPv6地址，因此我们的单栈服务器可以尝试连接到WARP来获取额外的网络连通性支持。这样我们就可以让仅具有IPv6的服务器访问IPv4，也能让仅具有IPv4的服务器获得IPv6的访问能力。

* 为仅IPv6服务器添加IPv4

原理如图，IPv4的流量均被WARP网卡接管，实现了让IPv4的流量通过WARP访问外部网络。

![2021-02-04_21-45-45.png](https://i.loli.net/2021/03/20/XesDmluhRBkHSjd.png)

* 为仅IPv4服务器添加IPv6

原理如图，IPv6的流量均被WARP网卡接管，实现了让IPv6的流量通过WARP访问外部网络。

![2021-02-04_21-45-44.png](https://i.loli.net/2021/06/15/ARfOasgp286xjym.png)

* 双栈服务器置换网络

有时我们的服务器本身就是双栈的，但是由于种种原因我们可能并不想使用其中的某一种网络，这时也可以通过WARP接管其中的一部分网络连接隐藏自己的IP地址。至于这样做的目的，最大的意义是减少一些滥用严重机房出现验证码的概率；同时部分内容提供商将WARP的落地IP视为真实用户的原生IP对待，能够解除一些基于IP识别的封锁。

![2021-02-04_21-45-45-1.png](https://i.loli.net/2021/03/20/7vWf15szTONgq69.png)

* 网络性能方面：内核集成＞内核模块＞wireguard-go

Linux 5.6 以上内核则已经集成了 WireGuard ，可以用 ```hostnamectl```或```uname -r```查看版本。

甲骨文是 KVM 完整虚拟化的 VPS 主机，而官方系统由于版本较低，在不更换内核的前提下选择  "内核模块" 方案。

EUserv是 LXC 非完整虚拟化 VPS 主机，共享宿主机内核，不能更换内核，只能选择 "wireguard-go" 方案。
    

## 致谢下列作者和项目（排名不分先后）：  

技术指导:
* P3terx：https://p3terx.com/archives/use-cloudflare-warp-to-add-extra-ipv4-or-ipv6-network-support-to-vps-servers-for-free.html
* Luminous：https://luotianyi.vc/5252.html
* Hiram:https://hiram.wang/cloudflare-wrap-vps

所需文件：
* wgcf：https://github.com/ViRb3/wgcf
* WireGuard-GO 编译自官方：https://git.zx2c4.com/wireguard-go/
* 中科大 elrepo 源：https://www.dazhuanlan.com/2020/04/02/5e8524f06823d/
