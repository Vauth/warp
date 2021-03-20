mkdir warp && cd warp
sudo yum -y install wireguard-tools
sudo curl -Lo /etc/yum.repos.d/wireguard.repo https://copr.fedorainfracloud.org/coprs/jdoss/wireguard/repo/epel-7/jdoss-wireguard-epel-7.repo
sudo yum -y install epel-release wireguard-dkms
sudo yum -y update
sudo modprobe wireguard
sudo wget -O wgcf https://github.com/ViRb3/wgcf/releases/download/v2.2.3/wgcf_2.2.3_linux_amd64
sudo chmod +x wgcf
echo | sudo ./wgcf register
sudo ./wgcf generate
sudo sed -i '/0\.\0\/0/d' wgcf-profile.conf | sudo sed -i 's/engage.cloudflareclient.com/162.159.192.1/g' wgcf-profile.conf | sudo sed -i 's/1.1.1.1/9.9.9.10,8.8.8.8,1.1.1.1/g' wgcf-profile.conf
sudo cp wgcf-profile.conf /etc/wireguard/wgcf.conf
sudo systemctl start wg-quick@wgcf
sudo systemctl enable wg-quick@wgcf
echo 'precedence  ::ffff:0:0/96   100' | sudo tee -a /etc/gai.conf
cd .. && rm -rf ./warp warp*
ip a




