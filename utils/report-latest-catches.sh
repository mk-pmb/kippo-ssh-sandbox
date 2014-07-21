#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-
SELFPATH="$(readlink -m "$0"/..)"


function main () {
  cd "$SELFPATH" || return $?
  local SENS_NAME="$(grep -Pe '^sensor_name=' -m 1 ../kippo.cfg 2>/dev/null \
    | cut -d '=' -f 2- | tr -sc '\nA-Za-z0-9._-' '?')"
  [ -n "$SENS_NAME" ] || SENS_NAME=no_sensor_name_configured

  if [ -n "$MAILTO" ]; then
    # assume cronjob piped to nullmailer-inject or sendmail -t
    echo 'From: "Kippo Sandbox" '"<${SENS_NAME//\?/+}@kippo.ssh>"
    echo "To: $MAILTO"
    echo "Subject: Latest kippo activity on $SENS_NAME"
    local CTYPE='text/plain'
    case "$LANG" in
      *.UTF-8 ) CTYPE+='; charset=UTF-8';;
      * ) CTYPE+='; charset=ASCII';;
    esac
    echo "Content-Type: $CTYPE"
    echo 'Content-Transfer-Encoding: 8bit'
    echo 'MIME-Version: 1.0'
    echo
  fi

  LANG=C ls -1 ../dl/ ../log/[a-z]*/ 2>/dev/null | sed -nre '
    s~\t~ ~g
    s~^([0-9]{4})([0-9]{2})([0-9]{2})[_-]?($\
      |[0-9]{2})([0-9]{2})([0-9]*)[_-]?|$\
      ~\1-\2-\3 \4:\5 \6\t~
    /\t/p
    ' | LANG=C sort --reverse | head -n 50 | sed -re '
    s~ [0-9]*\t~\t~
    s~\t([a-z]+)_{3}~\t\1:~
    s~^20~~
    s!^(.{60}).{10,}(.{30})$!\1 ... \2!
    s~\t~ ~
    '
  return 0
}









main "$@"; exit $?
