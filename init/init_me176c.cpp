#include <fstream>

#ifdef REPLACE_PROPERTIES
#define _REALLY_INCLUDE_SYS__SYSTEM_PROPERTIES_H_
#include <sys/_system_properties.h>
#define property_set(name, value) \
    __system_property_update((prop_info*) __system_property_find(name), value, strlen(value))
#else
#include "property_service.h"
#endif

#include "log.h"

#define PHONE_INFO  "/factory/PhoneInfodisk/PhoneInfo_inf"

/* Serial number */
#define SERIALNO_PROP  "ro.serialno"
#define SERIALNO_SIZE  12+1

static void load_serialno() {
    // Open file
    std::ifstream file(PHONE_INFO);
    if (!file) {
        PLOG(ERROR) << "Failed to open phone info file";
        return;
    }

    char serial[SERIALNO_SIZE];

    // Read serial from file
    if (!file.get(serial, SERIALNO_SIZE)) {
        PLOG(ERROR) << "Failed to read serialno from phone info file";
        return;
    }

    // Set serialno property
    int ret = property_set(SERIALNO_PROP, serial);
    if (ret) {
        PLOG(ERROR) << "Failed to set " SERIALNO_PROP " property: " << ret;
    }
}

void vendor_load_properties() {
    load_serialno();
}
