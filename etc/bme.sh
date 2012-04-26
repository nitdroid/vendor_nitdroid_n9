#!/system/bin/sh

HARMATTAN_ROOT=/mnt/initfs

# we need to wait a little for fakedsme
sleep 1

exec strace chroot ${HARMATTAN_ROOT} /usr/sbin/bme_RX-71 -u -v 5 -c /usr/lib/hwi/hw/rx71.so
