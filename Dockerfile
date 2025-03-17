FROM ubuntu:24.10

ENV TZ=America/New_York
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install base
RUN \
  apt-get update && apt-get install --no-install-recommends -y \
    build-essential \
    curl \
    git \
    unzip \
    vim \
    less \
    wget \
    ruby \
    ruby-dev \
    libssl-dev \
    openssh-client && \
  rm -rf /var/lib/apt/lists/*

RUN echo "gem: --no-ri --no-rdoc" > ~/.gemrc && \
  gem install puppet && \
  gem install librarian-puppet

# Set environment variables.
ENV HOME /root

# Define working directory.
WORKDIR /root

# Install apache23
RUN \
  apt-get update && \
  apt-get install -y apache2 && \
  apt-get clean

# we will use for data and what not
RUN mkdir /infra
RUN mkdir /etc/apache2/conf.d

# turn on mods
RUN \
  a2enmod ssl \
  rewrite \
  proxy \
  proxy_http

# Download and build OpenSSL
RUN \
  wget https://www.openssl.org/source/openssl-3.4.1.tar.gz && \
  tar -xzf openssl-3.4.1.tar.gz && \
  cd openssl-3.4.1 && \
  ./config && \
  make && \
  make install && \
  cd .. && \
  rm -rf openssl-3.4.1 openssl-3.4.1.tar.gz

# Download and build OpenSSH
RUN \
  wget https://cdn.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-9.9p2.tar.gz && \
  tar -xzf openssh-9.9p2.tar.gz && \
  cd openssh-9.9p2 && \
  ./configure && \
  make && \
  make install && \
  cd .. && \
  rm -rf openssh-9.9p2 openssh-9.9p2.tar.gz

# Download and build OpenSAML
RUN \
  wget https://shibboleth.net/downloads/c++-opensaml/latest/opensaml-3.3.1.tar.gz && \
  tar -xzf opensaml-3.3.1.tar.gz && \
  cd opensaml-3.3.1 && \
  ./configure && \
  make && \
  make install && \
  cd .. && \
  rm -rf opensaml-3.3.1 opensaml-3.3.1.tar.gz

EXPOSE 80
EXPOSE 443

CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
