#!/system/bin/sh

HARMATTAN_ROOT=/mnt/initfs

mkdir -p ${HARMATTAN_ROOT} 2> /dev/null
mount -t ext4 /dev/block/mmcblk0p2 ${HARMATTAN_ROOT}
mount -t proc proc ${HARMATTAN_ROOT}/proc
mount -t sysfs sysfs ${HARMATTAN_ROOT}/sys

mkdir /dev/shm 2> /dev/null
mount -o bind /dev ${HARMATTAN_ROOT}/dev
#mount -t tmpfs tmpfs -orw,nosuid,nodev,noatime,size=65536k ${HARMATTAN_ROOT}/dev/shm

mknod -m 644 ${HARMATTAN_ROOT}/dev/mtd1 c 90 2

#rm /mnt/initfs/tmp/dsmesock ; rm /mnt/initfs/dev/shm/iphb
#chroot ${HARMATTAN_ROOT} /www 2>/dev/null 1>/dev/null &

echo "ondemand" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor

start dsme
sleep 1

strace chroot ${HARMATTAN_ROOT} /usr/sbin/bme_RX-71 -u -v 5 -c /usr/lib/hwi/hw/rx71.so

#LD_LIBRARY_PATH=/lib:/usr/lib PATH=/bin:/sbin:/usr/bin:/usr/sbin chroot ${HARMATTAN_ROOT} /sbin/dsme -p /lib/dsme/libstartup.so -d
