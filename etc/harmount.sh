#!/system/bin/sh

HARMATTAN_ROOT=/mnt/initfs

mkdir -p ${HARMATTAN_ROOT} 2> /dev/null
mount -t ext4 /dev/block/mmcblk0p2 ${HARMATTAN_ROOT}
mount -t proc proc ${HARMATTAN_ROOT}/proc
mount -t sysfs sysfs ${HARMATTAN_ROOT}/sys

mkdir /dev/shm 2> /dev/null
mount -o bind /dev ${HARMATTAN_ROOT}/dev

mknod -m 644 ${HARMATTAN_ROOT}/dev/mtd1 c 90 2

echo "ondemand" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor

start dsme
start bme

chroot ${HARMATTAN_ROOT} /usr/bin/mxt_configure.sh

SERIALNO=$( chroot ${HARMATTAN_ROOT} /bin/sh -c "sysinfoclient -g /device/production-sn | sed -e 's/.*= //'" )
setprop ro.serialno ${SERIALNO}
