# config.mk
#
# Product-specific compile-time definitions.
#

# The generic product target doesn't have any hardware-specific pieces.
TARGET_CPU_ABI := armeabi-v7a
TARGET_CPU_ABI2 := armeabi
TARGET_BOARD_PLATFORM := omap3
TARGET_ARCH_VARIANT	:= armv7-a-neon
ARCH_ARM_HAVE_TLS_REGISTER := true
TARGET_GLOBAL_CFLAGS += -mtune=cortex-a8 -mfpu=neon -mfloat-abi=softfp
TARGET_GLOBAL_CPPFLAGS += -mtune=cortex-a8 -mfpu=neon -mfloat-abi=softfp

TARGET_NO_BOOTLOADER := true
TARGET_NO_KERNEL := true
TARGET_NO_RECOVERY	:= true
TARGET_PROVIDES_INIT_RC := true
TARGET_NO_RADIOIMAGE := true

# Bluetooth
BOARD_HAVE_BLUETOOTH	:= true

# Enable TI/OMX
HARDWARE_OMX := true

USE_CAMERA_STUB		:= true
BOARD_USES_N900_CAMERA_HAL := true
#BOARD_USES_TI_CAMERA_HAL := true

BOARD_USES_GENERIC_AUDIO:= false
HAVE_HTC_AUDIO_DRIVER	:= false
BOARD_USES_ALSA_AUDIO	:= true
BUILD_WITH_ALSA_UTILS	:= true

BUILD_WITH_OFONO	:= true

ifdef HARDWARE_OMX
OMX_VENDOR := ti
OMX_VENDOR_INCLUDES := \
   hardware/ti/omap3/omx/system/src/openmax_il/omx_core/inc \
   hardware/ti/omap3/omx/image/src/openmax_il/jpeg_enc/inc
OMX_VENDOR_WRAPPER := TI_OMX_Wrapper
BUILD_WITHOUT_PV:=true
BUILD_WITH_TI_AUDIO:=1
#ENABLE_RMPM_STUB:=1
DVFS_ENABLED:=1
BUILD_JPEG_DECODER:= true
endif

CUSTOM_MODULES := libglib-2.0 libcmtspeechdata ofonod libofono-ril dbus-send
CUSTOM_MODULES += gps.omap3 lights.omap3 sensors.omap3 hwcomposer.omap3
CUSTOM_MODULES += audio.primary.omap3

CUSTOM_MODULES += libbridge dspexec \
	libOMX_Core libLCML \
	libOMX.TI.AAC.decode libOMX.TI.AAC.encode \
	libOMX.TI.MP3.decode libOMX.TI.WMA.decode \
	libOMX.TI.AMR.decode libOMX.TI.AMR.encode \
	libOMX.TI.WBAMR.decode libOMX.TI.WBAMR.encode \
	libOMX.TI.Video.Decoder libOMX.TI.Video.encoder \
	libOMX.TI.JPEG.Encoder
#

# GPS related defines
BOARD_HAVE_FAKE_GPS := true

# Wifi related defines
WIFI_DRIVER_MODULE_PATH     := "/system/lib/modules/current/wl12xx_sdio.ko"
WIFI_DRIVER_MODULE_ARG      := ""
WIFI_DRIVER_MODULE_NAME     := "wl12xx_sdio"
WIFI_FIRMWARE_LOADER        := "wlan_loader"
BOARD_WPA_SUPPLICANT_DRIVER      := WEXT
BOARD_WLAN_DEVICE                := wl12xx
#BOARD_SOFTAP_DEVICE := wl1271
