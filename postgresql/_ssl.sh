#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
#
# author        : JV-conseil
# credits       : JV-conseil
# copyright     : Copyright (c) 2019-2024 JV-conseil
#                 All rights reserved
#====================================================

_ucld_::generate_ssl_certificate() {
  local _server_key _subject

  _server_key="${UCLD_PATH[database]}/server.key"
  _subject="/CN=localhost"
  # _subject="/CN=${PGUSER}"

  openssl req -new -x509 -days 365 -nodes -text -out "${_server_key/.key/.crt}" -keyout "${_server_key}" -subj "${_subject}"
  chmod og-rwx "${_server_key}"

  cp -v "${_server_key/.key/.crt}" "${_server_key/server.key/root.crt}"

}

# <https://www.postgresql.org/docs/current/sql-altersystem.html>
_ucld_::pg_alter_system() {
  local _psql_commands _cmd

  _psql_commands=(
    "ALTER SYSTEM SET ssl = on ;"
    "ALTER SYSTEM SET ssl_ca_file = 'root.crt' ;"
    "ALTER SYSTEM SET ssl_cert_file = 'server.crt' ;"
    "ALTER SYSTEM SET ssl_crl_file = '' ;"
    "ALTER SYSTEM SET ssl_key_file = 'server.key' ;"
    "ALTER SYSTEM SET ssl_ciphers = 'HIGH:MEDIUM:+3DES:!aNULL' ;"
    "ALTER SYSTEM SET ssl_prefer_server_ciphers = on ;"
  )

  for _cmd in "${_psql_commands[@]}"; do
    # echo "${_cmd}"
    psql --dbname=postgres --command="${_cmd}" # 2>>logfile.log
  done
}

_ucld_::pg_hba_update() {
  local _template

  case "${PGSSLMODE}" in

  "require")
    _template="postgresql/pg_hba.conf.md5.txt"
    ;;

  "verify-ca" | "verify-full")
    _template="postgresql/pg_hba.conf.cert.txt"
    ;;

  *)
    _template="postgresql/pg_hba.conf.bkp"
    ;;

  esac

  if [[ ! -f "${UCLD_PATH[database]}/pg_hba.conf.bkp" ]]; then
    cp -v "${UCLD_PATH[database]}/pg_hba.conf" "${UCLD_PATH[database]}/pg_hba.conf.bkp" # &>>logfile.log
  fi

  cat "${_template}" >"${UCLD_PATH[database]}/pg_hba.conf"

}

_ucld_::pg_reload_conf() {
  psql --dbname=postgres --command="SELECT pg_reload_conf() ;"
}

_ucld_::pg_conf_ssl() {
  if [[ ! -d ${UCLD_PATH[database]} ]]; then
    _ucld_::exception "${UCLD_PATH[database]} database directory not found"
    return
  fi

  _ucld_::generate_ssl_certificate
  _ucld_::pg_alter_system
  _ucld_::pg_hba_update
  _ucld_::pg_reload_conf
}

_ucld_::generate_ssl_certificate_v1() {
  local _password _server_key _subject
  _server_key="${UCLD_PATH[database]}/server.key"
  _password="$(_ucld_::key_gen)"
  _subject="/C=FR/ST=IDF/L=/O=JV conseil - Internet Consulting/OU=/CN=JV conseil/emailAddress=contact@jv-conseil.net"

  # _password="$(openssl rand -base64 15)"
  # _server_key="server.key"

  # create an ssl certificate key
  {
    openssl genrsa -aes128 -passout pass:"${_password}" -out "${_server_key}" 2048
    openssl rsa -in "${_server_key}" -passin pass:"${_password}" -out "${_server_key}"
    chown ucloud "${_server_key}"
    openssl req -new -x509 -days 365 -key "${_server_key}" -out "${_server_key/.key/.crt}" -subj "${_subject}"
    cp "${_server_key/.key/.crt}" "${_server_key/server.key/root.crt}"
    cat "${_server_key}" >"${UCLD_PATH[env]}/server.cert.pem"
    cat "${_server_key/.key/.crt}" >>"${UCLD_PATH[env]}/server.cert.pem"
  } 1>/dev/null 2>>logfile.log
}
