FROM dtr.cucloud.net/cs/apache22

RUN \
  apt-get update && \
  apt-get install -y apache2-prefork-dev libkrb5-dev

COPY conf.patch /tmp
COPY cuwal-2.3.0.238.tar.gz /tmp
COPY build-script.sh /tmp
RUN chmod +x /tmp/build-script.sh

# docker run --rm -it -v /tmp:/root/tmp --entrypoint bash dtr.cucloud.net/cs/apache22
CMD ["/tmp/build-script.sh"]