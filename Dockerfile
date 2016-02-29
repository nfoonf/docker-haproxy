FROM alpine:latest
MAINTAINER Corey Butler

ENV HAPROXY_MAJOR 1.6
ENV HAPROXY_VERSION 1.6.2
ENV HAPROXY_MD5 d0ebd3d123191a8136e2e5eb8aaff039

RUN apk update && apk add libssl1.0 pcre lua5.3 lua5.3-dev && rm -f /var/cache/apk/* \
  && buildDeps='curl gcc libc-dev linux-headers pcre-dev openssl-dev make tar' \
	&& set -x \
	&& apk update && apk add $buildDeps && rm -f /var/cache/apk/* \
	&& curl -SL "http://www.haproxy.org/download/${HAPROXY_MAJOR}/src/haproxy-${HAPROXY_VERSION}.tar.gz" -o haproxy.tar.gz \
	&& echo "${HAPROXY_MD5}  haproxy.tar.gz" | md5sum -c \
	&& mkdir -p /usr/src/haproxy \
	&& tar -xzf haproxy.tar.gz -C /usr/src/haproxy --strip-components=1 \
	&& rm haproxy.tar.gz \
	&& make -C /usr/src/haproxy \
    DEBUG=-ggdb \
    CFLAGS=-O0 \
		TARGET=linux2628 \
    USE_LUA=yes \
    LUA_LIB=/opt/lua53/lib/ \
    LUA_INC=/opt/lua53/include/ \
		USE_PCRE=1 PCREDIR= \
		USE_OPENSSL=1 \
		USE_ZLIB=1 \
    LDFLAGS=-ldl \
		all \
		install-bin \
	&& mkdir -p /usr/local/etc/haproxy \
	&& cp -R /usr/src/haproxy/examples/errorfiles /usr/local/etc/haproxy/errors \
	&& rm -rf /usr/src/haproxy \
	&& apk del $buildDeps

# ADD ./errors /etc/haproxy/errors
ADD ./haproxy.cfg /usr/local/etc/haproxy/haproxy.cfg

CMD ["haproxy", "-f", "/usr/local/etc/haproxy/haproxy.cfg"]
