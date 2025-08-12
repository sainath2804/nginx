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
