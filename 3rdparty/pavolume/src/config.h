#ifndef PAVOLUME_CONFIG_H
#define PAVOLUME_CONFIG_H

#define FORMAT "%s"
#define PA_DEFAULT_VOLUME_STEP 5
#define PA_DEFAULT_VOLUME_MAX 153
#define PA_DEFAULT_VOLUME_MIN 0

#define PAVOLUME_VERSION "0.1"

static pa_mainloop* mainloop = NULL;
static pa_mainloop_api* mainloop_api = NULL;
static pa_context* context = NULL;
static int retval = EXIT_SUCCESS;

#endif //PAVOLUME_CONFIG_H
