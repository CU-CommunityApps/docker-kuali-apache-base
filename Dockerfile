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
  gem uninstall -I concurrent-ruby && \
  gem install concurrent-ruby -v 1.1.10 && \
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
