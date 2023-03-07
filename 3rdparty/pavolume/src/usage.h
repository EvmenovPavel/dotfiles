#ifndef PAVOLUME_USAGE_H
#define PAVOLUME_USAGE_H

#include <stdio.h>
#include <stdlib.h>

// Usage: update-alternatives [<option> ...] <command>
//
// Commands:
//   --install <link> <name> <path> <priority>
//     [--slave <link> <name> <path>] ...
//                            add a group of alternatives to the system.
//   --remove <name> <path>   remove <path> from the <name> group alternative.
//   --remove-all <name>      remove <name> group from the alternatives system.
//   --set <name> <path>      set <path> as alternative for <name>.
//   --all                    call --config on all alternatives.

// Options:
//   --log <file>             change the log file.
//   --quiet                  quiet operation, minimal output.
//   --verbose                verbose operation, more output.
//   --debug                  debug output, way more output.
//   --help                   show this help message.
//   --version                show the version.

static int usage()
{
    printf("Usage: pavolume <options>\n");
    printf("\n");
    printf("Available options:\n");
    printf("  -h|--help             Show this help\n");
    printf("  -v|--version          Print version of this program\n");
    printf("  -s|--set +/-N         Volume level. A number between 0 and 100\n"
           /*    */"                        inclusive. Critical 153. Optionally prefixed\n"
           /*    */"                        with `+` or `-` to denote a delta.\n");
    printf("  -g|--get              Get volume level\n");
    printf("  -m={on,off,toggle}]   Muting options\n");
    printf("  -w|--wait             Waits for volume change\n");
    // printf("  -W                    Infinitely waits for volume change,\n"
    //        /*    */"                        prints volume to stdout\n");
    // printf("  -f|--format           Format string. Default: `%s`\n", "%s");
    printf("\n");

    // printf("Available commands:\n");
    // printf("mon");

    return EXIT_FAILURE;
}

#endif //PAVOLUME_USAGE_H
