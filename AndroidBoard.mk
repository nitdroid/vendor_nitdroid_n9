LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

# This device is xhdpi.  However the platform doesn't
# currently contain all of the bitmaps at xhdpi density so
# we do this little trick to fall back to the hdpi version
# if the xhdpi doesn't exist.
#PRODUCT_AAPT_CONFIG := normal hdpi
#PRODUCT_AAPT_PREF_CONFIG := hdpi

# Misc
PRODUCT_COPY_FILES += \
	$(LOCAL_PATH)/busybox/busybox:root/bin/busybox \
	$(LOCAL_PATH)/init.rc:root/init.rc \
	$(LOCAL_PATH)/init.nokiarm-696board.rc:root/init.nokiarm-696board.rc \
	$(LOCAL_PATH)/ueventd.nokiarm-696board.rc:root/ueventd.nokiarm-696board.rc \
	$(LOCAL_PATH)/etc/media_profiles.xml:system/etc/media_profiles.xml \
	$(LOCAL_PATH)/etc/vold.fstab:system/etc/vold.fstab \
	$(LOCAL_PATH)/etc/modem.conf:system/etc/modem.conf \
	$(LOCAL_PATH)/etc/gps.conf:system/etc/gps.conf \
	$(LOCAL_PATH)/etc/harmount.sh:system/etc/harmount.sh \
	$(LOCAL_PATH)/etc/dhcpcd/dhcpcd.conf:system/etc/dhcpcd/dhcpcd.conf \
	$(LOCAL_PATH)/etc/wifi/wpa_supplicant.conf:system/etc/wifi/wpa_supplicant.conf \
	$(LOCAL_PATH)/system/xbin/rr:system/xbin/rr
##

# Input device calibration files
PRODUCT_COPY_FILES += \
	$(LOCAL_PATH)/Atmel_mXT_Touchscreen.idc:system/usr/idc/Atmel_mXT_Touchscreen.idc
##

# Permissions
PRODUCT_COPY_FILES += \
    frameworks/base/data/etc/handheld_core_hardware.xml:system/etc/permissions/handheld_core_hardware.xml \
    frameworks/base/data/etc/android.hardware.wifi.xml:system/etc/permissions/android.hardware.wifi.xml \
    frameworks/base/data/etc/android.hardware.telephony.gsm.xml:system/etc/permissions/android.hardware.telephony.gsm.xml \
    frameworks/base/data/etc/android.hardware.location.gps.xml:system/etc/permissions/android.hardware.location.gps.xml \
    frameworks/base/data/etc/android.software.sip.voip.xml:system/etc/permissions/android.software.sip.voip.xml \
##
