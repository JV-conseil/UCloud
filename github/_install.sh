#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
#
# author        : JV-conseil
# credits       : JV-conseil
# copyright     : Copyright (c) 2019-2024 JV-conseil
#                 All rights reserved
#====================================================

# export GH_DEBUG=api

_ucld_::gh_cli_install() {
  local gh_cli_version gh_cli_targz

  gh_cli_version=$(curl --silent "https://api.github.com/repos/cli/cli/releases/latest" | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/' | cut -c2-)

  # NOTE: Hack v2.24.0 is bugged 🐛
  # NOTE: v2.24.3 has fixed the bug 🐛
  # gh_cli_version="2.23.0"

  gh_cli_targz="gh_${gh_cli_version}_linux_amd64.tar.gz"

  cat <<EOF

Installing GitHub CLI v$gh_cli_version...

GitHub CLI, or gh, is a command-line interface to GitHub for use in your terminal or your scripts.
https://cli.github.com/manual/

EOF

  if ! [ -x "$(command -v gh)" ]; then

    mkdir "${UCLD_PATH[install]}"

    curl -sSL "https://github.com/cli/cli/releases/download/v${gh_cli_version}/${gh_cli_targz}" -o "${UCLD_PATH[install]}/${gh_cli_targz}"
    tar -xvf "${UCLD_PATH[install]}/${gh_cli_targz}" --directory="${UCLD_PATH[install]}"
    sudo cp "${UCLD_PATH[install]}/gh_${gh_cli_version}_linux_amd64/bin/gh" /usr/local/bin/
    sudo cp -r "${UCLD_PATH[install]}/gh_${gh_cli_version}_linux_amd64/share/man/man1/"* /usr/share/man/man1/

    ls "${UCLD_PATH[install]}"

  fi

  _ucld_::h3 "You are now running $(gh version)"

}

alias gh_cli_install="_ucld_::gh_cli_install"

if ! _ucld_::is_gh_cli_installed; then

  if _ucld_::ask_2 "Do you want to install GitHub CLI"; then
    _ucld_::gh_cli_install
    echo
  fi

fi
