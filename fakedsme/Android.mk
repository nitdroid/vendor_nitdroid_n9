LOCAL_PATH:= $(call my-dir)

#
# fakedsme
#
include $(CLEAR_VARS)
LOCAL_SRC_FILES:= fakedsme.c
LOCAL_MODULE:= fakedsme
LOCAL_SHARED_LIBRARIES:= libc libcutils
LOCAL_MODULE_TAGS:= optional
include $(BUILD_EXECUTABLE)
