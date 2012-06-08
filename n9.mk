# This is a generic product that isn't specialized for a specific device.
# It includes the base Android platform. If you need Google-specific features,
# you should derive from generic_with_google.mk

#$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base.mk)

# This is the list of apps included in the generic AOSP build
PRODUCT_PACKAGES := \
    Camera \
    Development \
    SpareParts \
    SoundRecorder \
    VoiceDialer

# Live Wallpapers
PRODUCT_PACKAGES += \
    LiveWallpapers \
    LiveWallpapersPicker \
    VisualizationWallpapers \
    librs_jni
##

# Inherit from those products. Most specific first.
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base.mk)

DEVICE_PACKAGE_OVERLAYS := vendor/nitdroid/n9/overlay

# Overrides
PRODUCT_BRAND := nokia
PRODUCT_DEVICE := n9
PRODUCT_NAME := n9
PRODUCT_MODEL := Nokia N9

# This is a high DPI device, so add the hdpi pseudo-locale
PRODUCT_LOCALES += en_US hdpi
