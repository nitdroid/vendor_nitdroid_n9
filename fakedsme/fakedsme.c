/*
** Copyright 2012, Alexey Roslyakov <alexey.roslyakov@newsycat.com>
**
** Licensed under the Apache License, Version 2.0 (the "License");
** you may not use this file except in compliance with the License.
** You may obtain a copy of the License at
**
**     http://www.apache.org/licenses/LICENSE-2.0
**
** Unless required by applicable law or agreed to in writing, software
** distributed under the License is distributed on an "AS IS" BASIS,
** WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
** See the License for the specific language governing permissions and
** limitations under the License.
*/

#include <unistd.h>
#include <errno.h>
#include <fcntl.h>
#include <linux/rtc.h>
#include <linux/ioctl.h>

#define LOG_TAG "wdpinger"
#include <utils/Log.h>

#include <sys/socket.h>
#include <sys/un.h>

static const char DSME_SOCKET[] = "/mnt/initfs/tmp/dsmesock";
static const char IPHB_SOCKET[] = "/dev/shm/iphb";
static const char WATCHDOG_DEV[]    = "/dev/watchdog"; 
static const char TWL4030_WDT_DEV[] = "/dev/twl4030_wdt"; 

static void* dsme()
{
  int s_dsme, s2;
  struct sockaddr_un local, remote;
  int len;
  s_dsme = socket(AF_UNIX, SOCK_STREAM, 0);

  local.sun_family = AF_UNIX;  /* local is declared before socket() ^ */
  strcpy(local.sun_path, DSME_SOCKET);
  unlink(local.sun_path);
  len = strlen(local.sun_path) + sizeof(local.sun_family);
  bind(s_dsme, (struct sockaddr *)&local, len);

  listen(s_dsme, 5);

  s2 = accept(s_dsme, (struct sockaddr *)&remote, &len);
  fprintf(stderr, "dsme connected!\n");

  char foo[256];
  read(s2, foo, sizeof(foo));
  write(s2, "\20\0\0\0\20\0\0\0\7\3\0\0\0\0\0\0", 16);
  write(s2, "\20\0\0\0\20\0\0\0\1\3\0\0\2\0\0\0", 16);

  while (1)
  {
    read(s2, foo, sizeof(foo));
  }

  return 0;
}

static void* iphb()
{
  int s_iphb, s2;
  struct sockaddr_un local, remote;
  int len;
  s_iphb = socket(AF_UNIX, SOCK_STREAM, 0);

  local.sun_family = AF_UNIX;  /* local is declared before socket() ^ */
  strcpy(local.sun_path, IPHB_SOCKET);
  unlink(local.sun_path);
  len = strlen(local.sun_path) + sizeof(local.sun_family);
  bind(s_iphb, (struct sockaddr *)&local, len);

  listen(s_iphb, 5);

  s2 = accept(s_iphb, (struct sockaddr *)&remote, &len);
  fprintf(stderr, "iphb connected!\n");

  char foo[256];

  while (1)
  {
    read(s2, foo, sizeof(foo));
  }
  
  return 0;
}

int main(int argc, const char **argv)
{
  signal(SIGPIPE, SIG_IGN);

  // @todo FIXME
  pthread_t thr;
  pthread_create(&thr, NULL, dsme, 0);
  pthread_create(&thr, NULL, iphb, 0);

  int watchdog = -1;
  int twl4030_wdt = -1;
  int alarm = -1;

  while(1)
  {
    if (watchdog < 0)
      watchdog = open(WATCHDOG_DEV, O_WRONLY);

    if (twl4030_wdt < 0)
      twl4030_wdt = open(TWL4030_WDT_DEV, O_WRONLY);

    write(watchdog, "*", 1);
    write(twl4030_wdt, "*", 1);

    if (alarm < 0)
      alarm = open("/dev/rtc0", O_RDWR);

    if (alarm < 0)
      sleep(10);
    else {
      struct timeval tv = {10, 0};     /* 10 second timeout on select */
      fd_set readfds;
      int fd = alarm; int ret;
      unsigned long data;
      struct rtc_time rtc_tm;

      FD_ZERO(&readfds);
      FD_SET(fd, &readfds);
      /* The select will wait until an RTC interrupt happens. */
      int retval = select(fd+1, &readfds, NULL, NULL, &tv);
      if (retval == -1) {
        LOGE("select");
      }
      /* This read won't block unlike the select-less case above. */
      if (FD_ISSET(fd, &readfds)) {
      retval = read(fd, &data, sizeof(unsigned long));
      if (retval == -1) {
        LOGE("read");
      }
      LOGD(" %lu",data);
      }
    }
  }

  return 0;
}
