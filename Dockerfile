FROM debian:bookworm

# Install build dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libpcre3-dev \
    zlib1g-dev \
    libssl-dev \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Set Nginx and headers-more versions
ENV NGINX_VERSION=1.25.3
ENV HEADERS_MORE_VERSION=0.37

# Download and extract Nginx and headers-more module
RUN wget https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz && \
    tar -zxvf nginx-${NGINX_VERSION}.tar.gz && \
    wget https://github.com/openresty/headers-more-nginx-module/archive/v${HEADERS_MORE_VERSION}.tar.gz && \
    tar -zxvf v${HEADERS_MORE_VERSION}.tar.gz

# Build Nginx with headers-more module and provided configure arguments
RUN cd nginx-${NGINX_VERSION} && \
    ./configure --prefix=/etc/nginx \
                --sbin-path=/usr/sbin/nginx \
                --modules-path=/usr/lib/nginx/modules \
                --conf-path=/etc/nginx/nginx.conf \
                --error-log-path=/var/log/nginx/error.log \
                --http-log-path=/var/log/nginx/access.log \
                --pid-path=/var/run/nginx.pid \
                --lock-path=/var/run/nginx.lock \
                --http-client-body-temp-path=/var/cache/nginx/client_temp \
                --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
                --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
                --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
                --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
                --user=nginx \
                --group=nginx \
                --with-compat \
                --with-file-aio \
                --with-threads \
                --with-http_addition_module \
                --with-http_auth_request_module \
                --with-http_dav_module \
                --with-http_flv_module \
                --with-http_gunzip_module \
                --with-http_gzip_static_module \
                --with-http_mp4_module \
                --with-http_random_index_module \
                --with-http_realip_module \
                --with-http_secure_link_module \
                --with-http_slice_module \
                --with-http_ssl_module \
                --with-http_stub_status_module \
                --with-http_sub_module \
                --with-http_v2_module \
                --with-http_v3_module \
                --with-mail \
                --with-mail_ssl_module \
                --with-stream \
                --with-stream_realip_module \
                --with-stream_ssl_module \
                --with-stream_ssl_preread_module \
                --with-cc-opt='-g -O2 -ffile-prefix-map=/data/builder/debuild/nginx-1.25.3/debian/debuild-base/nginx-1.25.3=. -fstack-protector-strong -Wformat -Werror=format-security -Wp,-D_FORTIFY_SOURCE=2 -fPIC' \
                --with-ld-opt='-Wl,-z,relro -Wl,-z,now -Wl,--as-needed -pie' \
                --add-dynamic-module=/headers-more-nginx-module-${HEADERS_MORE_VERSION} && \
    make && make install

# Create nginx user and group
RUN groupadd -r nginx && useradd -r -g nginx -s /sbin/nologin -M nginx

# Set up runtime directories and copy files
RUN mkdir -p /etc/nginx /var/log/nginx /var/cache/nginx/client_temp /var/cache/nginx/proxy_temp /var/cache/nginx/fastcgi_temp /var/cache/nginx/uwsgi_temp /var/cache/nginx/scgi_temp /var/run /usr/lib/nginx/modules && \
    cp -r /etc/nginx/conf/* /etc/nginx/ 2>/dev/null || true && \
    cp /nginx-${NGINX_VERSION}/objs/ngx_http_headers_more_filter_module.so /usr/lib/nginx/modules/ && \
    chown -R nginx:nginx /var/cache/nginx /var/log/nginx /etc/nginx /var/run

# Clean up to reduce image size
RUN rm -rf /nginx-${NGINX_VERSION} /v${HEADERS_MORE_VERSION}.tar.gz /headers-more-nginx-module-${HEADERS_MORE_VERSION} /nginx-${NGINX_VERSION}.tar.gz && \
    apt-get purge -y build-essential wget && apt-get autoremove -y && apt-get clean

# Expose port


# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
