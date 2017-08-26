PRODUCT_PACKAGES += \
    android.hardware.sensors@1.0-service \
    android.hardware.sensors@1.0-impl \
    sensors.iio \
    SmartCover

PRODUCT_PROPERTY_OVERRIDES += \
    ro.hardware.sensors=iio \
    ro.iio.accel.panel=5 \
    ro.iio.accel.rotation=4 \
    ro.iio.magn.quirks=no-trig
