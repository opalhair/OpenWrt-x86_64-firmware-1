#!/bin/bash
#=================================================

# SSR-Plus
svn co https://github.com/fw876/helloworld/trunk/luci-app-ssr-plus package/luci-app-ssr-plus

# Passwall
svn co https://github.com/pirately/packages/trunk/Passwall/luci-app-passwall package/luci-app-passwall
svn co https://github.com/Lienol/openwrt-package/trunk/package/tcping package/tcping
git clone https://github.com/pexcn/openwrt-chinadns-ng.git package/chinadns-ng

#更改Passwall国内的dns
passwall_dns=$(grep -o "option up_china_dns 'default'" package/luci-app-passwall/root/etc/config/passwall | wc -l)
if [[ "$passwall_dns" == "1" ]]; then
	sed -i "s/option up_china_dns 'default'/option up_china_dns '223.5.5.5'/g" package/luci-app-passwall/root/etc/config/passwall
fi

#更改Passwall的dns模式
dns_mode=$(grep -o "option dns_mode 'pdnsd'" package/luci-app-passwall/root/etc/config/passwall | wc -l)
if [[ "$dns_mode" == "1" ]]; then
	sed -i "s/option dns_mode 'pdnsd'/option dns_mode 'chinadns-ng'/g" package/luci-app-passwall/root/etc/config/passwall
fi

#更改Passwall显示位置
passwall_display=$(grep -o "vpn" package/luci-app-passwall/luasrc/controller/passwall.lua | wc -l)
if [[ "$passwall_display" == "1" ]]; then
	sed -i "s/vpn/services/g" package/luci-app-passwall/luasrc/controller/passwall.lua
	sed -i "s/VPN/Services/g" package/luci-app-passwall/luasrc/controller/passwall.lua
	sed -i "s/vpn/services/g" package/luci-app-passwall/luasrc/model/cbi/passwall/node_config.lua
	sed -i "s/vpn/services/g" package/luci-app-passwall/luasrc/model/cbi/passwall/node_list.lua
	sed -i "s/vpn/services/g" package/luci-app-passwall/luasrc/model/cbi/passwall/node_subscribe.lua
	sed -i "s/vpn/services/g" package/luci-app-passwall/luasrc/view/passwall/haproxy/status.htm
	sed -i "s/vpn/services/g" package/luci-app-passwall/luasrc/view/passwall/log/log.htm
	sed -i "s/vpn/services/g" package/luci-app-passwall/luasrc/view/passwall/global/tips.htm
	sed -i "s/vpn/services/g" package/luci-app-passwall/luasrc/view/passwall/global/status.htm
	sed -i "s/vpn/services/g" package/luci-app-passwall/luasrc/view/passwall/global/status2.htm
	sed -i "s/vpn/services/g" package/luci-app-passwall/luasrc/view/passwall/node_list/node_list.htm
	sed -i "s/vpn/services/g" package/luci-app-passwall/luasrc/view/passwall/node_list/link_add_node.htm
	sed -i "s/vpn/services/g" package/luci-app-passwall/luasrc/view/passwall/rule/rule_version.htm
	sed -i "s/vpn/services/g" package/luci-app-passwall/luasrc/view/passwall/rule/brook_version.htm
	sed -i "s/vpn/services/g" package/luci-app-passwall/luasrc/view/passwall/rule/v2ray_version.htm
	sed -i "s/vpn/services/g" package/luci-app-passwall/luasrc/view/passwall/rule/kcptun_version.htm
	sed -i "s/vpn/services/g" package/luci-app-passwall/luasrc/view/passwall/rule/passwall_version.htm
fi

# OpenClash
svn co https://github.com/vernesong/OpenClash/trunk/luci-app-openclash

# AdguardHome
git clone https://github.com/rufengsuixing/luci-app-adguardhome.git

# SmartDNS
git clone https://github.com/pymumu/luci-app-smartdns -b lede

# Themes
rm -rf package/lean/luci-theme-argon
git clone https://github.com/jerrykuku/luci-theme-argon -b 19.07_stable package/lean/luci-theme-argon
svn co https://github.com/solidus1983/luci-theme-opentomato/branches/dev-v19.07/luci/themes/luci-theme-opentomato package/luci-theme-opentomato

echo 'Modify TimeZone'
sed -i "s/'UTC'/'CST-8'\nset system.@system[-1].zonename='Asia\/Shanghai'/g" package/base-files/files/bin/config_generate

echo 'Modify banner'
cp -f ../diy/banner package/base-files/files/etc/
date=`date +%m.%d.%Y`
sed -i "s/Jeffen$/Jeffen $date/g" package/base-files/files/etc/banner

#活动连接数
sed -i 's/16384/65536/g' package/kernel/linux/files/sysctl-nf-conntrack.conf

#enable KERNEL_MIPS_FPU_EMULATOR
sed -i 's/default y if TARGET_pistachio/default y/g' config/Config-kernel.in

#应用fullconenat
rm -rf package/lean/openwrt-fullconenat
svn co https://github.com/Lienol/openwrt/branches/dev-master/package/fullconenat package/fullconenat
rm -rf package/network/config/firewall
svn co https://github.com/Lienol/openwrt/branches/dev-master/package/network/config/firewall package/network/config/firewall
sed -i "s/option syn_flood	0/option syn_flood	1/g" package/network/config/firewall/files/firewall.config
sed -i "s/option fullcone		0/option fullcone		1/g" package/network/config/firewall/files/firewall.config
sed -i "s/option bbr '0'/option bbr '1'/g" package/lean/luci-app-flowoffload/root/etc/config/flowoffload

