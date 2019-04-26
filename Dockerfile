FROM ubuntu:14.04

# Install.
RUN \
  apt-get update && apt-get install --no-install-recommends -y \
    build-essential \
    curl \
    git \
    unzip \
    vim \
    wget \
    ruby \
    ruby-dev \
    clamav-daemon \
    openssh-client && \
  rm -rf /var/lib/apt/lists/*


RUN \
  apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y apache2 && \
  apt-get clean

#copy files needed for CUWA
COPY conf/cuwebauth.load /etc/apache2/mods-available/cuwebauth.load
COPY lib/mod_cuwebauth.so /usr/lib/apache2/modules/mod_cuwebauth.so

# we will use for data and what not
RUN mkdir /infra/

# turn on mods
RUN \
  a2enmod ssl \
  cuwebauth \
  rewrite \
  proxy \
  proxy_http

# Add test suite to image
COPY bin/run-tests.sh /root/test-suite/

EXPOSE 80
EXPOSE 443

CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
