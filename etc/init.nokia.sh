#!/system/bin/sh
#
# nitboot
#
# Launcher script to kickstart NIT's required proprietary software.
# Modified for NITdroid
#
# http://guug.org/nit/nitboot/
# Otto Solares Cabrera <solca@guug.org>

#
# nitboot configuration
#

PATH=/system/bin/busybox/bin:/system/bin/busybox/sbin:$PATH
ROOTFS=/nokia
INITFS=/mnt/initfs
TRACE="/strace -ff -F -tt -s 200 -o /tmp/trace"

umask 0002
export PATH


#
# NITdroid specific
#

rm /system/etc/firmware
ln -s /mnt/initfs/lib/firmware /system/etc/firmware

boot_anim=`getprop ro.kernel.android.bootanim`
case "$boot_anim" in
    0)  setprop debug.sf.nobootanimation 1
    ;;
esac

