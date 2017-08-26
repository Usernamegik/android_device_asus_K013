$(call inherit-product, device/asus/me176c/device.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/aosp_base.mk)

PRODUCT_NAME := aosp_me176c

PRODUCT_BRAND := asus
PRODUCT_DEVICE := me176c
TARGET_VENDOR_DEVICE_NAME := K013

PRODUCT_MANUFACTURER := ASUS
PRODUCT_MODEL := ASUS MeMO Pad 7 (ME176C)

PRODUCT_PACKAGES += \
    Launcher3