echo '定义默认值'
cat > package/default-settings/files/zzz-default-settings <<-EOF
#!/bin/sh
# set language
uci set luci.main.lang=zh_cn
uci set luci.main.mediaurlbase=/luci-static/bootstrap
uci commit luci

# set time zone
uci set system.@system[0].timezone=CST-8
uci set system.@system[0].zonename=Asia/Shanghai
uci commit system

# set distfeeds
sed -i 's#http://downloads.openwrt.org#http://mirrors.tuna.tsinghua.edu.cn/openwrt#g' /etc/opkg/distfeeds.conf

# set menu
sed -i 's/\"services\"/\"vpn\"/g' /usr/lib/lua/luci/controller/shadowsocksr.lua
sed -i 's/services/vpn/g' /usr/lib/lua/luci/view/shadowsocksr/checkport.htm
sed -i 's/services/vpn/g' /usr/lib/lua/luci/view/shadowsocksr/refresh.htm
sed -i 's/services/vpn/g' /usr/lib/lua/luci/view/shadowsocksr/server_list.htm
sed -i 's/services/vpn/g' /usr/lib/lua/luci/view/shadowsocksr/status.htm
sed -i 's/services/vpn/g' /usr/lib/lua/luci/view/shadowsocksr/subscribe.htm
sed -i 's/services/vpn/g' /usr/lib/lua/luci/view/shadowsocksr/check.htm
sed -i 's/services/vpn/g' /usr/lib/lua/luci/model/cbi/shadowsocksr/server.lua
sed -i 's/services/vpn/g' /usr/lib/lua/luci/model/cbi/shadowsocksr/servers.lua
sed -i 's/services/vpn/g' /usr/lib/lua/luci/model/cbi/shadowsocksr/client-config.lua
sed -i 's/services/vpn/g' /usr/lib/lua/luci/model/cbi/shadowsocksr/server-config.lua
sed -i 's/\"services\"/\"vpn\"/g' /usr/lib/lua/luci/controller/openclash.lua
sed -i 's/services/vpn/g' /usr/lib/lua/luci/view/openclash/download_game_rule.htm
sed -i 's/services/vpn/g' /usr/lib/lua/luci/view/openclash/server_list.htm
sed -i 's/services/vpn/g' /usr/lib/lua/luci/view/openclash/update.htm
sed -i 's/services/vpn/g' /usr/lib/lua/luci/view/openclash/status.htm
sed -i 's/services/vpn/g' /usr/lib/lua/luci/view/openclash/state.htm
sed -i 's/services/vpn/g' /usr/lib/lua/luci/model/cbi/openclash/client.lua
sed -i 's/services/vpn/g' /usr/lib/lua/luci/model/cbi/openclash/config.lua
sed -i 's/services/vpn/g' /usr/lib/lua/luci/model/cbi/openclash/config-subscribe.lua
sed -i 's/services/vpn/g' /usr/lib/lua/luci/model/cbi/openclash/game-rules-manage.lua
sed -i 's/services/vpn/g' /usr/lib/lua/luci/model/cbi/openclash/game-settings.lua
sed -i 's/services/vpn/g' /usr/lib/lua/luci/model/cbi/openclash/groups-config.lua
sed -i 's/services/vpn/g' /usr/lib/lua/luci/model/cbi/openclash/log.lua
sed -i 's/services/vpn/g' /usr/lib/lua/luci/model/cbi/openclash/proxy-provider-config.lua
sed -i 's/services/vpn/g' /usr/lib/lua/luci/model/cbi/openclash/servers.lua
sed -i 's/services/vpn/g' /usr/lib/lua/luci/model/cbi/openclash/servers-config.lua
sed -i 's/services/vpn/g' /usr/lib/lua/luci/model/cbi/openclash/settings.lua

# set network
sed -i 's/root:.*/root:$1$UmLoGX73$uH5R9TCJBsV.9s9B2twB91:0:0:99999:7:::/g' /etc/shadow
uci set network.lan.ipaddr="10.0.1.1"
uci set network.lan.ifname="eth1 eth2 eth3"
uci set network.wan.ifname="eth0"
uci set network.wan.proto=pppoe
uci set network.wan6.ifname="eth0"
uci commit network

# set firewall
sed -i '/REDIRECT --to-ports 53/d' /etc/firewall.user
echo "iptables -t nat -A PREROUTING -p udp --dport 53 -j REDIRECT --to-ports 53" >> /etc/firewall.user
echo "iptables -t nat -A PREROUTING -p tcp --dport 53 -j REDIRECT --to-ports 53" >> /etc/firewall.user

# set DIY
# sed -i '/DISTRIB_REVISION/d' /etc/openwrt_release
# echo "DISTRIB_REVISION='SNAPSHOT'" >> /etc/openwrt_release
sed -i '/DISTRIB_DESCRIPTION/d' /etc/openwrt_release
echo "DISTRIB_DESCRIPTION='%D %V %C by Jeffen '" >> /etc/openwrt_release

# clear tmp
rm -rf /tmp/luci*
exit 0
EOF

echo '当前路径'
pwd
