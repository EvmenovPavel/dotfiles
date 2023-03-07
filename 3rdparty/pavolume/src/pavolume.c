#include "pavolume.h"

#include <math.h>
#include <memory.h>
#include <stdbool.h>
#include <stdio.h>
#include <pulse/pulseaudio.h>

#include "config.h"

int version()
{
    printf("[DEBUG] pavolume version: %s\n", PAVOLUME_VERSION);
    return EXIT_FAILURE;
}

int quit(int new_retval)
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

void wait_loop(pa_operation* operation)
{
    while (pa_operation_get_state(operation) == PA_OPERATION_RUNNING)
    {
        if (pa_mainloop_iterate(mainloop, 1, &retval) < 0)
            break;
    }

    pa_operation_unref(operation);
}

static float constrain_volume(float volume)
{
    if (volume > PA_DEFAULT_VOLUME_MAX)
        return PA_DEFAULT_VOLUME_MAX;

    if (volume < PA_DEFAULT_VOLUME_MIN)
        return PA_DEFAULT_VOLUME_MIN;

    return volume;
}

static int normalize(pa_volume_t volume)
{
    return (int)round(volume * 100.0 / PA_VOLUME_NORM);
}

static pa_volume_t denormalize(float volume)
{
    return (pa_volume_t)round(volume * PA_VOLUME_NORM / 100);
}

