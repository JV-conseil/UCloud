#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
#
# author        : JV-conseil
# credits       : JV-conseil
# licence       : BSD 3-Clause License
# copyright     : Copyright (c) 2019-2023 JV-conseil
#                 All rights reserved
#====================================================

# shellcheck disable=SC1090,SC1091
{
  . "incl/all.sh"
  . "${UCLD_PATH[env]}/.env" || :
  . "django/_utils.sh"
  # more files
}

cat "django/README.txt"

cat <<EOF


Please select a valid Django repository...

EOF

select _dj_repo in $(dirname "${UCLD_PATH[work]}"/*/manage.py); do
  test -n "${_dj_repo}" && break
  echo ">>> Invalid Selection"
done

if [[ -d "${_dj_repo}" ]]; then

  cd_ "$_dj_repo"

  _ucld_::dj_collectstatic
  _ucld_::dj_install_dependencies

  if [[ "${VC_JOB_NUM}" -gt 0 ]]; then

    echo
    read -r -N 1 -p "Do you want to run migrations? [y/N] "
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      _ucld_::dj_running_migrations
    fi

    echo
    read -r -N 1 -p "Do you want to create a superuser? [y/N] "
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      _ucld_::dj_create_superuser
    fi

    python manage.py runserver

  else
    _ucld_::exception postgresql
  fi

  _ucld_::back_to_script_dir_
fi
