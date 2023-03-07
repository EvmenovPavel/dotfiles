#ifndef PAVOLUME_H
#define PAVOLUME_H

#include <stdbool.h>

// #include <pulse/operation.h>
#include <pulse/pulseaudio.h>

#include "config.h"
#include "usage.h"
#include "options.h"

typedef struct Command
{
    char* format;
    bool is_delta_volume;
    bool is_name;
    bool is_status;
    bool is_mute;
    bool is_mute_on;
    bool is_mute_off;
    bool is_mute_toggle;
    bool is_snoop;
    bool is_get;
    int volume;
} Command;

int init_pavolume(int argc, char* argv[]);

#endif //PAVOLUME_H
