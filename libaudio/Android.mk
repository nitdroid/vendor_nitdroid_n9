LOCAL_PATH:= $(call my-dir)

ifneq ($(filter n9 ,$(TARGET_DEVICE)),)

#
# aplay, arec, amix
#
include $(CLEAR_VARS)
LOCAL_SRC_FILES:= aplay.c alsa_pcm.c alsa_mixer.c
LOCAL_MODULE:= aplay
LOCAL_SHARED_LIBRARIES:= libc libcutils
LOCAL_MODULE_TAGS:= debug
include $(BUILD_EXECUTABLE)

include $(CLEAR_VARS)
LOCAL_SRC_FILES:= arec.c alsa_pcm.c
LOCAL_MODULE:= arec
LOCAL_SHARED_LIBRARIES:= libc libcutils
LOCAL_MODULE_TAGS:= debug
include $(BUILD_EXECUTABLE)

include $(CLEAR_VARS)
LOCAL_SRC_FILES:= amix.c alsa_mixer.c
LOCAL_MODULE:= amix
LOCAL_SHARED_LIBRARIES := libc libcutils
LOCAL_MODULE_TAGS:= debug
include $(BUILD_EXECUTABLE)

#
# audio.primary.omap3.so
#
include $(CLEAR_VARS)
LOCAL_SRC_FILES:= AudioHardware.cpp alsa_mixer.c alsa_pcm.c
LOCAL_MODULE:= audio.primary.omap3
LOCAL_MODULE_PATH := $(TARGET_OUT_SHARED_LIBRARIES)/hw
LOCAL_MODULE_TAGS := optional
LOCAL_STATIC_LIBRARIES += libmedia_helper
LOCAL_WHOLE_STATIC_LIBRARIES := libaudiohw_legacy
LOCAL_SHARED_LIBRARIES:= libc libcutils libutils libmedia libhardware_legacy

ifeq ($(BOARD_HAVE_BLUETOOTH),true)
#  LOCAL_SHARED_LIBRARIES += audio.a2dp.default
endif

ifeq ($(TARGET_SIMULATOR),true)
 LOCAL_LDLIBS += -ldl
else
 LOCAL_SHARED_LIBRARIES += libdl
endif

include $(BUILD_SHARED_LIBRARY)

#
# audio_policy.omap3.so
#
include $(CLEAR_VARS)
LOCAL_SRC_FILES:= AudioPolicyManager.cpp
LOCAL_MODULE:= audio_policy.omap3
LOCAL_MODULE_PATH := $(TARGET_OUT_SHARED_LIBRARIES)/hw
LOCAL_MODULE_TAGS := optional
LOCAL_STATIC_LIBRARIES:= libaudiopolicy_legacy libmedia_helper
LOCAL_SHARED_LIBRARIES:= libcutils libutils libmedia
ifeq ($(BOARD_HAVE_BLUETOOTH),true)
  LOCAL_CFLAGS += -DWITH_A2DP
endif

# TODO: fix it
#include $(BUILD_SHARED_LIBRARY)

endif
