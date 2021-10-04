#!/bin/bash

APP=php
GROUP=root
USER=root
HOME=/opt/$APP
SYSD=/etc/systemd/system
SERFILE=php-fpm.service

init() {
  egrep "^$GROUP" /etc/group >/dev/null
  if [[ $? -ne 0 ]]; then
    groupadd -r $GROUP
  fi

  egrep "^$USER" /etc/passwd >/dev/null
  if [[ $? -ne 0 ]]; then
    useradd -r -g $GROUP -s /usr/sbin/nologin -M $USER
  fi

  if [[ ! -d $HOME/log ]]; then
    mkdir -p $HOME/log
    chmod 755 $HOME/log
  fi

  if [[ ! -d $HOME/var ]]; then
    mkdir -p $HOME/var
    chmod 755 $HOME/var
  fi

  if [[ ! -d $HOME/var/run ]]; then
    mkdir -p $HOME/var/run
    chmod 755 $HOME/var/run
  fi

  chown -R $GROUP:$USER $HOME

  if [[ ! -s $SYSD/$SERFILE ]]; then
    ln -s $HOME/setup/$SERFILE $SYSD/$SERFILE
    systemctl enable $SERFILE
    echo "($APP) create symlink: $SYSD/$SERFILE --> $HOME/setup/$SERFILE"
  fi

  systemctl daemon-reload
}

deinit() {
  if [[ -s $SYSD/$SERFILE ]]; then
    systemctl disable $SERFILE
    rm -rf $SYSD/$SERFILE
    echo "($APP) delete symlink: $SYSD/$SERFILE"
  fi

  systemctl daemon-reload

  egrep "^$USER" /etc/passwd >/dev/null
  if [[ $? -eq 0 ]]; then
    userdel $USER
  fi

  egrep "^$GROUP" /etc/group >/dev/null
  if [[ $? -eq 0 ]]; then
    groupdel $GROUP
  fi

  chown -R root:root $HOME
}

start() {
  pgrep -x php-fpm >/dev/null
  if [[ $? != 0 ]]; then
    systemctl start $SERFILE
    echo "($APP) php-fpm start!"
  fi
  show
}

stop() {
  pgrep -x php-fpm >/dev/null
  if [[ $? == 0 ]]; then
    systemctl stop $SERFILE
    echo "($APP) php-fpm stop!"
  fi
  show
}

show() {
  ps -ef | grep $APP | grep -v 'grep'
}

case "$1" in
  init) init ;;
  deinit) deinit ;;
  start) start ;;
  stop) stop ;;
  show) show ;;
  *)
    SCRIPTNAME="${0##*/}"
    echo "Usage: $SCRIPTNAME {init|deinit|start|stop|show}"
    exit 3
    ;;
esac

exit 0

# vim: syntax=sh ts=4 sw=4 sts=4 sr noet
