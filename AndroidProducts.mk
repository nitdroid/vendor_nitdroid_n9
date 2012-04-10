#
# Copyright (C) 2009 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

#
# This file should set PRODUCT_MAKEFILES to a list of product makefiles
# to expose to the build system.  LOCAL_DIR will already be set to
# the directory containing this file.
#
# This file may not rely on the value of any variable other than
# LOCAL_DIR; do not use any conditionals, and do not look up the
# value of any variable that isn't set in this file or in a file that
# it includes.
#

# Misc
PRODUCT_COPY_FILES += \
	$(LOCAL_PATH)/busybox/busybox:root/bin/busybox \
	$(LOCAL_PATH)/init.rc:root/init.rc \
	$(LOCAL_PATH)/init.nokiarm-696board.rc:root/init.nokiarm-696board.rc \
	$(LOCAL_PATH)/init.nokiarm-680board.rc:root/init.nokiarm-680board.rc \
	$(LOCAL_PATH)/ueventd.nokiarm-696board.rc:root/ueventd.nokiarm-696board.rc \
	$(LOCAL_PATH)/ueventd.nokiarm-680board.rc:root/ueventd.nokiarm-680board.rc \
	$(LOCAL_PATH)/etc/media_profiles.xml:system/etc/media_profiles.xml \
	$(LOCAL_PATH)/etc/vold.fstab:system/etc/vold.fstab \
	$(LOCAL_PATH)/etc/modem.conf:system/etc/modem.conf \
	$(LOCAL_PATH)/etc/gps.conf:system/etc/gps.conf \
	$(LOCAL_PATH)/etc/harmount.sh:system/etc/harmount.sh \
	$(LOCAL_PATH)/etc/dhcpcd/dhcpcd.conf:system/etc/dhcpcd/dhcpcd.conf \
	$(LOCAL_PATH)/etc/wifi/wpa_supplicant.conf:system/etc/wifi/wpa_supplicant.conf \
	$(LOCAL_PATH)/etc/excluded-input-devices.xml:system/etc/excluded-input-devices.xml \
	$(LOCAL_PATH)/system/xbin/rr:system/xbin/rr
##

# Input device calibration files
PRODUCT_COPY_FILES += \
	$(LOCAL_PATH)/Atmel_mXT_Touchscreen.idc:system/usr/idc/Atmel_mXT_Touchscreen.idc \
	$(LOCAL_PATH)/TWL4030_Keypad.idc:system/usr/idc/TWL4030_Keypad.idc \
	$(LOCAL_PATH)/TWL4030_Keypad.kl:system/usr/keylayout/TWL4030_Keypad.kl \
	$(LOCAL_PATH)/TWL4030_Keypad.kcm:system/usr/keychars/TWL4030_Keypad.kcm

##

# Permissions
PRODUCT_COPY_FILES += \
    frameworks/base/data/etc/handheld_core_hardware.xml:system/etc/permissions/handheld_core_hardware.xml \
    frameworks/base/data/etc/android.hardware.wifi.xml:system/etc/permissions/android.hardware.wifi.xml \
    frameworks/base/data/etc/android.hardware.telephony.gsm.xml:system/etc/permissions/android.hardware.telephony.gsm.xml \
    frameworks/base/data/etc/android.hardware.location.gps.xml:system/etc/permissions/android.hardware.location.gps.xml \
    frameworks/base/data/etc/android.software.sip.voip.xml:system/etc/permissions/android.software.sip.voip.xml \
##

PRODUCT_MAKEFILES := \
    $(LOCAL_DIR)/n9.mk
