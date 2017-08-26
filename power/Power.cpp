#include <fstream>

#include "Power.h"

namespace android {
namespace hardware {
namespace power {
namespace V1_0 {
namespace implementation {

#define TOUCHSCREEN_POWER_CONTROL_PATH  "/sys/bus/i2c/devices/i2c-GDIX1001:00/power/control"
#define BATTERY_POWER_CONTROL_PATH      "/sys/bus/i2c/devices/i2c-UPIG3105:00/power/control"

#define RUNTIME_PM_ON           "on"
#define RUNTIME_PM_AUTOSUSPEND  "auto"

#define updateRuntimePM(path, disable) \
    writeFile(path, disable ? RUNTIME_PM_ON : RUNTIME_PM_AUTOSUSPEND)
#define updateTouchscreenState(enable) \
    updateRuntimePM(TOUCHSCREEN_POWER_CONTROL_PATH, enable)
#define updateBatteryState(enable) \
    updateRuntimePM(BATTERY_POWER_CONTROL_PATH, enable)

static void writeFile(const char *path, const char *text) {
    std::ofstream file(path);
    if (file) {
        file << text;
        file.close();
        if (!file) {
            ALOGE("Failed to write to %s: %s", path, strerror(errno));
        }
    } else {
        ALOGE("Failed to open %s: %s", path, strerror(errno));
    }
}

// Methods from ::android::hardware::power::V1_0::IPower follow.
Return<void> Power::setInteractive(bool interactive) {
    ALOGV("Set interactive: %d", interactive);
    updateTouchscreenState(interactive);
    updateBatteryState(interactive);
    return Void();
}

Return<void> Power::powerHint(PowerHint /*hint*/, int32_t /*data*/) {
    return Void();
}

Return<void> Power::setFeature(Feature /*feature*/, bool /*activate*/) {
    return Void();
}

Return<void> Power::getPlatformLowPowerStats(getPlatformLowPowerStats_cb _hidl_cb) {
    _hidl_cb({}, Status::SUCCESS);
    return Void();
}

}  // namespace implementation
}  // namespace V1_0
}  // namespace power
}  // namespace hardware
}  // namespace android
