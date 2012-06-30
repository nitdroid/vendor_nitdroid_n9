#!/system/bin/sh

HARMATTAN_ROOT=/mnt/initfs

# we need to wait a little for fakedsme
sleep 2

rm ${HARMATTAN_ROOT}/tmp/.bme* 2> /dev/null

exec chroot ${HARMATTAN_ROOT} /usr/sbin/bme_RX-71 -l stdout -v 5 --nodsme -c /usr/lib/hwi/hw/rx71.so