static void print_status(__attribute__((unused)) pa_context* context, const pa_sink_info* info,
                         __attribute__((unused)) int eol, void* userdata)
{
    if (info == NULL)
        return;

    printf("pa_cvolume_max: %d\n", pa_cvolume_max(&(info->volume)));
    printf("pa_cvolume_avg: %f\n", pa_sw_volume_to_linear(pa_cvolume_avg(&(info->volume))));
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

void get_by_name(pa_context* context, const pa_sink_info* info, __attribute__((unused)) int eol, void* userdata)
{

}

void set_volume(pa_context* context, const pa_sink_info* info, __attribute__((unused)) int eol, void* userdata)
{
    if (info == NULL)
        return;

    Command* command = (Command*)userdata;
    if (command->is_mute_on)
        pa_context_set_sink_mute_by_index(context, info->index, 0, NULL, NULL);

    if (command->is_mute_off)
        pa_context_set_sink_mute_by_index(context, info->index, 1, NULL, NULL);

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

void get_server_info(__attribute__((unused)) pa_context* context, const pa_server_info* info, void* userdata)
{
    if (info == NULL)
        return;

    strncpy(userdata, info->default_sink_name, 255);
}

static void handle_server_info_event(pa_context* context, const pa_server_info* info, void* userdata)
{
    if (info == NULL)
        return;

    pa_context_get_sink_info_by_name(context, info->default_sink_name, print_volume, userdata);
}

void handle_sink_event(__attribute__((unused)) pa_context* context, pa_subscription_event_type_t t,
                       __attribute__((unused)) uint32_t idx, void* userdata)
{
    // See: https://freedesktop.org/software/pulseaudio/doxygen/subscribe.html
    if ((t & PA_SUBSCRIPTION_EVENT_TYPE_MASK) != PA_SUBSCRIPTION_EVENT_CHANGE)
        return;

    pa_context_get_server_info(context, handle_server_info_event, userdata);

}

int init_context(pa_context* context, int retval)
{
    pa_context_connect(context, NULL, PA_CONTEXT_NOFLAGS, NULL);
    pa_context_state_t state;

    while (state = pa_context_get_state(context), true)
    {
        if (state == PA_CONTEXT_READY)
            return 0;

        if (state == PA_CONTEXT_FAILED)
            return 1;

        pa_mainloop_iterate(mainloop, 1, &retval);
    }
}

int init_pavolume(int argc, char* argv[])
{
    Command command = {
    .format = FORMAT, //
    .is_delta_volume = false, //
    .is_mute_off = false, //
    .is_mute_on = false, //
    .is_mute_toggle = false, //
    .is_snoop = false, //
    .volume = -1,
    };

    int opt = 0;
    int option_index = 0;
    while ((opt = getopt_long(argc, argv, "s:m:hvgwSN", long_options, &option_index)) != -1)
    {
        switch (opt)
        {
            case 'h': // help
            {
                return usage();
            }
            case 'v': // version
            {
                return version();
            }
            case 'f': // format
            {
                command.format = optarg;
                break;
            }
            case 'g': // get
            {
                command.is_get = true;
                break;
            }
            case 'S': // status
            {
                command.is_status = true;
                break;
            }
            case 'N': // name
            {
                command.is_name = true;
                break;
            }
            case 'm': // muting
            {
                command.is_mute = true;
                command.is_mute_off = strcmp("off", optarg) == 0;
                command.is_mute_on = strcmp("on", optarg) == 0;
                command.is_mute_toggle = strcmp("toggle", optarg) == 0;

                if (!(command.is_mute_off || command.is_mute_on || command.is_mute_toggle))
                    return usage();

                break;
            }
            case 'w':
            {
                // "snoop" or monitoring mode. Prints the volume level (a number between 0 and 100
                // inclusive) whenever it changes.
                command.is_snoop = true;
                break;
            }
            case 's':
            {
                // volume between 0 and 100 inclusive; expressed either as a specific value or as a delta.
                if ('-' == optarg[0] || '+' == optarg[0])
                    command.is_delta_volume = true;
                else
                    return usage();

                command.volume = (int)strtol(optarg, NULL, 10);
                if (command.volume == 0 && '0' != optarg[0])
                {
                    // If `strtol` converted the `optarg` to 0, but the argument didn't begin with a '0'
                    // then it must not have been numeric.
                    return usage();
                }

                break;
            }
            default:
            {
                return quit(retval);
            }
        }
    }

    if (optind == 1)
    {
        return usage();
    }

    mainloop = pa_mainloop_new();
    if (!mainloop)
    {
        fprintf(stderr, "Could not create PulseAudio main loop\n");
        return quit(EXIT_FAILURE);
    }

    mainloop_api = pa_mainloop_get_api(mainloop);
    if (pa_signal_init(mainloop_api) != 0)
    {
        fprintf(stderr, "Could not initialize PulseAudio UNIX signal subsystem\n");
        return quit(EXIT_FAILURE);
    }

    context = pa_context_new(mainloop_api, argv[0]);
    if (!context || init_context(context, retval) != 0)
    {
        fprintf(stderr, "Could not initialize PulseAudio context\n");
        return quit(EXIT_FAILURE);
    }

    char default_sink_name[256];
    wait_loop(pa_context_get_server_info(context, get_server_info, &default_sink_name));
    wait_loop(pa_context_get_sink_info_by_name(context, default_sink_name, set_volume, &command));

    if (command.is_name)
    {
        printf("%s\n", default_sink_name);
        return quit(EXIT_FAILURE);
    }

    if (command.is_get || command.is_mute)
    {
        wait_loop(pa_context_get_sink_info_by_name(context, default_sink_name, print_volume, &command));
        return quit(EXIT_FAILURE);
    }

    if (command.is_status)
    {
        wait_loop(pa_context_get_sink_info_by_name(context, default_sink_name, print_status, &command));
        return quit(EXIT_FAILURE);
    }

    if (command.is_snoop)
    {
        pa_context_set_subscribe_callback(context, handle_sink_event, &command);
        pa_context_subscribe(context, PA_SUBSCRIPTION_MASK_SINK, NULL, NULL);

        if (pa_mainloop_run(mainloop, &retval) != 0)
        {
            fprintf(stderr, "Could not run PulseAudio main loop\n");
            return quit(EXIT_FAILURE);
        }
    }

    return quit(retval);
}