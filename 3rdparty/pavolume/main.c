int main(int argc, char* argv[])
{
    Command command = {
    .format = FORMAT, .is_delta_volume = false, .is_mute_off = false, .is_mute_on = false, .is_mute_toggle = false, .is_snoop = false, .volume = -1,
    };

    int opt;
    int option_index = 0;

    while ((opt = getopt(argc, argv, "-hsf:m:v:")) != -1)
    {
        switch (opt)
        {
            case 'h':
            {
                // help
                return usage();
            }
            case 'v':
            {
                // help
                return version();
            }
            case 'f':
            {
                // format
                command.format = optarg;
                break;
            }
            case 'm':
            {
                // muting
                command.is_mute_off = strcmp("off", optarg) == 0;
                command.is_mute_on = strcmp("on", optarg) == 0;
                command.is_mute_toggle = strcmp("toggle", optarg) == 0;
                if (!(command.is_mute_off || command.is_mute_on || command.is_mute_toggle))
                {
                    return usage();
                }

                break;
            }
                // case 's':
                // {                // "snoop" or monitoring mode. Prints the volume level (a number between 0 and 100
                // inclusive) whenever it changes.
                // command.is_snoop = true;
                // break;
                // }
            case 's':
            {                // volume between 0 and 100 inclusive; expressed either as a specific value or as a delta.
                command.volume = (int)strtol(optarg, NULL, 10);
                if (command.volume == 0 && '0' != optarg[0])
                {
                    // If `strtol` converted the `optarg` to 0, but the argument didn't begin with a '0'
                    // then it must not have been numeric.
                    return usage();
                }

                if ('-' == optarg[0] || '+' == optarg[0])
                    command.is_delta_volume = true;

                break;
            }
            default:
            {
                return usage();
            }
        }
    }

    if (optind >= argc)
    {
        usage();
        return EXIT_FAILURE;
        // fprintf(stderr, "Expected argument after options\n");
        // return quit(EXIT_FAILURE);
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

    char* default_sink_name[256];
    wait_loop(pa_context_get_server_info(context, get_server_info, &default_sink_name));
    wait_loop(pa_context_get_sink_info_by_name(context, (char*)default_sink_name, set_volume, &command));
    // wait_loop(pa_context_get_sink_info_by_name(context, (char*)default_sink_name, print_volume, &command));

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
