# SBL - Simple Bash Library
#
# Copyright (C) Koynov Stas - skojnov@yandex.ru
#
# SPDX-License-Identifier: MIT


# shellcheck disable=SC2034  # unused vars
# shellcheck disable=SC2059  # warn for printf
# shellcheck disable=SC2148  # SBL is lib (no shebang)



# If already included, don't do anything
[ -n "${SBL_VERSION-}" ] && return


# support only bash
if [ -z "${BASH-}" ]; then
    echo "Error: SBL support only bash" >&2
    return 1
fi



readonly SBL_VERSION_MAJOR=0
readonly SBL_VERSION_MINOR=1
readonly SBL_VERSION="${SBL_VERSION_MAJOR}.${SBL_VERSION_MINOR}"



sbl_is_root() { [ ${EUID:-$(id -u)} -eq 0 ] ; }
sbl_is_user() { [ ${EUID:-$(id -u)} -ne 0 ] ; }



#
# out: true(0) if script was sourced(included) otherwise false(1)
# in:  ["any"]
#
# any - indicates that you need to search at any level,
#       not only at the first one (main script)
#
sbl_is_sourced() {
    if [ "$1" == "any" ] ; then
        for f in "${FUNCNAME[@]}" ; do
            [ "$f" == "source" ] && return
        done
    fi

    [ "${FUNCNAME[-1]}" == "source" ]
}



sbl_is_main() { ! sbl_is_sourced "any" ; }



sbl_exit_if_user() { sbl_is_user && sbl_log -f "${1:-"root rights required\\n"}" ; }
sbl_exit_if_root() { sbl_is_root && sbl_log -f "${1:-"user rights required\\n"}" ; }



# out: full path of script
# in:  [script_name], if not set, it's script that called this function
sbl_get_src_dir() { dirname "$(readlink -f "${1:-${BASH_SOURCE[1]}}")" ; }



# out: full name (with path) of script
# in:  [script_name], if not set, it's script that called this function
sbl_get_src_full_name() { readlink -f "${1:-${BASH_SOURCE[1]}}" ; }



# out: basename of script
# in:  [script_name], if not set, it's script that called this function
sbl_get_src_name() { basename "$(readlink -f "${1:-${BASH_SOURCE[1]}}")" ; }



#
# Will run the command as a user(SBL_USER) (with user rights)
#
# in: cmd [params]
#
# examples:
# sbl_run_cmd_as_user some_cmd "param1 param2"
# sbl_run_cmd_as_user some_cmd '"param11 param12" "param21"'
# sbl_run_cmd_as_user some_cmd "\"param11 param12\" \"param21\""
#
sbl_run_cmd_as_user() { sudo -u "$SBL_USER" bash -c "$*" ; }
sbl_run_cmd_as_root() { sudo bash -c "$*" ; }



#
# Will run the function as a user(SBL_USER) (with user rights)
#
# in: function_name [params]
#
# examples:
# sbl_run_fun_as_user some_function "param1 param2"
# sbl_run_fun_as_user some_function '"param11 param12" "param21"'
# sbl_run_fun_as_user some_function "\"param11 param12\" \"param21\""
#
sbl_run_fun_as_user() { sbl_run_cmd_as_user "$(declare -f "$1"); $*" ; }
sbl_run_fun_as_root() { sbl_run_cmd_as_root "$(declare -f "$1"); $*" ; }



#
# |cmd\variable     |$SUDO_USER| $USER |$SBL_USER |  $HOME  |$SBL_HOME
# |-----------------|----------|-------|----------|---------|-----------
# |xxx:$ ./t.sh     |    nul   |  xxx  |   xxx    |/home/xxx|/home/xxx
# |-----------------|----------|-------|----------|---------|-----------
# |xxx:$ sudo ./t.sh|    xxx   |  root |   xxx    |  /root  |/home/xxx
# |-----------------|----------|-------|----------|---------|-----------
# |xxx:# ./t.sh     |    xxx   |  root |   xxx    |  /root  |/home/xxx
# |-----------------|----------|-------|----------|---------|-----------
# |xxx:# sudo ./t.sh|    root  |  root |   xxx    |  /root  |/home/xxx
#
SBL_USER=$(logname)
readonly SBL_USER


