#!/bin/bash

# docker run --rm -it -v /tmp:/tmp --entrypoint bash dtr.cucloud.net/cs/apache22

cd /tmp
tar zxf /tmp/cuwal-2.3.0.238.tar.gz
cd cuwal-2.3.0.238
source /etc/apache2/envvars
patch configure -l -i ../conf.patch -o configure.no_apr_psprintf
chmod +x configure.no_apr_psprintf
./configure.no_apr_psprintf --with-apxs=/usr/bin/apxs2
make
cd apache
make install
cp /usr/lib/apache2/modules/mod_cuwebauth.so /tmp/target
