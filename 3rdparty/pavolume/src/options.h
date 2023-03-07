#ifndef PAVOLUME_OPTIONS_H
#define PAVOLUME_OPTIONS_H

#include <stdlib.h>
#include <getopt.h>

static struct option long_options[] = {
{  "set"    , required_argument, NULL, 's'}
, {"muting" , required_argument, NULL, 'm'}
, {"help"   , no_argument      , NULL, 'h'}
, {"version", no_argument      , NULL, 'v'}
, {"get"    , no_argument      , NULL, 'g'}
, {"format" , no_argument      , NULL, 'f'}
, {"wait"   , no_argument      , NULL, 'w'}
, {"status" , no_argument      , NULL, 'S'}
, {"name"   , no_argument      , NULL, 'N'}
// , {"list"   , no_argument      , NULL, 'l'}
// , {"longwait", no_argument      , NULL, 'W'}
// , {"print"   , no_argument      , NULL, 'p'}
// , {"next"    , no_argument      , NULL, 'n'}
// , {"debug"  , no_argument      , NULL, 'd'}
, {         NULL, 0            , NULL, 0}
};

#endif //PAVOLUME_OPTIONS_H
