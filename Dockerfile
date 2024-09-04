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
    ruby-dev \
    clamav-daemon \
    libssl-dev \
    openssh-client && \
  rm -rf /var/lib/apt/lists/*


RUN echo "gem: --no-ri --no-rdoc" > ~/.gemrc && \
  gem install json_pure && \
  gem install thor -v 1.2.2 && \
  gem install minitar -v 0.12 && \
  gem install faraday-net_http -v 3.0.2 && \
  gem install faraday -v 2.8.1 && \
  gem install puppet -v 7.24.0 && \
  gem install librarian-puppet && \
  gem uninstall -I concurrent-ruby && \
  gem install concurrent-ruby -v 1.1.10 && \
  gem install highline -v 2.1.0 && \
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

# we will use for data and what not
RUN mkdir /infra
RUN mkdir /etc/apache2/conf.d

# turn on mods
RUN \
  a2enmod ssl \
  rewrite \
  proxy \
  proxy_http

EXPOSE 80
EXPOSE 443

CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
