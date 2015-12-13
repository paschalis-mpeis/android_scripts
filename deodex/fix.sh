#!/bin/sh

# Creates some symlinks to fix some problems that appear after deodexing
# This is because the libraries are extracted from the APK's in the original odexed /system

function symlink {
  adb shell rm -f $1
  adb shell ln -s $2 $1
}

# delete oat folders and contents
adb shell "find /system/priv-app/ -type d -name "oat" -exec rm -rf {} \;"
adb shell "find /system/app/ -type d -name "oat" -exec rm -rf {} \;"

symlink "/system/lib/libbluetooth_jni.so" "/system/app/Bluetooth/lib/arm/libbluetooth_jni.so"
symlink "/system/lib/libchrome.2125.509.so" "/system/app/Chrome/lib/arm/libchrome.2125.509.so"
symlink "/system/lib/libdefcontainer_jni.so" "/system/priv-app/DefaultContainerService/lib/arm/libdefcontainer_jni.so"
symlink "/system/lib/lib_dic_en_tablet_USUK.conf.so" "/system/app/iWnnIME/lib/arm/lib_dic_en_tablet_USUK.conf.so"
symlink "/system/lib/lib_dic_en_USUK.conf.so" "/system/app/iWnnIME/lib/arm/lib_dic_en_USUK.conf.so"
symlink "/system/lib/lib_dic_ja_JP.conf.so" "/system/app/iWnnIME/lib/arm/lib_dic_ja_JP.conf.so"
symlink "/system/lib/lib_dic_morphem_ja_JP.conf.so" "/system/app/iWnnIME/lib/arm/lib_dic_morphem_ja_JP.conf.so"
symlink "/system/lib/libEnjemailuri.so" "/system/app/iWnnIME/lib/arm/libEnjemailuri.so"
symlink "/system/lib/libennjcon.so" "/system/app/iWnnIME/lib/arm/libennjcon.so"
symlink "/system/lib/libennjubase1gb.so" "/system/app/iWnnIME/lib/arm/libennjubase1gb.so"
symlink "/system/lib/libennjubase1.so" "/system/app/iWnnIME/lib/arm/libennjubase1.so"
symlink "/system/lib/libennjubase1us.so" "/system/app/iWnnIME/lib/arm/libennjubase1us.so"
symlink "/system/lib/libennjubase2.so" "/system/app/iWnnIME/lib/arm/libennjubase2.so"
symlink "/system/lib/libennjubase3.so" "/system/app/iWnnIME/lib/arm/libennjubase3.so"
symlink "/system/lib/libennjyomi.so" "/system/app/iWnnIME/lib/arm/libennjyomi.so"
symlink "/system/lib/libfacelock_jni.so" "/system/app/FaceLock/lib/arm/libfacelock_jni.so"
symlink "/system/lib/libgoogle_hotword_jni.so" "/system/priv-app/Velvet/lib/arm/libgoogle_hotword_jni.so"
symlink "/system/lib/libgoogle_recognizer_jni_l.so" "/system/priv-app/Velvet/lib/arm/libgoogle_recognizer_jni_l.so"
symlink "/system/lib/libiwnn.so" "/system/app/iWnnIME/lib/arm/libiwnn.so"
symlink "/system/lib/libjni_latinimegoogle.so" "/system/app/LatinImeGoogle/lib/arm/libjni_latinimegoogle.so"
symlink "/system/lib/libjni_pacprocessor.so" "/system/app/PacProcessor/lib/arm/libjni_pacprocessor.so"
symlink "/system/lib/libnfc_nci_jni.so" "/system/app/NfcNci/lib/arm/libnfc_nci_jni.so"
symlink "/system/lib/libnjaddress.so" "/system/app/iWnnIME/lib/arm/libnjaddress.so"
symlink "/system/lib/libnjcon.so" "/system/app/iWnnIME/lib/arm/libnjcon.so"
symlink "/system/lib/libnjemoji.so" "/system/app/iWnnIME/lib/arm/libnjemoji.so"
symlink "/system/lib/libnjexyomi_plus.so" "/system/app/iWnnIME/lib/arm/libnjexyomi_plus.so"
symlink "/system/lib/libnjexyomi.so" "/system/app/iWnnIME/lib/arm/libnjexyomi.so"
symlink "/system/lib/libnjfzk.so" "/system/app/iWnnIME/lib/arm/libnjfzk.so"
symlink "/system/lib/libnjkaomoji.so" "/system/app/iWnnIME/lib/arm/libnjkaomoji.so"
symlink "/system/lib/libnjname.so" "/system/app/iWnnIME/lib/arm/libnjname.so"
symlink "/system/lib/libnjtan.so" "/system/app/iWnnIME/lib/arm/libnjtan.so"
symlink "/system/lib/libnjubase1.so" "/system/app/iWnnIME/lib/arm/libnjubase1.so"
symlink "/system/lib/libnjubase2.so" "/system/app/iWnnIME/lib/arm/libnjubase2.so"
symlink "/system/lib/libprintspooler_jni.so" "/system/app/PrintSpooler/lib/arm/libprintspooler_jni.so"
symlink "/system/lib/libvariablespeed.so" "/system/priv-app/GoogleDialer/lib/arm/libvariablespeed.so"
symlink "/system/lib/libvcdecoder_jni.so" "/system/priv-app/Velvet/lib/arm/libvcdecoder_jni.so"
symlink "/system/lib/libvorbisencoder.so" "/system/app/GoogleEars/lib/arm/libvorbisencoder.so"
symlink "/system/lib/libwebviewchromium.so" "/system/app/WebViewGoogle/lib/arm/libwebviewchromium.so"

