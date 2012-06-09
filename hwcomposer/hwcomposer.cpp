/*
 * Copyright (C) 2010 The Android Open Source Project
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

#include <hardware/hardware.h>

#include <fcntl.h>
#include <errno.h>

#include <cutils/log.h>
#include <cutils/atomic.h>
#include <cutils/properties.h>

#include <hardware/hwcomposer.h>

#include <EGL/egl.h>

#include <fcntl.h>
#include <errno.h>
#include <sys/ioctl.h>
#include <string.h>
#include <stdlib.h>

/*****************************************************************************/

#define CPUFREQ "/sys/devices/system/cpu/cpu0/cpufreq/"

static const char CPUFREQ_GOVERNOR[] = CPUFREQ "scaling_governor";
static const char CPUFREQ_SETSPEED[] = CPUFREQ "scaling_setspeed";

static const char LCD_BLANK[] = "/sys/class/graphics/fb0/blank";
static const char DISABLE_TS[] = "/sys/devices/platform/i2c_omap.2/i2c-2/2-004b/disable_ts";
static const char CPR_COEF[] = "/sys/devices/platform/omapdss/manager0/cpr_coef";
static const char CPR_ENABLE[] = "/sys/devices/platform/omapdss/manager0/cpr_enable";

static int fb = -1;

static int fbUpdateWindow(int fd, int x=0, int y=0, int width=854, int height=480)
{
#define _IOC(dir,type,nr,size)                  \
    (((dir)  << _IOC_DIRSHIFT) |                \
     ((type) << _IOC_TYPESHIFT) |               \
     ((nr)   << _IOC_NRSHIFT) |                 \
     ((size) << _IOC_SIZESHIFT))
#define _IOW(type,nr,size)      _IOC(_IOC_WRITE,(type),(nr),(_IOC_TYPECHECK(size)))

#define OMAP_IOW(num, dtype)	_IOW('O', num, dtype)

    struct omapfb_update_window {
        __u32 x, y;
        __u32 width, height;
        __u32 format;
        __u32 out_x, out_y;
        __u32 out_width, out_height;
        __u32 reserved[8];
    };

    const unsigned int OMAPFB_UPDATE_WINDOW = OMAP_IOW(54, struct omapfb_update_window);
    const unsigned int OMAPFB_SET_UPDATE_MODE = OMAP_IOW(40, int);

    struct omapfb_update_window update;
    memset(&update, 0, sizeof(omapfb_update_window));
    update.format = 0; /*OMAPFB_COLOR_RGB565*/
    update.x = x;
    update.y = y;
    update.out_x = x;
    update.out_y = y;
    update.out_width = width;
    update.out_height = height;
    update.width = width;
    update.height = height;
    if (ioctl(fd, OMAPFB_UPDATE_WINDOW, &update) < 0) {
        LOGE("Could not ioctl(OMAPFB_UPDATE_WINDOW): %s", strerror(errno));
    }

    //LOGD("fbUpdateWindow(%d, %d, %d, %d)", x, y, width, height);
    return 0;
}

static int readSomethingFromFile(const char *file)
{
    int f = open(file, O_RDONLY);
    int res = 0;

    if (f > 0) {
        char buf[32];
        if ( read(f, buf, sizeof(buf)) <= 0) {
            LOGE("Error reading from file '%s': %s", file, strerror(errno));
            res = errno;
        }
    }
    else {
        LOGE("Can't open file '%s' for reading: %s", file, strerror(errno));
        res = errno;
    }

    return res;
}

static int writeStringToFile(const char *file, const char *data)
{
    int res = 0;
    int f = open(file, O_WRONLY);
    if (f <= 0) {
        LOGE("writeStringToFile can't open file %s: %s", file, strerror(errno));
        return errno;
    }

    int len = strlen(data);
    if (len != write(f, data, len)) {
        LOGE("writeStringToFile(%s, %s) failed: %s", file, data, strerror(errno));
        res = errno;
    }

    close(f);
    return res;
}

