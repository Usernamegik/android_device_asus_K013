LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
LOCAL_MODULE := bluetooth.me176c.rc
LOCAL_VENDOR_MODULE := true
LOCAL_SRC_FILES := $(LOCAL_MODULE)
LOCAL_MODULE_CLASS := ETC
LOCAL_MODULE_RELATIVE_PATH := init
LOCAL_REQUIRED_MODULES := bdaddr
include $(BUILD_PREBUILT)
