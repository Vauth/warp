# 【WGCF】连接CF WARP为服务器添加IPv4/IPv6网络

* * *

# 目录

- [脚本特点](README.md#脚本特点)
- [WARP好处](README.md#WARP好处)
- [运行脚本](README.md#运行脚本)
- [WARP+ License 及 ID 获取](README.md#warp-license-及-id-获取)
- [WARP 网络接口数据，临时、永久关闭和开启](README.md#warp-网络接口数据临时永久关闭和开启)
- [WARP原理](README.md#WARP原理)
- [致谢](README.md#致谢下列作者和项目排名不分先后)

* * *

## 脚本特点

* 支持 Warp+ 账户，附带第三方刷 Warp+ 流量和升级内核 BBR 脚本
* 普通用户友好的菜单，进阶者通过后缀选项快速搭建
* 智能判断vps操作系统：Ubuntu 18.04、Ubuntu 20.04、Debian 10、Debian 11、CentOS 7、CentOS 8，请务必选择 LTS 系统；智能判断硬件结构类型：AMD 或者 ARM
* 结合 Linux 版本和虚拟化方式，自动优选三个 WireGuard 方案。网络性能方面：内核集成 WireGuard＞安装内核模块＞wireguard-go
* 智能判断 WGCF 作者 github库的最新版本 （Latest release）
* 智能分析内网和公网IP生成 WGCF 配置文件
* 输出结果，提示是否使用 WARP IP ，IP 归属地

## WARP好处

* 解锁奈飞流媒体
* 避免 Google 验证码或是使用 Google 学术搜索
* 可调用 IPv4 接口，使青龙和V2P等项目能正常运行
* 由于可以双向转输数据，能做对方VPS的跳板和探针，替代 HE tunnelbroker
* 能让 IPv6 only VPS 上做的节点支持 Telegram
* IPv6 建的节点能在只支持 IPv4 的 PassWall、ShadowSocksR Plus+ 上使用

<img src="https://user-images.githubusercontent.com/62703343/135889918-d224d2e3-c79f-47be-8bc7-fe4d48f26c56.png" width="80%" />

## 运行脚本

首次运行
```bash
wget -N https://cdn.jsdelivr.net/gh/fscarmen/warp/menu.sh && bash menu.sh [option] [lisence]
```
再次运行
```bash
warp [option] [lisence]
```
  | [option] 变量 | 具体动作说明 |
  | ------------- | ----------- |
  | 1 | 原生IPv4 -> （原生IPv4 + Warp IPv6) 或者 原生IPv6 -> (Warp IPv4 + 原生IPv6) |
  | 1 lisence | 在上面基础上把 Warp+ Lisence 添加进去，如 ```bash menu.sh 1 N5670ljg-sS9jD334-6o6g4M9F``` |
  | 2 | 原无论任何状态 -> Warp 双栈 |
  | 2 lisence | 在上面基础上把 Warp+ Lisence 添加进去，如 ```bash menu.sh 2 N5670ljg-sS9jD334-6o6g4M9F```  |
  | o | Warp 开关，脚本主动判断当前状态，自动开或关 |
  | u | 卸载 Warp |
  | n | 断网时，用于刷Warp网络 (Warp bug) |
  | b | 升级内核、开启BBR及DD |
  | p | 刷 Warp+ 流量 |
  | 其他或空值| 菜单界面 |

举例：想为 IPv4 的甲骨文添加 Warp 双栈，首次运行
```bash
wget -N https://cdn.jsdelivr.net/gh/fscarmen/warp/menu.sh && bash menu.sh 2
```
或者再次运行
```bash
warp 2
```
## WARP+ License 及 ID 获取

<img src="https://user-images.githubusercontent.com/62703343/136070323-47f2600a-13e4-4eb0-a64d-d7eb805c28e2.png" width="70%" />

## WARP 网络接口数据，临时、永久关闭和开启

WireGuard 网络接口数据，查看 ```wg```

临时关闭和开启 WARP（reboot重启后恢复开启） ```bash menu.sh o```
官方原始指令 ```wg-quick down wgcf``` ，恢复启动 ```wg-quick up wgcf```

禁止开机启动 ```systemctl disable wg-quick@wgcf```,恢复开机启动 ```systemctl enable wg-quick@wgcf```


## WARP原理

WARP是CloudFlare提供的一项基于WireGuard的网络流量安全及加速服务，能够让你通过连接到CloudFlare的边缘节点实现隐私保护及链路优化。

其连接入口为双栈（IPv4/IPv6均可），且连接后能够获取到由CF提供基于NAT的IPv4和IPv6地址，因此我们的单栈服务器可以尝试连接到WARP来获取额外的网络连通性支持。这样我们就可以让仅具有IPv6的服务器访问IPv4，也能让仅具有IPv4的服务器获得IPv6的访问能力。

* 为仅IPv6服务器添加IPv4

原理如图，IPv4的流量均被WARP网卡接管，实现了让IPv4的流量通过WARP访问外部网络。
<img src="https://user-images.githubusercontent.com/62703343/135735404-1389d022-e5c5-4eb8-9655-f9f065e3c92e.png" width="70%" />

* 为仅IPv4服务器添加IPv6

原理如图，IPv6的流量均被WARP网卡接管，实现了让IPv6的流量通过WARP访问外部网络。
<img src="https://user-images.githubusercontent.com/62703343/135735414-01321b0b-887e-43d6-ad68-a74db20cfe84.png" width="70%" />

* 双栈服务器置换网络

有时我们的服务器本身就是双栈的，但是由于种种原因我们可能并不想使用其中的某一种网络，这时也可以通过WARP接管其中的一部分网络连接隐藏自己的IP地址。至于这样做的目的，最大的意义是减少一些滥用严重机房出现验证码的概率；同时部分内容提供商将WARP的落地IP视为真实用户的原生IP对待，能够解除一些基于IP识别的封锁。
<img src="https://user-images.githubusercontent.com/62703343/135735419-50805ed6-20ea-4440-93b4-5bcc6f2aca9b.png" width="70%" />

* 网络性能方面：内核集成＞内核模块＞wireguard-go

Linux 5.6 及以上内核则已经集成了 WireGuard ，可以用 ```hostnamectl```或```uname -r```查看版本。

甲骨文是 KVM 完整虚拟化的 VPS 主机，而官方系统由于版本较低，在不更换内核的前提下选择  "内核模块" 方案。如已升级内核在5.6及以上，将会自动选择 “内核集成” 方案。

EUserv是 LXC 非完整虚拟化 VPS 主机，共享宿主机内核，不能更换内核，只能选择 "wireguard-go" 方案。
    

## 致谢下列作者和项目（排名不分先后）：  

技术指导:
* P3terx：https://p3terx.com/archives/use-cloudflare-warp-to-add-extra-ipv4-or-ipv6-network-support-to-vps-servers-for-free.html
* Luminous：https://luotianyi.vc/5252.html
* Hiram：https://hiram.wang/cloudflare-wrap-vps

服务提供：
* CloudFlare Warp(+)：https://1.1.1.1/
* WGCF 项目原作者：https://github.com/ViRb3/wgcf/
* WireGuard-GO 官方：https://git.zx2c4.com/wireguard-go/
* ylx2016 的成熟作品：https://github.com/ylx2016/Linux-NetSpeed
* ALIILAPRO 的成熟作品：https://github.com/ALIILAPRO/warp-plus-cloudflare
* mixool 的成熟作品：https://github.com/mixool/across/tree/master/wireguard
* 获取公网 IP 及归属地查询：https://ip.gs/
