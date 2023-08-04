#!/usr/bin/env bash

#set -u  # stop when undeclared variables get consumed
#set -e  # stop when exitcode != 0
#set -x  # trace (useful for debuggging)


[ -z "${SBL_DIR-}" ] && SBL_DIR="../src"


. "${SBL_DIR}"/sbl.bash



SBL_LOG_LVL=0  # all

sbl_log -d "it's debug   level\n"
sbl_log -i "it's info    level\n"
sbl_log -w "it's warning level\n"
sbl_log -e "it's error   level\n"

sbl_log -d -s "it's debug   level (short variant)\n"
sbl_log -i -s "it's info    level (short variant)\n"
sbl_log -w -s "it's warning level (short variant)\n"
sbl_log -e -s "it's error   level (short variant)\n"

sbl_log -d --no-color "no_color\n"
sbl_log -i --no-color "no_color\n"
sbl_log -w --no-color "no_color\n"
sbl_log -e --no-color "no_color\n"

sbl_log -i "USER:%s  HOME:%s\n"  "${SBL_USER}" "${SBL_HOME}"

# new time format
SBL_LOG_TIME_FMT="%(%H:%M:%S)T"
sbl_log -i "new time format\n"


# off time
SBL_LOG_PREFIX="%LVL: "
sbl_log -d "it's debug   level (no time)\n"
sbl_log -i "it's info    level (no time)\n"
sbl_log -w "it's warning level (no time)\n"
sbl_log -e "it's error   level (no time)\n"



SBL_LOG_FILE="1.log"
sbl_log -d "it's debug   level (no time)\n"
sbl_log -i "it's info    level (no time)\n"
sbl_log -w "it's warning level (no time)\n"
sbl_log -e "it's error   level (no time)\n"

# restore default prefix and time format
SBL_LOG_PREFIX=
SBL_LOG_TIME_FMT=
sbl_log -d -s "it's debug   level (short variant)\n"
sbl_log -i -s "it's info    level (short variant)\n"
sbl_log -w -s "it's warning level (short variant)\n"
sbl_log -e -s "it's error   level (short variant)\n"

SBL_LOG_FILE=
sbl_log -f "Fatal (must be exit 1)\n\n"

# last log was be fatal (we must be exit from script)
echo "We shouldn't have reached this cmd"
