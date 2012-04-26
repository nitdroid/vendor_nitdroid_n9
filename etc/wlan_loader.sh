#!/system/bin/sh

HARMATTAN_ROOT=/mnt/initfs

# load wl12xx_spi only for N950
getprop ro.hardware | /bin/busybox grep -q -e "nokiarm-680board" && insmod /system/lib/modules/current/wl12xx_spi.ko

chroot ${HARMATTAN_ROOT} /usr/bin/wl1271-cal

exec setprop wlan.driver.status ok

