#!/bin/bash

set -e -x

echo "EXPECT success from Apache configtest"
/usr/sbin/apache2ctl configtest

echo "EXPECT success from disabling mod_cuwebauth and starting Apache"
/usr/sbin/a2dismod cuwebauth
/usr/sbin/service apache2 start

echo "EXPECT success from Apache stop"
/usr/sbin/service apache2 stop

echo "EXPECT failure from a2dismod on non-existent module"
! /usr/sbin/a2dismod my-bogus-module

echo "EXPECT failure from a2enmod on non-existent module"
! /usr/sbin/a2enmod my-bogus-module

echo "EXPECT failure from enabling mod_cuwebauth and Apache start-up"
/usr/sbin/a2enmod cuwebauth
! /usr/sbin/service apache2 start 

echo "EXPECT success reconfiguring for CUWA"
cat <<EOF > /etc/apache2/conf-enabled/test.conf
CUWAWebLoginURL "https://web1.login.cornell.edu https://web2.login.cornell.edu https://web3.login.cornell.edu https://web4.login.cornell.edu"
CUWApermitServer "permitd/permit1@CIT.CORNELL.EDU@permit1.cit.cornell.edu:80 permitd/permit1@CIT.CORNELL.EDU@permit0.cit.cornell.edu:80"
CUWAWAK2Flags 1
CUWAReturnURL https://localhost
CUWAkerberosPrincipal  "https/localhost-test-bogus@CIT.CORNELL.EDU"
CUWAKeytab          "/infra/httpd/keytabs/https.localhost-test-bogus.keytab"
CUWAsessionFilePath "/infra/httpd/sessions"
EOF
mkdir -p /infra/httpd/keytabs /infra/httpd/sessions
chmod 0700 /infra/httpd/keytabs /infra/httpd/sessions
chown www-data:www-data /infra/httpd/sessions
touch /infra/httpd/keytabs/https.localhost-test-bogus.keytab
chmod 0600 /infra/httpd/keytabs/https.localhost-test-bogus.keytab

echo "EXPECT success on Apache startup with mod_cuwebauth enabled"
/usr/sbin/service apache2 start

echo "EXPECT Apache to remain running for at least 30 seconds"
sleep 30
/usr/sbin/service apache2 status

echo "EXPECT success retrieving index from Apache"
curl -sI http://localhost/
curl -sI http://localhost/ |head -1 | tr -d '\r' | grep '200 OK$'

echo "EXPECT successful redirect to CUWA"
cat <<EOF > /etc/apache2/conf-enabled/test-secure.conf
<Location /secure-test>
    AuthName CORNELL
    AuthType all
    Require valid-user
</Location>
EOF
service apache2 restart
curl -sI http://localhost/secure-test/
curl -sI http://localhost/secure-test/ |head -1 | tr -d '\r' | grep '302 Found$'
curl -sI http://localhost/secure-test/ | grep '^Location: https://web..login.cornell.edu'
