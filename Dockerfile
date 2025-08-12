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

# Build Nginx with headers-more module
RUN cd nginx-${NGINX_VERSION} && \
    ./configure --with-compat \
                --add-dynamic-module=/headers-more-nginx-module-${HEADERS_MORE_VERSION} \
                --with-http_ssl_module && \
    make && make install

# Copy Nginx binary and set up runtime
RUN cp /usr/local/nginx/sbin/nginx /usr/sbin/nginx && \
    mkdir -p /etc/nginx /var/log/nginx /var/cache/nginx && \
    cp -r /usr/local/nginx/conf/* /etc/nginx/

# Clean up to reduce image size
RUN rm -rf /nginx-${NGINX_VERSION} /v${HEADERS_MORE_VERSION}.tar.gz /headers-more-nginx-module-${HEADERS_MORE_VERSION} /nginx-${NGINX_VERSION}.tar.gz && \
    apt-get purge -y build-essential wget && apt-get autoremove -y && apt-get clean

# Expose port
EXPOSE 4455

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
