KERNEL_CROSS_COMPILE_WRAPPER := x86_64-linux-android-
TARGET_PRELINK_MODULE := false

BOARD_KERNEL_CMDLINE += androidboot.hardware=me176c androidboot.serialno=01234567890123456789 console=tty0 console=ttyS2,115200n8

BOARD_KERNEL_IMAGE_NAME := bzImage
ENABLE_CPUSETS := true