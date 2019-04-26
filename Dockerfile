FROM ubuntu:14.04


# Install base
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


RUN rm /etc/localtime
RUN ln -s /usr/share/zoneinfo/America/New_York /etc/localtime


RUN echo "gem: --no-ri --no-rdoc" > ~/.gemrc && \
  gem install json_pure -v 1.8.1 && \ 
  gem install puppet -v 3.7.5 && \
  gem install librarian-puppet -v 2.1.0 && \
  gem install hiera-eyaml -v 2.1.0


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
COPY conf/apache2.conf /etc/apache2/apache2.conf
COPY lib/libcom_err.so.3 /lib/libcom_err.so.3
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

EXPOSE 80
EXPOSE 443

CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
