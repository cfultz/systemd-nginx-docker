# CentOS 7 with nginx and systemd support

This image contains the centos/systemd modified with nginx installed. A custom nginx.conf has been added that points to the host's `/var/www` directory instead of the default nginx location. 

This image contains a health check that wget's localhost. A simple `index.html` needs to be created on the host in `/var/www` for it to pass initially. Once you have your website files in `/var/www`, the check will pass normally.

### Dockerfile

```
FROM centos/systemd

MAINTAINER "Caleb Fultz" caleb@fultz.dev

RUN yum -y install epel-release; yum update; yum -y upgrade; yum -y install nginx wget; yum clean all; systemctl enable nginx.service

EXPOSE 80
EXPOSE 443

COPY nginx.conf /etc/nginx/nginx.conf

CMD ["/usr/sbin/init"]

HEALTHCHECK CMD wget -q --spider localhost

```


### docker-compose.yml
```
ngxsysd:

  command:
    - /usr/sbin/init

  container_name: ngxsysd

  environment:
    - PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
    - container=docker

  hostname: ngxsysd

  image: cfultz/c7sysd:ngxsysd

  ipc: private

  log_driver: json-file

  labels:
    - Maintainer="Caleb Fultz <caleb@fultz.dev>"

  ports:
    - 443:443/tcp
    - 80:80/tcp

  privileged: true

  security_opt:
    - label=disable

  volumes:
    - /sys/fs/cgroup:/sys/fs/cgroup:ro
    - /var/www:/var/www

  restart: unless-stopped
```

### nginx.conf

```
# For more information on configuration, see:
#   * Official English Documentation: http://nginx.org/en/docs/
#   * Official Russian Documentation: http://nginx.org/ru/docs/

user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;

# Load dynamic modules. See /usr/share/doc/nginx/README.dynamic.
include /usr/share/nginx/modules/*.conf;

events {
    worker_connections 1024;
}

http {
    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile            on;
    tcp_nopush          on;
    tcp_nodelay         on;
    keepalive_timeout   65;
    types_hash_max_size 2048;

    include             /etc/nginx/mime.types;
    default_type        application/octet-stream;

    # Load modular configuration files from the /etc/nginx/conf.d directory.
    # See http://nginx.org/en/docs/ngx_core_module.html#include
    # for more information.
    include /etc/nginx/conf.d/*.conf;

    server {
        listen       80 default_server;
        listen       [::]:80 default_server;
        server_name  _;
        # change this if you'd like to place your files somewhere else
        root         /var/www;
        # Load configuration files for the default server block.
        include /etc/nginx/default.d/*.conf;

        location / {
        }

        error_page 404 /404.html;
        location = /404.html {
        }

        error_page 500 502 503 504 /50x.html;
        location = /50x.html {
        }
    }

# Settings for a TLS enabled server.
#
#    server {
#        listen       443 ssl http2 default_server;
#        listen       [::]:443 ssl http2 default_server;
#        server_name  _;
#        root         /var/www;
#
#        ssl_certificate "/etc/pki/nginx/server.crt";
#        ssl_certificate_key "/etc/pki/nginx/private/server.key";
#        ssl_session_cache shared:SSL:1m;
#        ssl_session_timeout  10m;
#        ssl_ciphers HIGH:!aNULL:!MD5;
#        ssl_prefer_server_ciphers on;
#
#        # Load configuration files for the default server block.
#        include /etc/nginx/default.d/*.conf;
#
#        location / {
#        }
#
#        error_page 404 /404.html;
#        location = /404.html {
#        }
#
#        error_page 500 502 503 504 /50x.html;
#        location = /50x.html {
#        }
#    }

}
```
