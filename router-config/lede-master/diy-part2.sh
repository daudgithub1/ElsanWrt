#!/bin/bash
#========================================================================================================================
# https://github.com/ophub/amlogic-s9xxx-openwrt
# Description: Automatically Build OpenWrt for Amlogic S9xxx STB
# Function: Diy script (After Update feeds, Modify the default IP, hostname, theme, add/remove software packages, etc.)
# Source code repository: https://github.com/coolsnowwolf/lede / Branch: master
#========================================================================================================================

# ------------------------------- Main source started -------------------------------
#
# Modify default theme（FROM uci-theme-bootstrap CHANGE TO luci-theme-netgear）
sed -i 's/luci-theme-bootstrap/luci-theme-material/g' ./feeds/luci/collections/luci/Makefile

# autocore support for armvirt
sed -i 's/TARGET_rockchip/TARGET_rockchip\|\|TARGET_armvirt/g' package/lean/autocore/Makefile

# Set etc/openwrt_release
sed -i "s|DISTRIB_REVISION='.*'|DISTRIB_REVISION='R$(date +%Y.%m.%d)'|g" package/lean/default-settings/files/zzz-default-settings
echo "DISTRIB_SOURCECODE='lede'" >>package/base-files/files/etc/openwrt_release

# Modify default IP（FROM 192.168.1.1 CHANGE TO 192.168.31.4）
# sed -i 's/192.168.1.1/192.168.31.4/g' package/base-files/files/bin/config_generate

# Modify default root's password（FROM 'password'[$1$V4UetPzk$CYXluq4wUazHjmCDBCqXF.] CHANGE TO 'your password'）
sed -i 's/root::0:0:99999:7:::/root:$1$7359e37c2d3cdcbdf87b78a84cd8a747:0:0:99999:7:::/g' package/base-files/files/etc/shadow

# language
sed -i "s/zh_cn/en/g" feeds/luci/modules/luci-base/root/etc/uci-defaults/luci-base
sed -i "s/zh_cn/en/g" package/lean/default-settings/files/zzz-default-settings
# time-zone
sed -i "s/CST-8/WIB-7/g" package/lean/default-settings/files/zzz-default-settings
sed -i "s/Shanghai/Jakarta/g" package/lean/default-settings/files/zzz-default-settings
# user firwall
sed -i -e "40s/echo '/echo '# /g" -e "41s/echo '/echo '# /g" -e "42s/echo '/echo '# /g" -e "43s/echo '/echo '# /g" package/lean/default-settings/files/zzz-default-settings
# rc local
sed -i "3s|^|\n# Mount Filesystem NTFS\n# sleep 1\n# ntfs-3g /dev/sda1 /mnt/hdd -o rw,lazytime,noatime,big_writes\n|" package/base-files/files/etc/rc.local
# hsotname
sed -i "s/OpenWrt/ELSAN/g" package/base-files/files/bin/config_generate
# default shell to zsh
sed -i "s/\/bin\/ash/\/usr\/bin\/zsh/g" package/base-files/files/etc/passwd
# docker startup
# sed -i "s/99/25/g" feeds/packages/utils/dockerd/files/dockerd.init
# sed -i "s/99/25/g" package/lean/luci-app-dockerman/root/etc/init.d/dockerman
# wrtbwmon translate to english
# sed -i -e "s/客户端/Host/g" -e "s/下载带宽/DL Speed/g" -e "s/上传带宽/UL Speed/g" -e "s/总下载流量/Download/g" -e "s/总上传流量/Upload/g" -e "s/流量合计/Total/g" -e "s/首次上线时间/First Seen/g" -e "s/最后上线时间/Last Seen/g" -e "s/总计/TOTAL/g" -e "s/数据更新时间/Last updated/g" -e "s/倒数/Updating again in/g" -e "s/秒后刷新./seconds./g" package/lean/luci-app-wrtbwmon/htdocs/luci-static/wrtbwmon/wrtbwmon.js
# sed -i "s/Bandwidth Monitor/Bandwidth/g" feeds/luci/applications/luci-app-nlbwmon/luasrc/controller/nlbw.lua
# wireless
# sed -i -e "s/channel="'$'"{channel}/channel=11/g" -e "s/htmode="'$'"htmode/htmode=HT40/g" -e "s/country=US/country=ID/g" -e "s/ssid=OpenWrt/ssid=LYNX/g" package/kernel/mac80211/files/lib/wifi/mac80211.sh
# Replace the default software source
# sed -i 's#openwrt.proxy.ustclug.org#mirrors.bfsu.edu.cn\\/openwrt#' package/lean/default-settings/files/zzz-default-settings
#
# ------------------------------- Main source ends -------------------------------

