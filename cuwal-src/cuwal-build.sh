#!/bin/bash

set -e

tar zxf cuwal-${CUWA_VERSION}.tar.gz
cd cuwal-${CUWA_VERSION}

autoconf

# Disable use of format-security warnings as errors on Ubuntu 14.04
if [[ -f /usr/share/apache2/build/config_vars.mk ]] && [[ -f ../config_vars.mk.patch ]]; then
    patch /usr/share/apache2/build/config_vars.mk -f -i ../config_vars.mk.patch -l -r -
else
    echo Skipping patch to /usr/share/apache2/build/config_vars.mk on this platform
fi

if [[ -f ../conf.patch-${CUWA_VERSION} ]]; then
    patch configure -f -i ../conf.patch-${CUWA_VERSION} -l -o configure.my.cuwa-build
    chmod +x configure.my.cuwa-build
else
    ln -s configure configure.my.cuwa-build
fi

./configure.my.cuwa-build
make
cd apache
make install

    
