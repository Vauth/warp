# 【WGCF】连接CF WARP为服务器添加IPv4/IPv6网络

* * *
## 更新信息：
2021.12.24  2.24: 1.IMPORTANT: First publication on a global scale. Support architecture s390x for IBM Linux One(Choose WARP ipv6 single stack); 2.The default language will set to the one selected during installation; 3.Support HAX LXC VPS. It needs run ```until curl -s4m8 ip.gs; do bash warp n; done``` to brush the warp network; 1. 全网首发，支持 IBM Linux One 的 s390x 架构 CPU (请选用 WARP ipv6单栈) 2.默认语言设置为安装时候选择的; 3.支持 HAX LXC VPSlxc 机器母鸡资源不够，warp 需要不停的刷才能获取到 ```until curl -s4m8 ip.gs; do bash warp n; done```

2021.12.17  2.23: Support change the Netflix IP not only WGCF but also Socks5 Client. Both will keep the Plus status. Recommand runs under [screen]; 2.Support update to TEAM account online. [URL for you](https://gist.githubusercontent.com/fscarmen/56aaf02d743551737c9973b8be7a3496/raw/16cf34edf5fb28be00f53bb1c510e95a35491032/com.cloudflare.onedotonedotonedotone_preferences.xml) 1.支持 WARP Interface 和 Socks5 Client 自动更换支持奈飞的IP，两者都会保留 Plus 的状态，建议在 screen 下在后台运行,如果是中文，需要 screen -U 解决乱码问题; 2.支持在线升级为 TEAM 账户。 [这此获取 URL](https://gist.githubusercontent.com/fscarmen/56aaf02d743551737c9973b8be7a3496/raw/16cf34edf5fb28be00f53bb1c510e95a35491032/com.cloudflare.onedotonedotonedotone_preferences.xml)

2021.12.14  2.22: 1.First in the whole network. Use WARP Team account instead of Plus. No need to brush Plus traffic any more. 50 user limited. return to version 2.21; 1.全网首创，使用脚本提供 TEAM 账户替代 Plus，免刷流量。翻车了，官方说了免费team有50个账户的限制，我心存侥幸，想着1个账户多人用，现在看来是行不通了，暂先回退到2.21版本

2021.12.11  2.21: 1.BoringTUN removed because of unstable; 2.Change the DNS to Google first. 3.Count the number of runs1.BoringTUN 因不稳定而移除 2.域名解析服务器首先谷歌 3.统计运行次数

2021.12.04  2.20: IMPORTANT: First publication on a global scale. Reduce installation time by more than 50% through multi-threading. No need to wait for WGCF registering and MTU value searching time; 2.Recode EN/CH traslation through associative array. Smarter and more efficient. Thx Oreo. 重大更新：1.全网首创，通过多线程，安装 WARP 时间缩短一半以上，不用长时间等待 WGCF 注册和寻找 MTU 值时间了; 2.中英双语部分关联数组重构了，更聪明高效，感谢猫大

<details>
    <summary>历史更新 history（点击即可展开或收起）</summary>
<br>

>
>2021.11.30  2.11: 感谢luoxue-bot原创，唤醒大神告知。 1.Changing Netflix IP is adapted from other authors [luoxue-bot]; 1.更换支持 Netflix IP 改编自 [luoxue-bot] 的成熟作品
>
>2021.11.11  2.10: 1.Customize the priority of IPv4 / IPv6; 2.Customize the port of Client Socks5(default is 40000); 1.自定义 IPv4 / IPv6 优先组别; 2.自定义 Client Socks5 代理端>>口，默认40000
>
>2021.11.06  2.09: 1.WARP Linux Client supported.Socks5 proxy listening on: 127.0.0.1:40000. Register and connnect need non-WARP IPv4 interface. Native IPv4 + WARP IPv6 is ok; >2.WARP+ license on Client supported; 3.Customize the WARP+ device name. 1.支持 WARP Linux Client，Socks5 代理监听:127.0.0.1:40000,注册和连接需要非 WARP 的原生 IPv4，可以是：原生>IPv4+ WARP IPv6; 2.Client 支持 WARP+ 账户升级和安装; 3.自定义 WARP+ 设备名
>
>2021.11.01  2.08: 1.Serching the best MTU value for WARP interface automatically; 2.asn organisation for the VPS; 1.自动设置最优 MTU; 2.显示asn组织(线路提供商)
>
>2021.10.29  2.07: 1.Support Chinese and English; 2.Optimize running speed; 3)fix startup at reboot bug;  1.支持中英文，用户可自行选择; 2.大幅优化速度; 3)修复重启后启动WARP的bug
>
>2021.10.23  2.06: 1.添加自动检查是否开启 Tun 模块； 2.提高脚本适配性; 3.新增 hax、Amazon Linux 2 和 Oracle Linux 支持
>
>2021.10.15  2.05: 1.WGCF自动同步最新的2.2.9； 2.升级了重启后运行 Warp 的处理方法，不再依赖另外的文件; 3.修复 KVM 由免费账户升级为 Warp+ 账户的bug
>
>2021.10.14  2.04: 1.LXC 用户自主选择 BoringTun 还是 Wireguard-go (BoringTun用Rust语言，性能接近内核模块性能 ，稳定性与VPS有关；WireGuard-GO用Go语言，性能比前者差点，稳定性高); 2.增加限>制：原生双栈VPS只能用Warp双栈，bash menu.sh 1 会建议改为Warp双栈或退出; 3.Warp断网后，运行warp会自动关闭通道和杀掉进程; 4.脚本中止后，用 echo $? 显示 1,即代表不成功 (原来为代表运行成功的0)
>
>2021.10.12  2.03: 1.对刷网络作了优化，加快了两次尝试之间的间隔时间，不会出现死循环，因为已经限制次数为10次，有明确的提示 2.用Rust语言的 BoringTun 替代Go语言的 WireGuard-GO
>
>2021.10.10  2.02: 上游 ip.gs 用 wget 不稳定导致获取不了 IP 而一直在死刷，弃坑用 curl 替换，脚本检查到没有的话自动安装
</details>