# ------------------------------- Other started -------------------------------
#
# luci-app-amlogic
svn co https://github.com/ophub/luci-app-amlogic/trunk/luci-app-amlogic package/luci-app-amlogic

# p7zip
svn co https://github.com/hubutui/p7zip-lede/trunk package/p7zip

# luci-app-passwall
# svn co https://github.com/xiaorouji/openwrt-passwall/trunk package/openwrt-passwall

# luci-app-openclash
svn co https://github.com/vernesong/OpenClash/trunk/luci-app-openclash package/openwrt-openclash
pushd package/openwrt-openclash/tools/po2lmo && make && sudo make install 2>/dev/null && popd

#add luci-theme-netgear
rm -rf package/lean/luci-theme-netgear/
git clone https://github.com/i028/luci-theme-netgear feeds/luci/themes/luci-theme-netgear

# luci-theme-argon
git clone https://github.com/jerrykuku/luci-app-argon-config package/luci-app-argon-config
rm -rf package/lean/luci-theme-argon/
git clone -b 18.06 https://github.com/jerrykuku/luci-theme-argon package/luci-theme-argon

# luci-app-adguardhome
# svn co https://github.com/rufengsuixing/luci-app-adguardhome/trunk package/lean/luci-app-adguardhome

# luci-app-3ginfo
# svn co https://github.com/4IceG/luci-app-3ginfo/trunk package/luci-app-3ginfo

# luci-app-filebrowser
git clone https://github.com/xiaozhuai/luci-app-filebrowser package/luci-app-filebrowser
make package/luci-app-filebrowser/compile

# luci-app-dockerman
# rm -rf ./package/lean/luci-app-docker
# rm -rf ./package/lean/luci-lib-docker
# svn co https://github.com/lisaac/luci-app-dockerman/trunk/applications/luci-app-dockerman package/luci-app-dockerman
# svn co https://github.com/lisaac/luci-lib-docker/trunk/collections/luci-lib-docker package/luci-lib-docker
# if [ -e feeds/packages/utils/docker-ce ];then
# sed -i '/dockerd/d' package/luci-app-dockerman/Makefile
# sed -i 's/+docker/+docker-ce/g' package/luci-app-dockerman/Makefile
# fi

# oh-my-zsh
mkdir -p files/root
pushd files/root
git clone https://github.com/robbyrussell/oh-my-zsh ./.oh-my-zsh
git clone https://github.com/zsh-users/zsh-autosuggestions ./.oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ./.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-completions ./.oh-my-zsh/custom/plugins/zsh-completions
cp $GITHUB_WORKSPACE/amlogic-s9xxx/common-files/patches/zsh/.zshrc .
cp $GITHUB_WORKSPACE/amlogic-s9xxx/common-files/patches/zsh/example.zsh ./.oh-my-zsh/custom/example.zsh
popd

# coolsnowwolf default software package replaced with Lienol related software package
# rm -rf feeds/packages/utils/{containerd,libnetwork,runc,tini}
# svn co https://github.com/Lienol/openwrt-packages/trunk/utils/{containerd,libnetwork,runc,tini} feeds/packages/utils

# Add third-party software packages (The entire repository)
# git clone https://github.com/libremesh/lime-packages.git package/lime-packages
# Add third-party software packages (Specify the package)
# svn co https://github.com/libremesh/lime-packages/trunk/packages/{shared-state-pirania,pirania-app,pirania} package/lime-packages/packages
# Add to compile options (Add related dependencies according to the requirements of the third-party software package Makefile)
# sed -i "/DEFAULT_PACKAGES/ s/$/ pirania-app pirania ip6tables-mod-nat ipset shared-state-pirania uhttpd-mod-lua/" target/linux/armvirt/Makefile

# Apply patch
# git apply ../router-config/patches/{0001*,0002*}.patch --directory=feeds/luci

# fix runc
sed -i -e "s/1.0.3/1.0.2/g" -e "s/0eaf2f6606d72f166a5e7138a8a8d4d8f85d84e43448c08c66a1c93ead17a574/6c3cca4bbeb5d9b2f5e3c0c401c9d27bc8a5d2a0db8a2f6a06efd03ad3c38a33/g" -e "s/f46b6ba2c9314cfc8caae24a32ec5fe9ef1059fe/52b36a2dd837e8462de8e01458bf02cf9eea47dd/g" feeds/packages/utils/runc/Makefile
# ------------------------------- Other ends -------------------------------