# updater-script-20_PERMISSIONS
# I guess this fix the permission problems that show on logcat messages. These were extracted from TWRP GApps fixes
# set_metadata_recursive("/system", "uid", 0, "gid", 0, "dmode", 0755, "fmode", 0644, "capabilities", 0x0, "selabel", "u:object_r:system_file:s0");
# set_metadata_recursive("/system/bin", "uid", 0, "gid", 2000, "dmode", 0755, "fmode", 0755, "capabilities", 0x0, "selabel", "u:object_r:system_file:s0");
# set_metadata("/system/bin/ATFWD-daemon", "uid", 0, "gid", 2000, "mode", 0755, "capabilities", 0x0, "selabel", "u:object_r:atfwd_exec:s0");
# set_metadata("/system/bin/app_process", "uid", 0, "gid", 2000, "mode", 0755, "capabilities", 0x0, "selabel", "u:object_r:zygote_exec:s0");
# set_metadata("/system/bin/bootanimation", "uid", 0, "gid", 2000, "mode", 0755, "capabilities", 0x0, "selabel", "u:object_r:bootanim_exec:s0");
# set_metadata("/system/bin/bugreport", "uid", 0, "gid", 2000, "mode", 0755, "capabilities", 0x0, "selabel", "u:object_r:bugreport_exec:s0");
# set_metadata("/system/bin/clatd", "uid", 0, "gid", 2000, "mode", 0755, "capabilities", 0x0, "selabel", "u:object_r:clatd_exec:s0");
# set_metadata("/system/bin/debuggerd", "uid", 0, "gid", 2000, "mode", 0755, "capabilities", 0x0, "selabel", "u:object_r:debuggerd_exec:s0");
# set_metadata("/system/bin/dhcpcd", "uid", 0, "gid", 2000, "mode", 0755, "capabilities", 0x0, "selabel", "u:object_r:dhcp_exec:s0");
# set_metadata("/system/bin/dnsmasq", "uid", 0, "gid", 2000, "mode", 0755, "capabilities", 0x0, "selabel", "u:object_r:dnsmasq_exec:s0");
# set_metadata("/system/bin/drmserver", "uid", 0, "gid", 2000, "mode", 0755, "capabilities", 0x0, "selabel", "u:object_r:drmserver_exec:s0");
# set_metadata("/system/bin/dumpstate", "uid", 0, "gid", 2000, "mode", 0755, "capabilities", 0x0, "selabel", "u:object_r:dumpstate_exec:s0");
# set_metadata("/system/bin/dumpsys", "uid", 0, "gid", 2000, "mode", 0755, "capabilities", 0x0, "selabel", "u:object_r:dumpsys_exec:s0");
# set_metadata("/system/bin/efsks", "uid", 0, "gid", 2000, "mode", 0755, "capabilities", 0x0, "selabel", "u:object_r:efsks_exec:s0");
# set_metadata("/system/bin/hostapd", "uid", 0, "gid", 2000, "mode", 0755, "capabilities", 0x0, "selabel", "u:object_r:hostapd_exec:s0");
# set_metadata("/system/bin/installd", "uid", 0, "gid", 2000, "mode", 0755, "capabilities", 0x0, "selabel", "u:object_r:installd_exec:s0");
# set_metadata("/system/bin/iptables", "uid", 0, "gid", 1000, "mode", 0750, "capabilities", 0x0, "selabel", "u:object_r:system_file:s0");
# set_metadata("/system/bin/keystore", "uid", 0, "gid", 2000, "mode", 0755, "capabilities", 0x0, "selabel", "u:object_r:keystore_exec:s0");
# set_metadata("/system/bin/ks", "uid", 0, "gid", 2000, "mode", 0755, "capabilities", 0x0, "selabel", "u:object_r:ks_exec:s0");
# set_metadata("/system/bin/logwrapper", "uid", 0, "gid", 2000, "mode", 0755, "capabilities", 0x0, "selabel", "u:object_r:logwrapper_exec:s0");
# set_metadata("/system/bin/mdnsd", "uid", 0, "gid", 2000, "mode", 0755, "capabilities", 0x0, "selabel", "u:object_r:mdnsd_exec:s0");
# set_metadata("/system/bin/mediaserver", "uid", 0, "gid", 2000, "mode", 0755, "capabilities", 0x0, "selabel", "u:object_r:mediaserver_exec:s0");
# set_metadata("/system/bin/mm-qcamera-daemon", "uid", 0, "gid", 2000, "mode", 0755, "capabilities", 0x0, "selabel", "u:object_r:mm-qcamera-daemon_exec:s0");
# set_metadata("/system/bin/mpdecision", "uid", 0, "gid", 2000, "mode", 0755, "capabilities", 0x0, "selabel", "u:object_r:mpdecision_exec:s0");
# set_metadata("/system/bin/mtpd", "uid", 0, "gid", 2000, "mode", 0755, "capabilities", 0x0, "selabel", "u:object_r:mtp_exec:s0");
# set_metadata("/system/bin/netcfg", "uid", 0, "gid", 3003, "mode", 02750, "capabilities", 0x0, "selabel", "u:object_r:system_file:s0");
# set_metadata("/system/bin/netd", "uid", 0, "gid", 2000, "mode", 0755, "capabilities", 0x0, "selabel", "u:object_r:netd_exec:s0");
# set_metadata("/system/bin/ping", "uid", 0, "gid", 0, "mode", 0755, "capabilities", 0x0, "selabel", "u:object_r:ping_exec:s0");
# set_metadata("/system/bin/pppd", "uid", 0, "gid", 2000, "mode", 0755, "capabilities", 0x0, "selabel", "u:object_r:ppp_exec:s0");
# set_metadata("/system/bin/qcks", "uid", 0, "gid", 2000, "mode", 0755, "capabilities", 0x0, "selabel", "u:object_r:qcks_exec:s0");
# set_metadata("/system/bin/qmuxd", "uid", 0, "gid", 2000, "mode", 0755, "capabilities", 0x0, "selabel", "u:object_r:qmuxd_exec:s0");
# set_metadata("/system/bin/qseecomd", "uid", 0, "gid", 2000, "mode", 0755, "capabilities", 0x0, "selabel", "u:object_r:qseecomd_exec:s0");
# set_metadata("/system/bin/racoon", "uid", 0, "gid", 2000, "mode", 0755, "capabilities", 0x0, "selabel", "u:object_r:racoon_exec:s0");
# set_metadata("/system/bin/rild", "uid", 0, "gid", 2000, "mode", 0755, "capabilities", 0x0, "selabel", "u:object_r:rild_exec:s0");
# set_metadata("/system/bin/rmt_storage", "uid", 0, "gid", 2000, "mode", 0755, "capabilities", 0x0, "selabel", "u:object_r:rmt_storage_exec:s0");
# set_metadata("/system/bin/run-as", "uid", 0, "gid", 2000, "mode", 0750, "capabilities", 0x0, "selabel", "u:object_r:runas_exec:s0");
# set_metadata("/system/bin/sdcard", "uid", 0, "gid", 2000, "mode", 0755, "capabilities", 0x0, "selabel", "u:object_r:sdcardd_exec:s0");
# set_metadata("/system/bin/servicemanager", "uid", 0, "gid", 2000, "mode", 0755, "capabilities", 0x0, "selabel", "u:object_r:servicemanager_exec:s0");
# set_metadata("/system/bin/surfaceflinger", "uid", 0, "gid", 2000, "mode", 0755, "capabilities", 0x0, "selabel", "u:object_r:surfaceflinger_exec:s0");
# set_metadata("/system/bin/tc", "uid", 0, "gid", 1000, "mode", 0750, "capabilities", 0x0, "selabel", "u:object_r:system_file:s0");
# set_metadata("/system/bin/thermald", "uid", 0, "gid", 2000, "mode", 0755, "capabilities", 0x0, "selabel", "u:object_r:thermald_exec:s0");
# set_metadata("/system/bin/vold", "uid", 0, "gid", 2000, "mode", 0755, "capabilities", 0x0, "selabel", "u:object_r:vold_exec:s0");
# set_metadata("/system/bin/wpa_supplicant", "uid", 0, "gid", 2000, "mode", 0755, "capabilities", 0x0, "selabel", "u:object_r:wpa_exec:s0");
# set_metadata_recursive("/system/etc/bluetooth", "uid", 1002, "gid", 1002, "dmode", 0755, "fmode", 0440, "capabilities", 0x0, "selabel", "u:object_r:system_file:s0");
# set_metadata("/system/etc/bluetooth/auto_pair_devlist.conf", "uid", 0, "gid", 0, "mode", 0644, "capabilities", 0x0, "selabel", "u:object_r:system_file:s0");
# set_metadata("/system/etc/bluetooth/bt_did.conf", "uid", 0, "gid", 0, "mode", 0644, "capabilities", 0x0, "selabel", "u:object_r:system_file:s0");
# set_metadata("/system/etc/bluetooth/bt_stack.conf", "uid", 0, "gid", 0, "mode", 0644, "capabilities", 0x0, "selabel", "u:object_r:system_file:s0");
# set_metadata_recursive("/system/etc/dhcpcd", "uid", 0, "gid", 0, "dmode", 0755, "fmode", 0644, "capabilities", 0x0, "selabel", "u:object_r:dhcp_system_file:s0");
# set_metadata("/system/etc/dhcpcd/dhcpcd-run-hooks", "uid", 1014, "gid", 2000, "mode", 0550, "capabilities", 0x0, "selabel", "u:object_r:dhcp_system_file:s0");
# set_metadata_recursive("/system/etc/ppp", "uid", 0, "gid", 0, "dmode", 0755, "fmode", 0555, "capabilities", 0x0, "selabel", "u:object_r:ppp_system_file:s0");
# set_metadata_recursive("/system/lib", "uid", 0, "gid", 0, "dmode", 0755, "fmode", 0644, "capabilities", 0x0, "selabel", "u:object_r:system_library_file:s0");
# set_metadata_recursive("/system/vendor", "uid", 0, "gid", 2000, "dmode", 0755, "fmode", 0644, "capabilities", 0x0, "selabel", "u:object_r:system_file:s0");
# set_metadata("/system/vendor/etc", "uid", 0, "gid", 2000, "mode", 0755, "capabilities", 0x0, "selabel", "u:object_r:system_file:s0");
# set_metadata("/system/vendor/firmware", "uid", 0, "gid", 2000, "mode", 0755, "capabilities", 0x0, "selabel", "u:object_r:system_file:s0");
# set_metadata("/system/vendor/lib", "uid", 0, "gid", 2000, "mode", 0755, "capabilities", 0x0, "selabel", "u:object_r:system_file:s0");
# set_metadata_recursive("/system/vendor/lib/drm", "uid", 0, "gid", 2000, "dmode", 0755, "fmode", 0644, "capabilities", 0x0, "selabel", "u:object_r:system_file:s0");
# set_metadata("/system/vendor/lib/drm/libdrmwvmplugin.so", "uid", 0, "gid", 0, "mode", 0644, "capabilities", 0x0, "selabel", "u:object_r:system_file:s0");
# set_metadata("/system/vendor/lib/egl", "uid", 0, "gid", 2000, "mode", 0755, "capabilities", 0x0, "selabel", "u:object_r:system_file:s0");
# set_metadata_recursive("/system/vendor/lib/mediadrm", "uid", 0, "gid", 2000, "dmode", 0755, "fmode", 0644, "capabilities", 0x0, "selabel", "u:object_r:system_file:s0");
# set_metadata("/system/vendor/lib/mediadrm/libwvdrmengine.so", "uid", 0, "gid", 0, "mode", 0644, "capabilities", 0x0, "selabel", "u:object_r:system_file:s0");
# set_metadata("/system/vendor/media", "uid", 0, "gid", 2000, "mode", 0755, "capabilities", 0x0, "selabel", "u:object_r:system_file:s0");
# set_metadata("/system/vendor/pittpatt", "uid", 0, "gid", 2000, "mode", 0755, "capabilities", 0x0, "selabel", "u:object_r:system_file:s0");
# set_metadata("/system/vendor/pittpatt/models", "uid", 0, "gid", 2000, "mode", 0755, "capabilities", 0x0, "selabel", "u:object_r:system_file:s0");
# set_metadata("/system/vendor/pittpatt/models/detection", "uid", 0, "gid", 2000, "mode", 0755, "capabilities", 0x0, "selabel", "u:object_r:system_file:s0");
# set_metadata_recursive("/system/vendor/pittpatt/models/recognition", "uid", 0, "gid", 2000, "dmode", 0755, "fmode", 0644, "capabilities", 0x0, "selabel", "u:object_r:system_file:s0");
# set_metadata_recursive("/system/xbin", "uid", 0, "gid", 2000, "dmode", 0755, "fmode", 0755, "capabilities", 0x0, "selabel", "u:object_r:system_file:s0");

