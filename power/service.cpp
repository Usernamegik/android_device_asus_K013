#include <hidl/HidlTransportSupport.h>
#include "Power.h"

using android::sp;

using android::hardware::configureRpcThreadpool;
using android::hardware::joinRpcThreadpool;

using android::hardware::power::V1_0::IPower;
using android::hardware::power::V1_0::implementation::Power;

using android::OK;

int main() {
    configureRpcThreadpool(1, true /*callerWillJoin*/);

    sp<IPower> power = new Power;
    auto status = power->registerAsService();
    LOG_ALWAYS_FATAL_IF(status != OK, "Failed to register Power HAL");

    joinRpcThreadpool();
    return 0;
}
