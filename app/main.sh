#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
#
# author        : JV-conseil
# credits       : JV-conseil
# copyright     : Copyright (c) 2019-2024 JV-conseil
#                 All rights reserved
#====================================================

# shellcheck source=/dev/null
. "incl/all.sh"

cat "app/README.txt"

_app_repo=""

if [[ ${UCLD_PATH[app]+_} ]]; then

  _app_repo="${UCLD_PATH[app]}"

else

  _ucld_::h2 "Please select a repo with a Python app"

  select _app_repo in $(dirname "${UCLD_PATH[work]}"/*/main.py || :); do
    test -n "${_app_repo}" && break
    _ucld_::alert ">>> Invalid Selection"
  done

fi

if [[ "${_app_repo}" ]]; then

  if [[ -f "${_app_repo}/main.py" ]]; then

    _ucld_::update_settings "UCLD_DIR[app]=""${_app_repo##*/}"""

    _ucld_::h2 "Installing dependencies"
    # pip install -r "${_app_repo}/requirements.txt"
    sudo python3 -m pip install -r "${_app_repo}/requirements.txt"

    _ucld_::h2 "Running the app"
    python3 "${_app_repo}/main.py"

    _ucld_::h2 "Displaying the output folder"
    ls "${UCLD_PATH[data]}/output"

  else
    _ucld_::exception "No main.py file found in ${_app_repo} directory\nAre you sure it is a valid Python 🐍 app?"
  fi

fi
