# Nginx
## Nginx with headers
```
cd /usr/local/nginx/conf
vi nginx.conf
```
## Add the following line top of the file
```
load_module /usr/local/nginx/modules/ngx_http_headers_more_filter_module.so;
```
## Building docker image
```
docker build -t docker.io/sainath2804/nginx:1.25.3 .
```
## Publishing to docker
```
docker login docker.io -u sainath2804
docker push docker.io/sainath2804/nginx:1.25.3
```
