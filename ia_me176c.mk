$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, device/asus/K013/device.mk)

# Overrides
PRODUCT_NAME := ia_me176c
PRODUCT_DEVICE := K013
PRODUCT_MODEL := ME176C
PRODUCT_BRAND := AndroidIA
PRODUCT_MANUFACTURER := asus