# Single quotes because we don't want $HOME expansion
# shellcheck disable=SC2016
SBL_HOME=$(sbl_run_cmd_as_user 'echo -n $HOME')
readonly SBL_HOME



sbl_rerun_as_root() {
    if sbl_is_user ; then
        sbl_run_cmd_as_root "$(sbl_get_src_full_name "${BASH_SOURCE[1]}") $*"
    fi
}



sbl_rerun_as_user() {
    if sbl_is_root ; then
        sbl_run_cmd_as_user "$(sbl_get_src_full_name "${BASH_SOURCE[1]}") $*"
    fi
}



# Foreground colors
readonly SBL_TXT_FG_BK="\e[30m"  # Black
readonly SBL_TXT_FG_RD="\e[31m"  # Red
readonly SBL_TXT_FG_GR="\e[32m"  # Green
readonly SBL_TXT_FG_YL="\e[33m"  # Yellow
readonly SBL_TXT_FG_BL="\e[34m"  # Blue
readonly SBL_TXT_FG_MG="\e[35m"  # Magenta
readonly SBL_TXT_FG_CY="\e[36m"  # Cyan
readonly SBL_TXT_FG_WT="\e[37m"  # White

# Background colors
readonly SBL_TXT_BG_BK="\e[40m"  # Black
readonly SBL_TXT_BG_RD="\e[41m"  # Red
readonly SBL_TXT_BG_GR="\e[42m"  # Green
readonly SBL_TXT_BG_YL="\e[43m"  # Yellow
readonly SBL_TXT_BG_BL="\e[44m"  # Blue
readonly SBL_TXT_BG_MG="\e[45m"  # Magent
readonly SBL_TXT_BG_CY="\e[46m"  # Cyan
readonly SBL_TXT_BG_WT="\e[47m"  # White

# Text mode
readonly SBL_TXT_MODE_CL="\e[0m"   # Clear/Reset any text mode
readonly SBL_TXT_MODE_BO="\e[1m"   # Bold
readonly SBL_TXT_MODE_UN="\e[4m"   # Underline
readonly SBL_TXT_MODE_BL="\e[5m"   # Flash/blink
readonly SBL_TXT_MODE_NE="\e[7m"   # Negative
readonly SBL_TXT_MODE_NO="\e[22m"  # Normal


readonly SBL_LOG_LVL_DBG=0  # debug
readonly SBL_LOG_LVL_INF=1  # info
readonly SBL_LOG_LVL_WRN=2  # warning
readonly SBL_LOG_LVL_ERR=3  # error
readonly SBL_LOG_LVL_FTL=4  # fatal (will be exit 1)
readonly SBL_LOG_LVL_CNT=5  # not level
readonly SBL_LOG_LVL_OFF=4  # off log, but fatal will be work


SBL_LOG_TXT_LVL=("Debug")
SBL_LOG_TXT_LVL+=("Info ")
SBL_LOG_TXT_LVL+=("Warn ")
SBL_LOG_TXT_LVL+=("Error")
SBL_LOG_TXT_LVL+=("Error")
# short varian
SBL_LOG_TXT_LVL+=("D")
SBL_LOG_TXT_LVL+=("I")
SBL_LOG_TXT_LVL+=("W")
SBL_LOG_TXT_LVL+=("E")
SBL_LOG_TXT_LVL+=("E")

readonly SBL_LOG_SHORT_SHIFT=$SBL_LOG_LVL_CNT

