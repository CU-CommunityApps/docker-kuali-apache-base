FROM ubuntu:20.04

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
    clamav-daemon \
    libssl-dev \
    openssh-client && \
  rm -rf /var/lib/apt/lists/*


RUN echo "gem: --no-ri --no-rdoc" > ~/.gemrc && \
  gem install json_pure && \
  gem install puppet && \
  gem install librarian-puppet && \
  gem install hiera-eyaml


# Set environment variables.
ENV HOME /root

# Define working directory.
WORKDIR /root

# Install apache23
RUN \
  apt-get update && \
  apt-get install -y apache2 && \
  apt-get clean

# copy files needed for CUWA
COPY conf/cuwebauth.load /etc/apache2/mods-available/cuwebauth.load
#COPY conf/apache2.conf /etc/apache2/apache2.conf
COPY build-cuwa/mod_cuwebauth-2.3.1.38-ubuntu20.4-apache2.4.so /usr/lib/apache2/modules/mod_cuwebauth.so

#COPY lib/libcom_err.so.3 /lib/libcom_err.so.3
#COPY lib/libcrypto.so.1.0.0 /lib/libcrypto.so.1.0.0
#COPY lib/libgssapi_krb5.so.2 /lib/libgssapi_krb5.so.2
#COPY lib/libk5crypto.so.3 /lib/libk5crypto.so.3
#COPY lib/libkrb5.so.3 /lib/libkrb5.so.3
#COPY lib/libkrb5support.so.0 /lib/libkrb5support.so.0
#COPY lib/libssl.so.1.0.0 /lib/libssl.so.1.0.0

#RUN ln -s /lib/libssl.so.1.0.0 /lib/libssl.so.10
#RUN ln -s /lib/libcrypto.so.1.0.0 /lib/libcrypto.so.10

# we will use for data and what not
RUN mkdir /infra
RUN mkdir /etc/apache2/conf.d

# turn on mods
RUN \
  a2enmod ssl \
  cuwebauth \
  rewrite \
  proxy \
  proxy_http

EXPOSE 80
EXPOSE 443

CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
