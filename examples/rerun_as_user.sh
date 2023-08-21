#!/usr/bin/env bash

#set -u  # stop when undeclared variables get consumed
#set -e  # stop when exitcode != 0
#set -x  # trace (useful for debuggging)


[ -z "${SBL_DIR-}" ] && SBL_DIR="../src"


. "${SBL_DIR}"/sbl.bash



param_info() {
    [ $# -eq 0 ] && return

    echo count params: $#
    for p in "$@" ; do
        echo "${p}"
    done
}

param_info "$@"



if sbl_is_root ; then
        echo "I am root (rerun is needed)"
        echo "start rerun"
    else
        echo "I am user it's ok (rerun is not needed)"
fi


sbl_rerun_as_user "$@"