# 目录

- [脚本特点](README.md#脚本特点)
- [WARP好处](README.md#WARP好处)
- [运行脚本](README.md#运行脚本)
- [WARP+ License 及 ID 获取](README.md#warp-license-及-id-获取)
- [WARP Teams 信息用于 Linux 的方法](README.md#WARP-Teams-信息用于-Linux-的方法)
- [WARP 网络接口数据，临时、永久关闭和开启](README.md#warp-网络接口数据临时永久关闭和开启)
- [WARP原理](README.md#WARP原理)
- [鸣谢](README.md#鸣谢下列作者的文章和项目)

* * *

## 脚本特点

* 支持 Warp+ 账户，附带第三方刷 Warp+ 流量和升级内核 BBR 脚本
* 普通用户友好的菜单，进阶者通过后缀选项快速搭建
* 智能判断vps操作系统：Ubuntu 18.04、Ubuntu 20.04、Debian 10、Debian 11、CentOS 7、CentOS 8，请务必选择 LTS 系统；  
  智能判断硬件结构类型：AMD 或者 ARM
* 结合 Linux 版本和虚拟化方式，自动优选三个 WireGuard 方案。  
  网络性能方面：内核集成 WireGuard＞安装内核模块＞BoringTun＞wireguard-go
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

<img src="https://user-images.githubusercontent.com/62703343/144635014-4c027645-0e09-4b84-8b78-88b41f950627.png" width="80%" />

## 运行脚本

首次运行
```bash
wget -N https://cdn.jsdelivr.net/gh/fscarmen/warp/menu.sh && bash menu.sh [option] [lisence]
```
再次运行
```bash
warp [option] [lisence]
```
  | [option] 变量1 变量2 | 具体动作说明 |
  | ----------------- | --------------- |
  | h | 帮助 |
  | 1 | 原生IPv4 -> （原生IPv4 + WARP IPv6) 或者 原生IPv6 -> (WARP IPv4 + 原生IPv6) |
  | 1 lisence name | 把 WARP+ Lisence 和设备名添加进去，如 ```bash menu.sh 1 N5670ljg-sS9jD334-6o6g4M9F Goodluck``` |
  | 2 | 原无论任何状态 -> WARP 双栈 |
  | 2 lisence name | 把 WARP+ Lisence 和设备名添加进去，如 ```bash menu.sh 2 N5670ljg-sS9jD334-6o6g4M9F Goodluck```  |
  | o | WARP 开关，脚本主动判断当前状态，自动开或关 |
  | u | 卸载 Warp |
  | n | 断网时，用于刷WARP网络 (WARP bug) |
  | b | 升级内核、开启BBR及DD |
  | d | 免费 WARP 账户升级 WARP+ |
  | d lisence | 在上面基础上把 WARP+ Lisence 添加进去，如 ```bash menu.sh d N5670ljg-sS9jD334-6o6g4M9F```  |
  | p | 刷 Warp+ 流量 |
  | c | 安装 WARP Linux Client，开启 Socks5 代理模式 |
  | c lisence | 在上面基础上把 WARP+ Lisence 添加进去，如 ```bash menu.sh c N5670ljg-sS9jD334-6o6g4M9F```  |
  | r | WARP Linux Client 开关 |
  | v | 同步脚本至最新版本 |
  | i | 更换 WARP IP |
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

以下是使用WARP和Team后 Argo 2.0 的官方介绍:[Argo 2.0: Smart Routing Learns New Tricks](https://blog.cloudflare.com/argo-v2/)

引用Luminous大神原话：实际测试WARP+在访问非CF的网站速度上和免费版没有差异，只有在访问CloudFlare的站点时付费版会通过Argo类似的技术通过与目标较近的数据中心前往源站，而免费版是仅限于连接地前往源站，仅此而已。

<img src="https://user-images.githubusercontent.com/62703343/136070323-47f2600a-13e4-4eb0-a64d-d7eb805c28e2.png" width="70%" />

## WARP 网络接口数据，临时、永久关闭和开启

WireGuard 网络接口数据，查看 ```wg```

临时关闭和开启 WARP（reboot重启后恢复开启） ```warp o```
官方原始指令 ```wg-quick down wgcf``` ，恢复启动 ```wg-quick up wgcf```

禁止开机启动 ```systemctl disable --now wg-quick@wgcf```,恢复开机启动 ```systemctl enable --now wg-quick@wgcf```


## WARP Teams 信息用于 Linux 的方法

感谢 TonyLCH 提供的资讯 [#26](https://github.com/fscarmen/warp/issues/26) ，由于Team是无限制的，省去了刷 WARP+ 流量。方法大体：
1.安装通安卓模拟器，并在上面安装 1.1.1.1 apk连上
2.连上 teams 后抓包，把获取到的信息替换到wgcf.conf配置文件里

具体原创文章:[Cloudflare for Teams Wireguard Config](https://parkercs.tech/cloudflare-for-teams-wireguard-config/)

感谢 asterriya 提供的资讯 [#42](https://github.com/fscarmen/warp/issues/42) 轻松获取 Team 账户，~~~而不需要用传统方法:注册Cloudflare--申请team--填邮箱--填验证码~~~
具体操作视频:[How to Use unlimited WARP+ for free with Cloudflare Teams](https://www.youtube.com/watch?v=5cuz3SJSj4s)

Download 下载:    
1. Android Studio: [MAC](https://redirector.gvt1.com/edgedl/android/studio/install/2020.3.1.26/android-studio-2020.3.1.26-mac.dmg)     [WIN](https://redirector.gvt1.com/edgedl/android/studio/install/2020.3.1.26/android-studio-2020.3.1.26-windows.exe)    
2. Android platform-tools: [MAC](https://dl.google.com/android/repository/platform-tools-latest-darwin.zip)     [WIN](https://dl.google.com/android/repository/platform-tools-latest-windows.zip)    
3. 1.1.1.1: Faster & Safer Internet: [Android](https://d-03.winudf.com/b/APK/Y29tLmNsb3VkZmxhcmUub25lZG90b25lZG90b25lZG90b25lXzIxNThfNWJkNDQwZjY?_fn=MSAxIDEgMSBGYXN0ZXIgU2FmZXIgSW50ZXJuZXRfdjYuMTBfYXBrcHVyZS5jb20uYXBr&_p=Y29tLmNsb3VkZmxhcmUub25lZG90b25lZG90b25lZG90b25l&am=Cu4e_5crBHRTOxscnCuK9g&at=1640012866&k=33522f995f6facc602071a659868d26161c1edc3)

感谢 Misaka 落地图文说明:https://blog.misaka.rest/202112/291.html    
视频:https://www.bilibili.com/video/BV1gU4y1K7of/

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
    

## 鸣谢下列作者的文章和项目

互联网永远不会忘记，但人们会。

技术文章或相关项目（排名不分先后）:
* P3terx: https://p3terx.com/archives/use-cloudflare-warp-to-add-extra-ipv4-or-ipv6-network-support-to-vps-servers-for-free.html
* P3terx: https://github.com/P3TERX/warp.sh/blob/main/warp.sh
* 猫大: https://github.com/Oreomeow
* Luminous: https://luotianyi.vc/5252.html
* Hiram: https://hiram.wang/cloudflare-wrap-vps
* Cloudflare: https://developers.cloudflare.com/warp-client/setting-up/linux  
https://blog.cloudflare.com/announcing-warp-for-linux-and-proxy-mode/
https://blog.cloudflare.com/argo-v2/
* WireGuard: https://lists.zx2c4.com/pipermail/wireguard/2017-December/002201.html
* Parker C. Stephens: https://parkercs.tech/cloudflare-for-teams-wireguard-config/

服务提供（排名不分先后）：
* CloudFlare Warp(+): https://1.1.1.1/
* WGCF 项目原作者: https://github.com/ViRb3/wgcf/
* WireGuard-GO 官方: https://git.zx2c4.com/wireguard-go/
* ylx2016 的成熟作品: https://github.com/ylx2016/Linux-NetSpeed
* ALIILAPRO 的成熟作品: https://github.com/ALIILAPRO/warp-plus-cloudflare
* mixool 的成熟作品: https://github.com/mixool/across/tree/master/wireguard
* luoxue-bot 的成熟作品:https://github.com/luoxue-bot/warp_auto_change_ip
* 获取公网 IP 及归属地查询: https://ip.gs/
* 统计PV网:https://hits.seeyoufarm.com/
