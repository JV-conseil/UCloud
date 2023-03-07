#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
#
# author        : JV-conseil
# credits       : JV-conseil
# license       : EUPL-1.2 license
# copyright     : Copyright (c) 2019-2023 JV-conseil
#                 All rights reserved
#====================================================

_ucld_::back_to_script_dir_() {
  cd_ "${UCLD_PATH[main]}"
}

_ucld_::is_python_installed() {
  local _bool=false
  if [ -x "$(command -v python)" ]; then _bool=true; fi
  echo ${_bool}
}

_ucld_::is_ucloud_execution() {
  local _bool=false
  if [[ "${PWD}" == "/work/"* ]]; then _bool=true; fi
  echo ${_bool}
}

# e.g.: $(_ucld_::key_gen 128)
_ucld_::key_gen() {
  local _size=${1:-15}
  # if [ -x "$(command -v python)" ]; then
  if "$(_ucld_::is_python_installed)"; then
    python -c "import secrets; result = ''.join(secrets.choice('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-+') for i in range($_size)); print(result)"
  else
    openssl rand -base64 "${_size}"
  fi
}

_ucld_::parent_directory() {
  # <https://stackoverflow.com/a/24112741/2477854>
  echo "$(
    cd_ "$(dirname "${BASH_SOURCE[0]}")"
    pwd -P
  )"
}

# sanitize input using a regular expression
_ucld_::sanitize_input() {
  local _bool=false
  if [[ "${1}" =~ ^[a-zA-Z0-9_./-]+$ ]]; then _bool=true; fi
  echo "${_bool}"
}

_ucld_::update_and_upgrade_apt() {
  sudo apt update -y
  sudo apt upgrade -y
}

_ucld_::update_bashrc() {
  local _file
  if grep -q "cd_() " "${HOME}/.profile" &>>logfile.log; then
    return
  fi

  for _file in ".profile" ".bashrc"; do
    cat <<<"


#====================================================" >>"${HOME}/${_file}"
    cat incl/__aliases.sh >>"${HOME}/${_file}"
  done
}

# Install Python3 from source
# <https://cloudinfrastructureservices.co.uk/how-to-install-python-3-in-debian-11-10/>
# <https://computingforgeeks.com/how-to-install-python-on-debian-linux/>
# <https://computingforgeeks.com/how-to-install-python-on-ubuntu-linux/>
_ucld_::udpate_python_version() {
  local _path="/work/install" _python="3.11.2"
  # sudo apt update -y && sudo apt upgrade -y
  # sudo apt install -y build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libreadline-dev libffi-dev libsqlite3-dev wget libbz2-dev
  # sudo apt install -y python3
  cd "${_path}" || cd "${UCLD_PATH[install]}" || return
  wget "https://www.python.org/ftp/python/${_python}/Python-${_python}.tgz"
  tar -xvf "Python-${_python}.tgz"
  cd "Python-${_python}" || return 0
  sudo "./configure" --enable-optimizations
  sudo make -j "$(nproc)"
  sudo make altinstall
  pip install --upgrade pip
  cd "${_path%/*}" || return
}