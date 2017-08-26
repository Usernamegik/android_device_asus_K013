ifneq ($(filter me176c K013, $(TARGET_DEVICE)),)

# Copyright (C) 2012 The CyanogenMod Project
#           (C) 2017 The LineageOS Project
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

## Externally influenced variables
# kernel location - optional, defaults to kernel/<vendor>/<device>
KERNEL_SRC := $(TARGET_KERNEL_SOURCE)
# kernel configuration - mandatory
KERNEL_DEFCONFIG := $(TARGET_KERNEL_CONFIG)

## Internal variables
KERNEL_OUT := $(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ
KERNEL_OUT := $(abspath $(KERNEL_OUT))
KERNEL_CONFIG := $(KERNEL_OUT)/.config
KERNEL_OUT_STAMP := $(KERNEL_OUT)/.mkdir_stamp
KERNEL_ARCH := $(TARGET_KERNEL_ARCH)

ifeq ($(KERNEL_ARCH),x86_64)
KERNEL_DEFCONFIG_ARCH := x86
else
KERNEL_DEFCONFIG_ARCH := $(KERNEL_ARCH)
endif
KERNEL_DEFCONFIG_SRC := $(KERNEL_SRC)/arch/$(KERNEL_DEFCONFIG_ARCH)/configs/$(KERNEL_DEFCONFIG)

TARGET_PREBUILT_INT_KERNEL := $(KERNEL_OUT)/arch/$(KERNEL_ARCH)/boot/$(BOARD_KERNEL_IMAGE_NAME)
KERNEL_BIN := $(TARGET_PREBUILT_INT_KERNEL)

# Clear this first to prevent accidental poisoning from env
MAKE_FLAGS :=

KERNEL_HEADERS_INSTALL := $(KERNEL_OUT)/usr
KERNEL_HEADERS_INSTALL_STAMP := $(KERNEL_OUT)/.headers_install_stamp

KERNEL_MODULES_OUT := $(TARGET_OUT_VENDOR)/lib/modules
KERNEL_MODULES_OUT := $(abspath $(KERNEL_MODULES_OUT))

KERNEL_TOOLCHAIN_PREFIX := $(TARGET_KERNEL_CROSS_COMPILE_PREFIX)
KERNEL_TOOLCHAIN_PATH := $(KERNEL_TOOLCHAIN_PREFIX)

ifneq ($(USE_CCACHE),)
    # Detect if the system already has ccache installed to use instead of the prebuilt
    ccache := $(shell which ccache)

    ifeq ($(ccache),)
        ccache := $(ANDROID_BUILD_TOP)/prebuilts/misc/$(HOST_PREBUILT_TAG)/ccache/ccache
        # Check that the executable is here.
        ccache := $(strip $(wildcard $(ccache)))
    endif
endif

KERNEL_CROSS_COMPILE := CROSS_COMPILE="$(ccache) $(KERNEL_TOOLCHAIN_PATH)"
ccache =

TARGET_KERNEL_MODULES := no-external-modules

$(KERNEL_OUT_STAMP):
	$(hide) mkdir -p $(KERNEL_OUT)
	$(hide) rm -rf $(KERNEL_MODULES_OUT)
	$(hide) mkdir -p $(KERNEL_MODULES_OUT)
	$(hide) touch $@

$(KERNEL_CONFIG): $(KERNEL_OUT_STAMP) $(KERNEL_DEFCONFIG_SRC)
	@echo "Building Kernel Config"
	rm -f KERNEL_CONFIG
	$(MAKE) $(MAKE_FLAGS) -C $(KERNEL_SRC) O=$(KERNEL_OUT) ARCH=$(KERNEL_ARCH) $(KERNEL_CROSS_COMPILE) $(KERNEL_DEFCONFIG)


KERNEL_MODULES_OBJ := $(TARGET_OUT_INTERMEDIATES)/KERNEL_MODULES
KERNEL_MODULES_OBJ := $(abspath $(KERNEL_MODULES_OBJ))

TARGET_KERNEL_BINARIES: $(KERNEL_OUT_STAMP) $(KERNEL_CONFIG) $(KERNEL_HEADERS_INSTALL_STAMP)
	@echo "Building Kernel"
	$(MAKE) $(MAKE_FLAGS) -C $(KERNEL_SRC) O=$(KERNEL_OUT) ARCH=$(KERNEL_ARCH) $(KERNEL_CROSS_COMPILE) $(TARGET_PREBUILT_INT_KERNEL_TYPE)

BUILD_KERNEL_MODULES: TARGET_KERNEL_BINARIES
	@echo "Building Kernel Modules"
	$(MAKE) $(MAKE_FLAGS) -C $(KERNEL_SRC) O=$(KERNEL_OUT) ARCH=$(KERNEL_ARCH) $(KERNEL_CROSS_COMPILE) modules
	$(MAKE) $(MAKE_FLAGS) -C $(KERNEL_SRC) O=$(KERNEL_OUT) INSTALL_MOD_PATH=$(KERNEL_MODULES_OBJ) ARCH=$(KERNEL_ARCH) $(KERNEL_CROSS_COMPILE) modules_install

	find $(KERNEL_MODULES_OBJ) -type f -name '*.ko' -exec $(KERNEL_TOOLCHAIN_PATH)strip --strip-unneeded {} ';'
	$(MAKE) $(MAKE_FLAGS) -C $(KERNEL_SRC) O=$(KERNEL_OUT) INSTALL_MOD_PATH=$(KERNEL_MODULES_OBJ) ARCH=$(KERNEL_ARCH) $(KERNEL_CROSS_COMPILE) modules_sign

$(TARGET_KERNEL_MODULES): BUILD_KERNEL_MODULES
	@echo "Copying Kernel Modules"
	find $(KERNEL_MODULES_OBJ) -type f -name '*.ko' -exec cp {} $(KERNEL_MODULES_OUT) ';'

$(TARGET_PREBUILT_INT_KERNEL): $(TARGET_KERNEL_MODULES)

$(KERNEL_HEADERS_INSTALL_STAMP): $(KERNEL_OUT_STAMP) $(KERNEL_CONFIG)
	@echo "Building Kernel Headers"
	$(MAKE) $(MAKE_FLAGS) -C $(KERNEL_SRC) O=$(KERNEL_OUT) ARCH=$(KERNEL_ARCH) $(KERNEL_CROSS_COMPILE) headers_install

# provide this rule because there are dependencies on this throughout the repo
$(KERNEL_HEADERS_INSTALL): $(KERNEL_HEADERS_INSTALL_STAMP)

.PHONY: kernel
kernel: $(INSTALLED_KERNEL_TARGET)

ALL_PREBUILT += $(INSTALLED_KERNEL_TARGET)
$(INSTALLED_KERNEL_TARGET): $(KERNEL_BIN) | $(ACP)
	$(transform-prebuilt-to-target)
endif
