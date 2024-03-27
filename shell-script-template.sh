#!/usr/bin/env bash

# fail fast
set -Eeuo pipefail
trap cleanup SIGINT SIGTERM ERR EXIT

readonly script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

usage() {
  cat <<USAGE_TEXT
Usage: $(basename "${BASH_SOURCE[0]}") [-h] [-v] [-f] [-d] -p <value> [-o <value>] arg1 [arg2...]

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
-s, --silent
    Silent mode, no output (not recommended with dry-run mode)

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
  BOLD=$(tput bold)
  NORMAL=$(tput sgr0)
  DIM=$(tput sgr0 && tput dim)
  UNDERLINE=$(tput smul)
  BOLD_UL=$(tput bold)$(tput smul)
  if [[ -t 2 ]] && [[ -z "${NO_COLOR-}" ]] && [[ "${TERM-}" != "dumb" ]]; then
    # \033 or \e is the escape character and coupled with the '[' makes the prefix used to specify color, 0; indicates normal (not bold/etc.), then a color code (see wiki)

    NOFORMAT='\e[0m'
    BLUE='\e[0;94m'
    RED='\e[0;31m'
    YELLOW='\e[0;93m'
    ORANGE='\e[0;33m'
    PINK='\e[0;95m'
    CYAN='\e[0;96m'
    GREEN='\e[0;92m'
    WHITE='\e[0;97m'
    GRAY='\e[0;90m'
  else
    NOFORMAT='' BLUE='' RED='' YELLOW='' ORANGE='' PINK='' CYAN='' GREEN='' WHITE='' GRAY=''
  fi
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
  [[ is_not_silent_mode ]] && [[ "${DEBUG-0}" -eq 1 ]]
}

msg() {
  if is_not_silent_mode; then
    # "In short: stdout is for output, stderr is for messaging."
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
  local code=${2-1} # default exit status 1
  if is_not_silent_mode; then
    msg "${RED}$msg${NOFORMAT}"
  fi
  exit "$code"
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

  # TODO: update the argument parsing to match the options/parameters for this script (should always align with usage text)
  while :; do
    case "${1-}" in
    -h|--help) usage ;;
    -d|--dry-run|--dryrun|--dry) DRY_RUN=1 ;;
    --debug) DEBUG=1 ;;
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

  args=("$@")

  is_debug_mode && dbg "Debug mode enabled" || msg "Not debug mode"

  # TODO: perform validation here and/or remove the following:
  [[ -z "${param-}" ]] && die "Missing required parameter: param"
  
  # This is only used if there are required args that aren't options/parameters
  # [[ ${#args[@]} -eq 0 ]] && die "Missing script arguments"

  return 0
}

parse_params "${@}"
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


