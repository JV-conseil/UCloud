#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
#
# author        : JV-conseil
# credits       : JV-conseil
# copyright     : Copyright (c) 2019-2024 JV-conseil
#                 All rights reserved
#====================================================

_ucld_::debug() {
  local _debug=${1:-DEBUG}

  if [[ "${_debug}" -eq 0 ]]; then
    return
  fi

  cat <<EOF


===============
 DEBUG LEVEL ${_debug}
===============

EOF

  cat /proc/version 2>/dev/null || :
  cat /etc/issue 2>/dev/null || :
  _ucld_::set_show_options
  python --version || :

  if [[ "${_debug}" -gt 1 ]]; then

    if [[ "${_debug}" -gt 2 ]]; then

      if [[ "${_debug}" -gt 3 ]]; then
        _ucld_::debugger
      fi

      echo "$(
        set -o posix
        set | sort
      )"

    else

      echo
      env -0 | sort -z | tr "\0" "\n"
      echo

    fi

    echo
    alias
    echo
  fi
}

# Usage:
# DEBUGGER=1 TRACE=1 BASH_ENV=utilities/debugger.sh ./main.sh
_ucld_::debugger() {
  _ucld_::set_strict_mode

  PS4='+[$0:$LINENO] '

  if [[ -v DEBUGGER ]]; then
    # if type bashdb &>/dev/null || :; then
    shopt -s extdebug
  else
    set -o errtrace
    set -o functrace
  fi

  if [[ -v TRACE ]]; then
    echo "Running TRACE mode..."
    exec 4>./utilities/xtrace.out
    BASH_XTRACEFD=4
    set -o xtrace # same as set -x
  fi

  if [[ -v NOOP ]]; then
    echo "Run NOOP mode"
    set -o noexec # same as set -n
  fi

  # shellcheck disable=SC2145,2317
  debug() {
    echo "[ DEBUG ]| BASH_COMMAND=${BASH_COMMAND}"
    echo "         | BASH_ARGC=${BASH_ARGC[@]} BASH_ARGV=${BASH_ARGV[@]}"
    echo "         | BASH_SOURCE: ${!BASH_SOURCE[@]} ${BASH_SOURCE[@]}"
    echo "         | BASH_LINENO: ${!BASH_LINENO[@]} ${BASH_LINENO[@]}"
    echo "         | FUNCNAME: ${!FUNCNAME[@]} ${FUNCNAME[@]}"
    echo "         | PIPESTATUS: ${!PIPESTATUS[@]} ${PIPESTATUS[@]}"
  }

  trap 'echo ERR trap from ${FUNCNAME:-MAIN} context. $BASH_COMMAND failed with error code $?' ERR
  trap 'debug' DEBUG
}
