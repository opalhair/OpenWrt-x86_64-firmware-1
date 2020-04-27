#!/bin/bash
#=================================================
# Description: DIY script
# Lisence: MIT
# Author: P3TERX
# Blog: https://p3terx.com
#=================================================

# HaProxy
svn co https://github.com/openwrt/packages/branches/openwrt-19.07/net/haproxy
rm -rf feeds/packages/net/haproxy
mv haproxy feeds/packages/net

# SSR-Plus
svn co https://github.com/fw876/helloworld/trunk/luci-app-ssr-plus package/luci-app-ssr-plus

# Passwall
svn co https://github.com/pirately/packages/trunk/Passwall package/passwall

# OpenClash
svn co https://github.com/vernesong/OpenClash/trunk/luci-app-openclash package/luci-app-openclash

# AdguardHome
git clone https://github.com/rufengsuixing/luci-app-adguardhome.git package/luci-app-adguardhome

# SmartDNS
svn co https://github.com/pirately/packages/trunk/SmartDNS package/smartdns

./scripts/feeds update -a && ./scripts/feeds install -a

# Modify default IP
sed -i 's/192.168.1.1/10.0.1.1/g' package/base-files/files/bin/config_generate

# Modify Default Password
sed -i 's/root:$1$V4UetPzk$CYXluq4wUazHjmCDBCqXF.:0:0:99999:7:::/root:$1$UmLoGX73$uH5R9TCJBsV.9s9B2twB91:0:0:99999:7:::/g' package/lean/default-settings/files/zzz-default-settings

sed -i '$i uci set network.lan.ifname="eth1 eth2 eth3"' package/lean/default-settings/files/zzz-default-settings
sed -i '$i uci set network.wan.ifname="eth0"' package/lean/default-settings/files/zzz-default-settings
sed -i '$i uci set network.wan.proto=pppoe' package/lean/default-settings/files/zzz-default-settings
sed -i '$i uci set network.wan6.ifname="eth0"' package/lean/default-settings/files/zzz-default-settings
sed -i '$i uci commit network' package/lean/default-settings/files/zzz-default-settings
