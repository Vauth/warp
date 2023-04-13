mac 的 WARP 一键脚本，使用 WireGuard 隧道， WARP 服务
电信 100兆家庭宽带下的效果:

<img width="795" alt="image" src="https://user-images.githubusercontent.com/62703343/164397693-549b3810-78a9-473d-9c1d-e88cc9a45991.png">

<img width="974" alt="image" src="https://user-images.githubusercontent.com/62703343/164398430-6303837e-1c27-4814-8a4b-5ec347b5af8a.png">


中文安装
```
sudo curl -o /usr/local/bin/mac.sh https://raw.githubusercontent.com/fscarmen/warp/main/pc/mac.sh && bash mac.sh c
```

英文安装
```
sudo curl -o /usr/local/bin/mac.sh https://raw.githubusercontent.com/fscarmen/warp/main/pc/mac.sh && bash mac.sh e
```

卸载
```
warp u
```
 
  | [option] | 具体动作说明 |
  | ----------------- | --------------- |
  | c | 指定中文安装 |
  | e | 指定英文安装 |
  | o | WARP 开关，脚本主动判断当前状态，自动开或关 |
  | u | 卸载 WARP |
  | n | 断网时，用于刷WARP网络 |
  | a | 免费 WARP 账户升级 WARP+ 或 Teams |
  | v | 同步脚本至最新版本 |
  | h 或空值| 帮助 |
