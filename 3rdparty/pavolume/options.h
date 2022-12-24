//
// Created by be3yh4uk on 6/28/22.
//

#ifndef PAVOLUME_OPTIONS_H
#define PAVOLUME_OPTIONS_H

// #include <stdio.h>
#include <stdlib.h>
#include <getopt.h>

static struct option long_options[] = {
{  "help"    , no_argument      , NULL, 'h'}
, {"version" , no_argument      , NULL, 'v'}
, {"set"     , required_argument, NULL, 's'}
, {"get"     , required_argument, NULL, 'g'}
, {"list"    , no_argument      , NULL, 'l'}
, {"wait"    , no_argument      , NULL, 'w'}
, {"longwait", no_argument      , NULL, 'W'}
, {"print"   , no_argument      , NULL, 'p'}
, {"next"    , no_argument      , NULL, 'n'}
, {"debug"   , no_argument      , NULL, 'd'}
, {NULL      , 0                , NULL, 0}
,
};

#endif //PAVOLUME_OPTIONS_H
