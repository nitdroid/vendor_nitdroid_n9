/*
 * Copyright (C) 2012 The NITDroid Open Source Project
 * Copyright (C) 2008 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include <fcntl.h>
#include <errno.h>
#include <math.h>
#include <poll.h>
#include <unistd.h>
#include <dirent.h>
#include <sys/select.h>
#include <cutils/log.h>

#include "MagneticSensor.h"

struct ak8975_data {
    __s16 x;
    __s16 y;
    __s16 z;
    __u16 valid;
} __attribute__((packed));

/*****************************************************************************/

MagneticSensor::MagneticSensor()
    : SensorBase(NULL, NULL),
      mEnabled(0),
      mHasPendingEvent(false),
      mEnabledTime(0)
{
    mPendingEvent.version = sizeof(sensors_event_t);
    mPendingEvent.sensor = ID_M;
    mPendingEvent.type = SENSOR_TYPE_MAGNETIC_FIELD;
    memset(mPendingEvent.data, 0, sizeof(mPendingEvent.data));
}

MagneticSensor::~MagneticSensor() {
    if (mEnabled) {
        enable(0, 0);
    }
}

int MagneticSensor::setInitialState() {
    return 0;
}

int MagneticSensor::enable(int32_t, int en) {
    int flags = en ? 1 : 0;
    LOGD("MagneticSensor::enable %d", en);
    if (en && dev_fd <= 0) {
        dev_fd = open("/dev/ak89750", O_RDONLY);
        if (dev_fd <= 0) {
            LOGE("Couldn't open %s (%s)", dev_name, strerror(errno));
            return -1;
        }
    }
    else {
        close_device();
    }
    return 0;
}

bool MagneticSensor::hasPendingEvents() const {
    return 1;
}

int MagneticSensor::setDelay(int32_t handle, int64_t delay_ns)
{
    LOGD("MagneticSensor::setDelay(%d, %ld) - ignored", handle, delay_ns);
    return 0;
}

int MagneticSensor::readEvents(sensors_event_t* data, int count)
{
    if (count < 1)
        return -EINVAL;

    ak8975_data akdata;
    int r = read(dev_fd, &akdata, sizeof(akdata));
    LOGD("MagneticSensor r: %d x: %d, y: %d, z: %d, v: %d", r, (int) akdata.x, (int) akdata.y, (int) akdata.z, (int) akdata.valid);

    // TODO: matrix transform for calibration?
    mPendingEvent.magnetic.x = akdata.x;
    mPendingEvent.magnetic.y = akdata.y;
    mPendingEvent.magnetic.z = akdata.z;
    *data++ = mPendingEvent;

    return 1;
}
