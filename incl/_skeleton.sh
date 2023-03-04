#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
#
# author        : JV-conseil
# credits       : JV-conseil
# licence       : BSD 3-Clause License
# copyright     : Copyright (c) 2019-2023 JV-conseil
#                 All rights reserved
#====================================================

_ucld_::build_skeleton() {
  local _key _value

  echo -e "\nBuilding skeleton...\n"

  for _key in "${!UCLD_DIR[@]}"; do
    if [[ -z "${UCLD_DIR[${_key}]}" ]]; then
      continue
    fi
    mkdir "${UCLD_PATH["${_key}"]}" || true
  done
}

_ucld_::startup_check() {
  _ucld_::update_bashrc
  _ucld_::build_skeleton
  _ucld_::init_settings
  echo
}

# deprecated

# _ucld_::build_skeleton_v1() {
#   local _key _value _option _echo
#   _option=${1:-""}
#   _echo=0

#   for _key in "${!UCLD_DIR[@]}"; do

#     _value="${UCLD_PATH["${_key}"]}"

#     # if [[ ! -f "${_value}" && ! -d "${_value}" ]]; then

#     if [[ "${_option}" == "delete" ]]; then

#       if [ ${_echo} -eq 0 ]; then
#         echo -e "\nDeleting skeleton...\n"
#         _echo=1
#       fi

#       rm -v "${_value}"

#     else

#       if [ ${_echo} -eq 0 ]; then
#         echo -e "\nBuilding skeleton...\n"
#         _echo=1
#       fi

#       _ucld_::h3 "Building skeleton"

#       mkdir "${_value}"

#     fi # [[ "${_option}" == "delete" ]]

#     # fi # [[ ! -f "${_value}" && ! -d "${_value}" ]]

#   done

# }