static void* wakeupHackThread(void *)
{
    char propValue[PROPERTY_VALUE_MAX];

    //
    // after awake several window updates needed to avoid freezes in SurfaceFlinger
    //

    while(1)
    {
        // wait for fb wake
        if (readSomethingFromFile("/sys/power/wait_for_fb_wake") != 0)
            break;

        writeStringToFile(LCD_BLANK, "0\n");
        writeStringToFile(DISABLE_TS, "0\n");
        writeStringToFile(CPUFREQ_GOVERNOR, "ondemand");

        // set user-defined (see /default.prop) colour profile for LCD
        if ( property_get("hw.lcd.colourprofile", propValue, NULL)) {
            LOGD("Colour profile: %s", propValue);
            writeStringToFile(CPR_COEF, propValue);
            writeStringToFile(CPR_ENABLE, "1");
        }

        // TODO make it proper
        usleep(100000);
        for(int i = 0; i < 10; i++)
            fbUpdateWindow(fb);

        // wait for sleep to lock in next read
        if (readSomethingFromFile("/sys/power/wait_for_fb_sleep") != 0)
            break;

        writeStringToFile(LCD_BLANK, "1\n");
        writeStringToFile(DISABLE_TS, "1\n");
        writeStringToFile(CPUFREQ_GOVERNOR, "userspace");
        writeStringToFile(CPUFREQ_SETSPEED, "300000");
        //writeStringToFile(CPR_ENABLE, "0");
    }

    return 0;
}

struct hwc_context_t {
    hwc_composer_device_t device;
    /* our private state goes below here */
};

static int hwc_device_open(const struct hw_module_t* module, const char* name,
        struct hw_device_t** device);

static struct hw_module_methods_t hwc_module_methods = {
    open: hwc_device_open
};

hwc_module_t HAL_MODULE_INFO_SYM = {
    common: {
        tag: HARDWARE_MODULE_TAG,
        version_major: 1,
        version_minor: 0,
        id: HWC_HARDWARE_MODULE_ID,
        name: "Sample hwcomposer module",
        author: "The Android Open Source Project",
        methods: &hwc_module_methods,
    }
};

/*****************************************************************************/

static void dump_layer(hwc_layer_t const* l) {
    LOGD("\ttype=%d, flags=%08x, handle=%p, tr=%02x, blend=%04x, {%d,%d,%d,%d}, {%d,%d,%d,%d}",
            l->compositionType, l->flags, l->handle, l->transform, l->blending,
            l->sourceCrop.left,
            l->sourceCrop.top,
            l->sourceCrop.right,
            l->sourceCrop.bottom,
            l->displayFrame.left,
            l->displayFrame.top,
            l->displayFrame.right,
            l->displayFrame.bottom);
}

static int hwc_prepare(hwc_composer_device_t *dev, hwc_layer_list_t* list) {
    if (list && (list->flags & HWC_GEOMETRY_CHANGED)) {
        for (size_t i=0 ; i<list->numHwLayers ; i++) {
            //dump_layer(&list->hwLayers[i]);
            list->hwLayers[i].compositionType = HWC_FRAMEBUFFER;
        }
    }
    return 0;
}

static int hwc_set(hwc_composer_device_t *dev,
        hwc_display_t dpy,
        hwc_surface_t sur,
        hwc_layer_list_t* list)
{
#if 0
    LOGD("size: %d, HWC_GEOMETRY_CHANGED: %d", list->numHwLayers, list->flags & HWC_GEOMETRY_CHANGED);
    for (size_t i=0 ; i<list->numHwLayers ; i++) {
        dump_layer(&list->hwLayers[i]);
    }
#endif

    EGLBoolean sucess = eglSwapBuffers((EGLDisplay)dpy, (EGLSurface)sur);

    fbUpdateWindow(fb);

    if (!sucess) {
        return HWC_EGL_ERROR;
    }
    return 0;
}

static int hwc_device_close(struct hw_device_t *dev)
{
    struct hwc_context_t* ctx = (struct hwc_context_t*)dev;
    if (ctx) {
        free(ctx);
    }
    return 0;
}

/*****************************************************************************/

static int hwc_device_open(const struct hw_module_t* module, const char* name,
        struct hw_device_t** device)
{
    int status = -EINVAL;
    if (!strcmp(name, HWC_HARDWARE_COMPOSER)) {
        struct hwc_context_t *dev;
        dev = (hwc_context_t*)malloc(sizeof(*dev));

        /* initialize our state here */
        memset(dev, 0, sizeof(*dev));

        /* initialize the procs */
        dev->device.common.tag = HARDWARE_DEVICE_TAG;
        dev->device.common.version = 0;
        dev->device.common.module = const_cast<hw_module_t*>(module);
        dev->device.common.close = hwc_device_close;

        dev->device.prepare = hwc_prepare;
        dev->device.set = hwc_set;

        *device = &dev->device.common;
        status = 0;

        fb = open("/dev/graphics/fb0", O_RDWR, 0);
        if (fb < 0)
            status = errno;
        else {
            pthread_t th;
            pthread_create(&th, 0, wakeupHackThread, 0);
            pthread_detach(th);
        }
    }
    return status;
}
