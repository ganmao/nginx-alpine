FROM alpine:3.7

LABEL MAINTAINER_MAIL="zdl0812@163.com"
LABEL MAINTAINER_VERSION="v0.1.0-20190123"

ENV TIMEZONE="Asia/Shanghai"
ENV LUAJIT_LIB=/usr/lib/
ENV LUAJIT_INC=/usr/include/luajit-2.1

RUN addgroup -S nginx &&\
    adduser -D -S -h /var/cache/nginx -s /sbin/nologin -G nginx nginx &&\
    apk add --update --no-cache git openssh curl luajit-dev geoip-dev pcre-dev libxslt-dev gd-dev openssl-dev zlib-dev gcc make libc-dev linux-headers gnupg1 &&\
    rm -rf /var/cache/apk/*
    
RUN mkdir /opt && cd /opt &&\
    curl http://nginx.org/download/nginx-1.13.6.tar.gz -o nginx-1.13.6.tar.gz &&\
    tar -xf nginx-1.13.6.tar.gz &&\
    curl -k https://codeload.github.com/vozlt/nginx-module-vts/tar.gz/v0.1.18 -o nginx-module-vts-0.1.18.tar.gz &&\
    tar -xf nginx-module-vts-0.1.18.tar.gz &&\
    curl -k https://codeload.github.com/vozlt/nginx-module-sts/tar.gz/v0.1.1 -o nginx-module-sts-0.1.1.tar.gz &&\
    tar -xf nginx-module-sts-0.1.1.tar.gz &&\
    curl -k https://codeload.github.com/vozlt/nginx-module-stream-sts/tar.gz/v0.1.1 -o nginx-module-stream-sts-0.1.1.tar.gz &&\
    tar -xf nginx-module-stream-sts-0.1.1.tar.gz &&\
    curl -k https://codeload.github.com/openresty/lua-nginx-module/tar.gz/v0.10.13 -o lua-nginx-module-0.10.13.tar.gz &&\
    tar -xf lua-nginx-module-0.10.13.tar.gz &&\
    curl -k https://codeload.github.com/simplresty/ngx_devel_kit/tar.gz/v0.3.0 -o ngx_devel_kit-0.3.0.tar.gz &&\
    tar -xf ngx_devel_kit-0.3.0.tar.gz &&\
    curl -k https://people.freebsd.org/~osa/ngx_http_redis-0.3.9.tar.gz -o ngx_http_redis-0.3.9.tar.gz &&\
    tar -xf ngx_http_redis-0.3.9.tar.gz &&\
    curl -k https://codeload.github.com/openresty/redis2-nginx-module/tar.gz/v0.14 -o redis2-nginx-module-0.14.tar.gz &&\
    tar -xf redis2-nginx-module-0.14.tar.gz
    
RUN cd /opt &&\
    git config --global http.sslVerify false &&\
    git clone https://github.com/google/ngx_brotli.git &&\
    cd /opt/ngx_brotli && git submodule update --init
    
RUN cd /opt/nginx-1.13.6 &&\
    ./configure \
    --prefix=/usr/local/nginx \
    --sbin-path=/usr/local/nginx/sbin/nginx \
    --conf-path=/etc/nginx/nginx.conf \
    --error-log-path=/dev/stderr \
    --http-log-path=/dev/stdout \
    --user=nginx \
    --group=nginx \
    --error-log-path=/var/log/nginx/error.log \
    --http-log-path=/var/log/nginx/access.log \
    --pid-path=/var/run/nginx/nginx.pid \
    --lock-path=/var/lock/nginx.lock \
    --with-http_ssl_module \
    --with-http_realip_module \
    --with-http_addition_module \
    --with-http_sub_module \
    --with-http_dav_module \
    --with-http_flv_module \
    --with-http_mp4_module \
    --with-http_gunzip_module \
    --with-http_gzip_static_module \
    --with-http_random_index_module \
    --with-http_secure_link_module \
    --with-http_stub_status_module \
    --with-http_auth_request_module \
    --with-http_xslt_module=dynamic \
    --with-http_image_filter_module=dynamic \
    --with-http_geoip_module=dynamic \
    --with-threads \
    --with-stream \
    --with-stream_ssl_module \
    --with-stream_ssl_preread_module \
    --with-stream_realip_module \
    --with-stream_geoip_module=dynamic \
    --with-http_slice_module \
    --with-mail \
    --with-mail_ssl_module \
    --with-compat \
    --with-file-aio \
    --with-http_v2_module \
    --http-client-body-temp-path=/var/tmp/nginx/client \
    --http-proxy-temp-path=/var/tmp/nginx/proxy \
    --http-fastcgi-temp-path=/var/tmp/nginx/fastcgi \
    --http-uwsgi-temp-path=/var/tmp/nginx/uwsgi \
    --add-module=/opt/nginx-module-vts-0.1.18 \
    --add-module=/opt/nginx-module-sts-0.1.1 \
    --add-module=/opt/nginx-module-stream-sts-0.1.1 \
    --with-ld-opt="-Wl,-rpath,/usr/lib" \
    --add-module=/opt/ngx_brotli \
    --add-module=/opt/lua-nginx-module-0.10.13 \
    --add-module=/opt/ngx_devel_kit-0.3.0 \
    --add-module=/opt/ngx_http_redis-0.3.9 \
    --add-module=/opt/redis2-nginx-module-0.14 &&\
    make -j2 && make install
    
RUN mkdir -p /var/tmp/nginx/{client,fastcgi,proxy,uwsgi} &&\
    rm -rf /opt/nginx-1.13.6.tar.gz &&\
    rm -rf /opt/nginx-module-vts-0.1.18.tar.gz &&\
    rm -rf /opt/nginx-module-sts-0.1.1.tar.gz &&\
    rm -rf /opt/nginx-module-stream-sts-0.1.1.tar.gz &&\
    rm -rf /opt/ngx_devel_kit-0.3.0.tar.gz &&\
    rm -rf /opt/lua-nginx-module-0.10.13.tar.gz &&\
    rm -rf /opt/ngx_http_redis-0.3.9.tar.gz &&\
    rm -rf /opt/redis2-nginx-module-0.14.tar.gz &&\
    rm -rf /opt/ngx_brotli
    
COPY nginx.conf  /etc/nginx/nginx.conf
    
ENV PATH /usr/local/nginx/sbin:$PATH
EXPOSE 80
STOPSIGNAL SIGTERM
CMD ["/usr/local/nginx/sbin/nginx","-g","daemon off;"]
