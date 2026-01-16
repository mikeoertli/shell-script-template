#!/usr/bin/env bash

# fail fast
set -Eeuo pipefail
trap cleanup SIGINT SIGTERM ERR EXIT

# shellcheck disable=SC2034
readonly script_dir="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" &>/dev/null && pwd -P)"
NO_COLOR=0

usage() {
  cat <<USAGE_TEXT
Usage: $(basename "${BASH_SOURCE[0]}") [-h] [-v] [-f] [-d] [-n] [-s] [--test-colors] -p <value> [-o <value>] arg1 [arg2...]

TODO: Script description here (make sure to update parse_params accordingly).

Script configuration:

-h, --help                      
    Print this help and exit
-v, --verbose
    Print script debug info (enables '-x' for bash)
--debug
    Enables debug logging (not as verbose as --verbose)
-d, --dry-run, --dryrun, --dry
    Dry run (only print what would be done, don't actually perform any operations)
-n, --no-color
    Disable colorized output
-b, --batch
    Batch mode, runs without prompting the user for anything.
-s, --silent
    Silent mode, no output (not recommended with dry-run mode)
--test-colors
    Print a message that shows the status of colors being enabled as well as samples of the colors themselves, 
    used for testing terminal color support.
    Does not exit the script after running this test.
--test-colors-and-exit
    Print a message that shows the status of colors being enabled as well as samples of the colors themselves, 
    used for testing terminal color support.
    Exits the script after running this test.

Available options:

-f, --flag
    Some flag description
-p, --param <value> [REQUIRED]
    Some param description
-o, --other-param <value> [OPTIONAL]
    Some other param description (default: 'some value')
USAGE_TEXT
  exit
}

cleanup() {
  trap - SIGINT SIGTERM ERR EXIT
  # script cleanup here
}

setup_colors() {
  # Typically uses bright color variants.
  # About terminal colors/format: https://unix.stackexchange.com/a/438357
  # Uses 3 and 4-bit color codes: https://en.wikipedia.org/wiki/ANSI_escape_code#3-bit_and_4-bit
  # Uncomment these if needed:
  # BOLD=$(tput bold)
  # NORMAL=$(tput sgr0)
  # DIM=$(tput sgr0 && tput dim)
  # UNDERLINE=$(tput smul)
  # BOLD_UL=$(tput bold)$(tput smul)
  # -t 2 checks if stderr is connected to an interactive terminal
  if [[ ${NO_COLOR-0} -ne 1 ]] && [[ -t 2 ]] && [[ "${TERM-}" != "dumb" ]]; then
    # \033 or \e is the escape character and coupled with the '[' makes the prefix used to specify color, 0; indicates normal (not bold/etc.), then a color code (see wiki)
    NOFORMAT='\033[0m'
    NORMAL='\033[0m'
    BLUE='\033[34m'
    RED='\033[31m'
    YELLOW='\033[93m'
    ORANGE='\033[33m'  # Some terminals may not support a distinct orange code
    PINK='\033[95m'    # Not a standard code; using intense magenta
    CYAN='\033[36m'
    GREEN='\033[32m'
    WHITE='\033[37m'
    GRAY='\033[90m'
    PURPLE='\033[35m'
  else
    # shellcheck disable=SC2034
    NORMAL='' NOFORMAT='' BLUE='' RED='' YELLOW='' ORANGE='' PINK='' CYAN='' GREEN='' WHITE='' GRAY='' PURPLE=''
  fi
}

test_colors() {
  local orig=$NO_COLOR
  if [[ "${NO_COLOR-0}" -eq 0 ]]; then
    msg "Colors are ENABLED! (NO_COLOR = $NO_COLOR)"
  else
    msg "Colors are DISABLED! (NO_COLOR = $NO_COLOR)"
    NO_COLOR=0
    setup_colors
  fi
  msg ""
  msg "WITH COLORS:"
  msg "  ${BLUE}BLUE${NOFORMAT} -- ${RED}RED${NOFORMAT} -- ${YELLOW}YELLOW${NOFORMAT} -- ${ORANGE}ORANGE${NOFORMAT} -- ${PINK}PINK${NOFORMAT} -- ${CYAN}CYAN${NOFORMAT} -- ${GREEN}GREEN${NOFORMAT} -- ${WHITE}WHITE${NOFORMAT} -- ${GRAY}GRAY${NOFORMAT} -- ${PURPLE}PURPLE${NOFORMAT}"
  NO_COLOR=1
  setup_colors
  msg "WITHOUT COLORS:"
  msg "  ${BLUE}BLUE${NOFORMAT} -- ${RED}RED${NOFORMAT} -- ${YELLOW}YELLOW${NOFORMAT} -- ${ORANGE}ORANGE${NOFORMAT} -- ${PINK}PINK${NOFORMAT} -- ${CYAN}CYAN${NOFORMAT} -- ${GREEN}GREEN${NOFORMAT} -- ${WHITE}WHITE${NOFORMAT} -- ${GRAY}GRAY${NOFORMAT} -- ${PURPLE}PURPLE${NOFORMAT}"
  NO_COLOR=$orig
  setup_colors
}

test_colors_and_exit() {
  test_colors
  exit
}

# Set them up initially so they work, but the setup will be rerun when parsing the parameters.
setup_colors

#
# Utility functions for script
#

is_dry_run() {
  [[ "${DRY_RUN-0}" -eq 1 ]]
}

is_silent_mode() {
  [[ "${SILENT-0}" -eq 1 ]]
}

is_not_silent_mode() {
  [[ "${SILENT-0}" -ne 1 ]]
}

is_debug_mode() {
  is_not_silent_mode && [[ "${DEBUG-0}" -eq 1 ]]
}

is_batch_mode() {
  [[ "${BATCH_MODE-0}" -eq 1 ]]
}

msg() {
  if is_not_silent_mode; then
    # stdout is for output, stderr is for messaging (thus we use stderr for messaging)
    echo >&2 -e "${1-}"
  fi
}

dbg() {
  if is_debug_mode; then
    echo >&2 -e "${GRAY}${1-}${NOFORMAT}"
  fi
}

die() {
  local msg=$1
  local code=${2:-1} # default exit status 1
  if is_not_silent_mode; then
    msg "${RED}$msg${NOFORMAT}"
  fi
  exit "$code"
}

color_wrap() {
  local VALUE=${1:?"String to be wrapped is required"}
  
  echo "${2:-$NOFORMAT}$VALUE${NOFORMAT}"
}

parse_params() {  
  # Do NOT use getopts, macOS version doesn't support long args

  # default values of variables set from params
  flag=0
  param=''
  other=''
  DRY_RUN=0
  SILENT=0
  DEBUG=0
  BATCH_MODE=0
  TEST_COLORS_MODE=0

  # TODO: update the argument parsing to match the options/parameters for this script (should always align with usage text)
  while :; do
    case "${1-}" in
    -h|--help) usage ;;
    --test-colors) TEST_COLORS_MODE=1 ;;
    --test-colors-and-exit) test_colors_and_exit ;;
    -d|--dry-run|--dryrun|--dry) DRY_RUN=1 ;;
    --debug) DEBUG=1 ;;
    -b|--batch) BATCH_MODE=1 ;;
    -s|--silent) SILENT=1 ;;
    -v|--verbose) set -x ;;
    -n|--no-color) NO_COLOR=1 ;;
    -f|--flag) flag=1 ;; # example flag
    -p|--param) # example named parameter
      param="${2-}"
      shift
      ;;
    -o | --other-param) # example 2nd named parameter
      other="${2-}"
      shift
      ;;
    -?*) die "Unknown option: $1" ;;
    *) break ;;
    esac
    shift
  done

  # The arguments passed after the parameters are saved to this array
  args=("$@")

  if is_debug_mode ; then
    dbg "Debug mode enabled. There are ${#args[@]} script args."
  else
    msg "Not debug mode"
  fi

  # TODO: perform any appropriate validation here and/or remove the following:
  [[ -z "${param-}" ]] && die "Missing required parameter: param"
  [[ -z "${other-}" ]] && die "Missing required parameter: other"
  
  # This is only used if there are required args that aren't options/parameters
  # [[ ${#args[@]} -eq 0 ]] && die "Missing script arguments"

  return 0
}

parse_params "${@}"

if [[ "${TEST_COLORS_MODE-0}" -eq 1 ]]; then
  test_colors
fi

setup_colors

#  Print some info for debugging
dbg "${RED}Read parameters:${NOFORMAT}"
dbg "- flag: ${ORANGE}${flag}${NOFORMAT}"
dbg "- param: ${ORANGE}${param}${NOFORMAT}"
dbg "- arguments: ${ORANGE}${args[*]-}${NOFORMAT}"


#
# Additional utility functions for script
#
# TODO: additional functions for script here (optional)


#
# Main body of script logic
#

# TODO: script logic here


