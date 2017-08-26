#include <fstream>

#include "Light.h"

namespace android {
namespace hardware {
namespace light {
namespace V2_0 {
namespace implementation {

#define BRIGHTNESS_PATH  "/sys/class/backlight/intel_backlight/brightness"

#define MAX_BRIGHTNESS_INPUT   255
#define MAX_BRIGHTNESS_OUTPUT  100

static uint32_t getBrightness(const uint32_t color) {
    // Based on recommendation in LightState.color
    const uint32_t brightness = ((77*((color>>16)&0x00ff)) + (150*((color>>8)&0x00ff)) + (29*(color&0x00ff))) >> 8;

    // Input brightness is 0-255, however intel_backlight accepts 0-100
    return brightness ? brightness * MAX_BRIGHTNESS_OUTPUT / MAX_BRIGHTNESS_INPUT : 0;
}

static Status writeBrightness(const uint32_t brightness) {
    std::ofstream file(BRIGHTNESS_PATH);
    if (file) {
        file << brightness;
        file.close();
        if (file) {
            return Status::SUCCESS;
        } else {
            ALOGE("Failed to update brightness: %s", strerror(errno));
        }
    } else {
        ALOGE("Failed to open brightness control: %s", strerror(errno));
    }

    return Status::UNKNOWN;
}

// Methods from ::android::hardware::light::V2_0::ILight follow.
Return<Status> Light::setLight(Type type, const LightState& state) {
    if (type != Type::BACKLIGHT) {
        return Status::LIGHT_NOT_SUPPORTED;
    }

    const auto brightness = getBrightness(state.color);
    ALOGV("Setting brightness: %d", brightness);
    return writeBrightness(brightness);
}

Return<void> Light::getSupportedTypes(getSupportedTypes_cb _hidl_cb) {
    _hidl_cb({Type::BACKLIGHT});
    return Void();
}

}  // namespace implementation
}  // namespace V2_0
}  // namespace light
}  // namespace hardware
}  // namespace android
