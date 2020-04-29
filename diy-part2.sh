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
mkdir -p package/passwall
svn co https://github.com/pirately/packages/trunk/Passwall/luci-app-passwall package/luci-app-passwall
svn co https://github.com/Lienol/openwrt-package/trunk/package/brook package/passwall/brook
svn co https://github.com/Lienol/openwrt-package/trunk/package/chinadns-ng package/passwall/chinadns-ng
svn co https://github.com/Lienol/openwrt-package/trunk/package/simple-obfs package/passwall/simple-obfs
svn co https://github.com/Lienol/openwrt-package/trunk/package/tcping package/passwall/tcping

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
svn co https://github.com/vernesong/OpenClash/trunk/luci-app-openclash package/luci-app-openclash

# AdguardHome
git clone https://github.com/rufengsuixing/luci-app-adguardhome.git package/luci-app-adguardhome

# SmartDNS
svn co https://github.com/pirately/packages/trunk/SmartDNS package/smartdns

./scripts/feeds update -a && ./scripts/feeds install -a

#替换lean首页文件，添加天气代码(by:冷淡)
#替换首页文件
rm -rf feeds/luci/modules/luci-mod-admin-full/luasrc/view/admin_status/index.htm
cp ../Warehouse/index_Weather/index.htm feeds/luci/modules/luci-mod-admin-full/luasrc/view/admin_status/index.htm
#替换X86首页文件
rm -rf package/lean/autocore/files/index.htm
cp ../Warehouse/index_Weather/x86_index.htm package/lean/autocore/files/index.htm
#添加天气预报翻译
sed -i '$a \       ' feeds/luci/modules/luci-base/po/zh-cn/base.po
sed -i '$a #天气预报' feeds/luci/modules/luci-base/po/zh-cn/base.po
sed -i '$a msgid "Weather"' feeds/luci/modules/luci-base/po/zh-cn/base.po
sed -i '$a msgstr "天气"' feeds/luci/modules/luci-base/po/zh-cn/base.po
sed -i '$a \       ' feeds/luci/modules/luci-base/po/zh-cn/base.po
sed -i '$a msgid "Local Weather"' feeds/luci/modules/luci-base/po/zh-cn/base.po
sed -i '$a msgstr "本地天气"' feeds/luci/modules/luci-base/po/zh-cn/base.po

#增加首页温度显示
temperature_if=$(grep -o "@TARGET_x86" package/lean/autocore/Makefile | wc -l)
if [[ "$temperature_if" == "1" ]]; then
	rm -rf package/lean/autocore/files/autocore
	sed -i "s/@TARGET_x86/@(i386||x86_64||arm||mipsel||mips||aarch64)/g"  package/lean/autocore/Makefile
	cp ../Warehouse/index_temperature/autocore  package/lean/autocore/files/autocore
	cp ../Warehouse/index_temperature/temperature package/lean/autocore/files/sbin/temperature
fi