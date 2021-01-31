#!/bin/bash

export PHP_DISABLE_ENV=yes
export PHPRC=/opt/php/lib
export PHP_INI_SCAN_DIR=/opt/php/lib/php.d
eval "optbin -s /opt/php/bin"
eval "optbin -s /opt/php/sbin"