# log colors
SBL_LOG_COLOR_LVL=("${SBL_TXT_FG_BL}")
SBL_LOG_COLOR_LVL+=("${SBL_TXT_FG_GR}")
SBL_LOG_COLOR_LVL+=("${SBL_TXT_FG_YL}")
SBL_LOG_COLOR_LVL+=("${SBL_TXT_FG_RD}")
SBL_LOG_COLOR_LVL+=("${SBL_TXT_FG_MG}")



_sbl_get_log_prefix() {

    local time_fmt="${SBL_LOG_TIME_FMT:-"%(%Y-%m-%d %H:%M:%S)T"}"
    local prefix="${SBL_LOG_PREFIX:-"%LVL: %TF: "}"
    local log_lvl=${1:-$SBL_LOG_LVL_INF}
    local txt_index=$log_lvl

    # if short
    ${2:-false} && ((txt_index += SBL_LOG_SHORT_SHIFT))

    local txt_lvl=${SBL_LOG_TXT_LVL[$txt_index]}

    # if color
    ${3:-true} && txt_lvl="${SBL_LOG_COLOR_LVL[$log_lvl]}${txt_lvl}${SBL_TXT_MODE_CL}"


    prefix="${prefix//"%TF"/$time_fmt}"
    printf "${prefix//"%LVL"/$txt_lvl}"
}



#
# A very simple logger based on the printf function.
# The log level is determined by the input arguments (-d, -i, etc...).
# options:
#  -nc | --no-color - turn off color (color is turned off automatically for the file)
#  -s  | --short    - use a one-letter variant of the log level
#
# global options:
#  SBL_LOG_LVL      - min log level to be work
#  SBL_LOG_TIME_FMT - time format for printf function
#  SBL_LOG_PREFIX   - log prefix format (see details in _sbl_get_log_prefix)
#  SBL_LOG_FILE     - log file, if defined, the output will be redirect to this file
#
# examples:
#  sbl_log [options] "printf_fmt" params_for_printf
#  sbl_log --debug --short --no-color "HOME_PATH: %s\n" "${SBL_HOME}"
#
sbl_log() {

    local log_lvl=${SBL_LOG_LVL:-$SBL_LOG_LVL_INF}
    local cur_lvl=${SBL_LOG_LVL_INF}
    local color=true
    local short=false


    for option in "$@"; do
        case $option in
            -d | --debug) cur_lvl=${SBL_LOG_LVL_DBG} ; shift ;;
            -i | --info)  cur_lvl=${SBL_LOG_LVL_INF} ; shift ;;
            -w | --warn)  cur_lvl=${SBL_LOG_LVL_WRN} ; shift ;;
            -e | --error) cur_lvl=${SBL_LOG_LVL_ERR} ; shift ;;
            -f | --fatal) cur_lvl=${SBL_LOG_LVL_FTL} ; shift ;;

            -nc | --no-color) color=false ; shift ;;
            -s  | --short)    short=true  ; shift ;;
        esac
    done


    [ "$log_lvl" -gt "$cur_lvl" ] && return


    [ -n "${SBL_LOG_FILE-}" ] && color=false # off color for FILE

    _sbl_log() {
        printf "$(_sbl_get_log_prefix $cur_lvl $short $color)"
        printf "$@"
    }

    if [ -n "${SBL_LOG_FILE-}" ]; then
        _sbl_log "$@"  >> "${SBL_LOG_FILE}" 2>&1
    elif [ $cur_lvl -ge ${SBL_LOG_LVL_ERR} ]; then
        _sbl_log "$@"  >&2
    else
        _sbl_log "$@"
    fi

    [ $cur_lvl -eq $SBL_LOG_LVL_FTL ] && exit 1
}



sbl_request_reboot() {

    while true ; do
        read -r -n 1 -p "Reboot system now? [y|n]: "

        case $REPLY in
            y|Y) reboot ;;
            n|N) return ;;
            *)   printf "\nInvalid input. Please press 'y' or 'n'\n" ;;
        esac
    done
}
