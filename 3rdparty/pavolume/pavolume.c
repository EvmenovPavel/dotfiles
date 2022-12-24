#include <getopt.h>
#include <math.h>
#include <memory.h>
#include <stdbool.h>
#include <stdio.h>
#include <pulse/pulseaudio.h>

#define FORMAT "%s"
#define DEFAULT_VOLUME_STEP 6
#define DEFAULT_VOLUME_MAX 153
#define DEFAULT_VOLUME_MIN 0

#define PAVOLUME_VERSION "0.1"

#define T_TAB

static pa_mainloop* mainloop = NULL;
static pa_mainloop_api* mainloop_api = NULL;
static pa_context* context = NULL;
int retval = EXIT_SUCCESS;

typedef struct Command
{
    char* format;
    bool is_delta_volume;
    bool is_mute_off;
    bool is_mute_on;
    bool is_mute_toggle;
    bool is_snoop;
    int volume;
} Command;

// Usage: amixer <options> [command]
//
// Available options:
//   -h,--help       this help
//   -c,--card N     select the card
//   -D,--device N   select the device, default 'default'
//   -d,--debug      debug mode
//   -n,--nocheck    do not perform range checking
//   -v,--version    print version of this program
//   -q,--quiet      be quiet
//   -i,--inactive   show also inactive controls
//   -a,--abstract L select abstraction level (none or basic)
//   -s,--stdin      Read and execute commands from stdin sequentially
//   -R,--raw-volume Use the raw value (default)
//   -M,--mapped-volume Use the mapped volume
//
// Available commands:
//   scontrols       show all mixer simple controls
//   scontents	 show contents of all mixer simple controls (default command)
//   sset sID P      set contents for one mixer simple control
//   sget sID        get contents for one mixer simple control
//   controls        show all controls for given card
//   contents        show contents of all controls for given card
//   cset cID P      set control contents for one control
//   cget cID        get control contents for one control



static int version()
{
    printf("[DEBUG] pavolume version: %s", PAVOLUME_VERSION);
    return EXIT_FAILURE;
}

static int quit(int new_retval)
{
    // Only set `retval` if it hasn't been changed elsewhere (such as by PulseAudio in `pa_mainloop_iterate()`).
    if (retval == EXIT_SUCCESS)
        retval = new_retval;

    if (context)
        pa_context_unref(context);

    if (mainloop_api)
        mainloop_api->quit(mainloop_api, retval);

    if (mainloop)
    {
        pa_signal_done();
        pa_mainloop_free(mainloop);
    }

    return retval;
}

static void wait_loop(pa_operation* op)
{
    while (pa_operation_get_state(op) == PA_OPERATION_RUNNING)
    {
        if (pa_mainloop_iterate(mainloop, 1, &retval) < 0)
            break;
    }

    pa_operation_unref(op);
}

static int constrain_volume(int volume)
{
    if (volume > DEFAULT_VOLUME_MAX)
        return DEFAULT_VOLUME_MAX;

    if (volume < DEFAULT_VOLUME_MIN)
        return DEFAULT_VOLUME_MIN;

    return volume;
}

static int normalize(pa_volume_t volume)
{
    return (int)round(volume * 100.0 / PA_VOLUME_NORM);
}

static pa_volume_t denormalize(int volume)
{
    return (pa_volume_t)round(volume * PA_VOLUME_NORM / 100);
}

static void set_volume(pa_context* context, const pa_sink_info* info, __attribute__((unused)) int eol, void* userdata)
{
    if (info == NULL)
        return;

    Command* command = (Command*)userdata;
    if (command->is_mute_on)
        pa_context_set_sink_mute_by_index(context, info->index, 1, NULL, NULL);

    if (command->is_mute_off)
        pa_context_set_sink_mute_by_index(context, info->index, 0, NULL, NULL);

    if (command->is_mute_toggle)
        pa_context_set_sink_mute_by_index(context, info->index, !info->mute, NULL, NULL);

    if (command->volume == -1 && !command->is_delta_volume)
        return;

    // Turn muting off on any volume change, unless muting was specifically turned on or toggled.
    if (!command->is_mute_on && !command->is_mute_toggle)
        pa_context_set_sink_mute_by_index(context, info->index, 0, NULL, NULL);

    pa_cvolume* cvolume = &info->volume;
    int new_volume = command->is_delta_volume ? normalize(pa_cvolume_avg(cvolume)) + command->volume : command->volume;
    pa_cvolume* new_cvolume = pa_cvolume_set(cvolume, info->volume.channels, denormalize(constrain_volume(new_volume)));
    pa_context_set_sink_volume_by_index(context, info->index, new_cvolume, NULL, NULL);
}

static void get_server_info(__attribute__((unused)) pa_context* c, const pa_server_info* i, void* userdata)
{
    if (i == NULL)
        return;

    strncpy(userdata, i->default_sink_name, 255);
}

static void print_volume(__attribute__((unused)) pa_context* context, const pa_sink_info* info,
                         __attribute__((unused)) int eol, void* userdata)
{
    if (info == NULL)
        return;

    Command* command = (Command*)userdata;
    char output[4] = "---";
    if (!info->mute)
        snprintf(output, 4, "%d", normalize(pa_cvolume_avg(&(info->volume))));

    printf(command->format, output);
    printf("\n");
    fflush(stdout);
}

static void handle_server_info_event(pa_context* c, const pa_server_info* i, void* userdata)
{
    if (i == NULL)
        return;

    pa_context_get_sink_info_by_name(c, i->default_sink_name, print_volume, userdata);
}

static void handle_sink_event(__attribute__((unused)) pa_context* c, pa_subscription_event_type_t t,
                              __attribute__((unused)) uint32_t idx, void* userdata)
{
    // See: https://freedesktop.org/software/pulseaudio/doxygen/subscribe.html
    if ((t & PA_SUBSCRIPTION_EVENT_TYPE_MASK) != PA_SUBSCRIPTION_EVENT_CHANGE)
        return;

    pa_context_get_server_info(context, handle_server_info_event, userdata);

}

static int init_context(pa_context* c, int retval)
{
    pa_context_connect(c, NULL, PA_CONTEXT_NOFLAGS, NULL);
    pa_context_state_t state;

    while (state = pa_context_get_state(c), true)
    {
        if (state == PA_CONTEXT_READY)
            return 0;

        if (state == PA_CONTEXT_FAILED)
            return 1;

        pa_mainloop_iterate(mainloop, 1, &retval);
    }
}

