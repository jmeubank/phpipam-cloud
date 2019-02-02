FROM luzifer/alpine-nginx-php

# based in part on code from
# https://github.com/pierrecdn/phpipam/blob/0f337b91751c237fffc51d16923f379f36b5950e/Dockerfile

RUN apk add --no-cache iputils fping net-snmp-libs \
     php7-pdo_mysql php7-session php7-sockets php7-openssl php7-gmp php7-ldap php7-mcrypt php7-simplexml php7-json \
     php7-gettext php7-pcntl php7-mbstring php7-snmp php7-gd php7-pear php7-ctype

#ENV PHPIPAM_SOURCE https://github.com/phpipam/phpipam/
ENV WEB_REPO /var/www
ENV PHPIPAM_USE_LOCAL_SOURCE phpipam
ENV PHPIPAM_VERSION 1.3.2
ENV PHPMAILER_SOURCE https://github.com/PHPMailer/PHPMailer/
ENV PHPMAILER_VERSION 5.2.21
ENV PHPSAML_SOURCE https://github.com/onelogin/php-saml/
ENV PHPSAML_VERSION 2.10.6

# Copy phpipam sources to web dir
COPY ${PHPIPAM_USE_LOCAL_SOURCE}/ ${WEB_REPO}/

#        curl -fSL ${PHPIPAM_SOURCE}/archive/${PHPIPAM_VERSION}.tar.gz | tar -xzC ${WEB_REPO}/ --strip-components=1 ;
# Copy referenced submodules into the right directory
RUN apk add --no-cache --virtual .build_deps curl gettext && \
    mkdir -p -- ${WEB_REPO} && \
    curl -fSL ${PHPMAILER_SOURCE}/archive/v${PHPMAILER_VERSION}.tar.gz | tar -xzC ${WEB_REPO}/functions/PHPMailer/ --strip-components=1 && \
    curl -fSL ${PHPSAML_SOURCE}/archive/v${PHPSAML_VERSION}.tar.gz | tar -xzC ${WEB_REPO}/functions/php-saml/ --strip-components=1 && \
    mkdir -p /var/lib/mibs/ietf && \
    curl -fSL ftp://ftp.cisco.com/pub/mibs/v2/CISCO-SMI.my -o /var/lib/mibs/ietf/CISCO-SMI.txt && \
    curl -fSL ftp://ftp.cisco.com/pub/mibs/v2/CISCO-TC.my -o /var/lib/mibs/ietf/CISCO-TC.txt && \
    curl -fSL ftp://ftp.cisco.com/pub/mibs/v2/CISCO-VTP-MIB.my -o /var/lib/mibs/ietf/CISCO-VTP-MIB.txt && \
    curl -fSL ftp://ftp.cisco.com/pub/mibs/v2/MPLS-VPN-MIB.my -o /var/lib/mibs/ietf/MPLS-VPN-MIB.txt

#    sed -i 's/;include_path = \".:\/php\/includes\"/include_path = \".:\/usr\/share\/php7\"/' /etc/php7/php.ini
# Use system environment variables into config.php
RUN cp ${WEB_REPO}/config.dist.php ${WEB_REPO}/config.php && \
    chown nginx:www-data ${WEB_REPO}/app/admin/import-export/upload && \
    chown nginx:www-data ${WEB_REPO}/app/subnets/import-subnet/upload && \
    chown nginx:www-data ${WEB_REPO}/css/images/logo && \
    echo "include_path = \".:/usr/share/php7\"" >/etc/php7/conf.d/pear.ini && \
    { \
      echo '# as recommended if running nginx on read-only filesystem'; \
      echo 'server_names_hash_bucket_size 128;'; \
      echo; \
      echo 'server {'; \
      echo '# as recommended if running nginx on read-only filesystem'; \
      echo '    proxy_buffering         off;'; \
      echo '    client_body_buffer_size 10m;'; \
      echo '    client_max_body_size    10m;'; \
      echo '    keepalive_timeout       120;'; \
      echo '# as recommended if running nginx in Vagrant/Virtualbox'; \
      echo '    sendfile                off;'; \
      echo; \
      echo '    error_log /dev/stdout warn;'; \
      echo '    access_log /dev/stdout;'; \
      echo; \
      echo '    listen      80;'; \
      echo '    listen [::]:80 default ipv6only=on;'; \
      echo '    server_name _;'; \
      echo; \
      echo '    index index.php;'; \
      echo; \
      echo '# phpIPAM under nginx'; \
      echo '    root $WEB_REPO;'; \
      echo '    location / {'; \
      echo '        try_files $uri $uri/ /index.php;'; \
      echo '    }'; \
      echo '    location /api/ {'; \
      echo '        try_files $uri $uri/ /api/index.php;'; \
      echo '    }'; \
      echo '    location ~ \.php$ {'; \
      echo '        fastcgi_split_path_info ^(.+\.php)(/.+)$;'; \
      echo '        fastcgi_pass  unix:/tmp/php-fpm.sock;'; \
      echo '        include       fastcgi_params;'; \
      echo '        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;'; \
      echo '        fastcgi_param PATH_INFO $fastcgi_path_info;'; \
      echo '        fastcgi_param SCRIPT_NAME $fastcgi_script_name;'; \
      echo '        fastcgi_index index.php;'; \
      echo '        try_files      $uri $uri/ =404;'; \
      echo '    }'; \
      echo; \
      echo '# as recommended for security'; \
      echo '    location ~ /\. {'; \
      echo '        log_not_found off;'; \
      echo '        deny all;'; \
      echo '    }'; \
      echo '}'; \
    } | envsubst '$WEB_REPO' | tee /etc/nginx/conf.d/default.conf && \
    { \
      echo '[global]'; \
      echo 'error_log = /proc/self/fd/2'; \
      echo; \
      echo '[www]'; \
      echo '; if we send this to /proc/self/fd/1, it never appears'; \
      echo 'access.log = /proc/self/fd/2'; \
      echo '; Ensure worker stdout and stderr are sent to the main error log.'; \
      echo 'catch_workers_output = yes'; \
      echo; \
      echo '; Listen on a local socket since we are combining nginx and php in the same container for phpIPAM'; \
      echo 'listen = /tmp/php-fpm.sock'; \
      echo 'listen.owner = nginx'; \
      echo 'listen.group = www-data'; \
      echo '; Pass in database environment variables from outside.'; \
      echo 'env[MYSQL_ENV_MYSQL_HOST] = $MYSQL_ENV_MYSQL_HOST'; \
      echo 'env[MYSQL_ENV_MYSQL_USER] = $MYSQL_ENV_MYSQL_USER'; \
      echo 'env[MYSQL_ENV_MYSQL_PASSWORD] = $MYSQL_ENV_MYSQL_PASSWORD'; \
      echo 'env[MYSQL_ENV_MYSQL_PASSWORD_FILE] = $MYSQL_ENV_MYSQL_PASSWORD_FILE'; \
    } | tee /etc/php7/php-fpm.d/zz_phpipam.conf && \
    sed -i -e "s/\['host'\] = 'localhost'/\['host'\] = getenv(\"MYSQL_ENV_MYSQL_HOST\") ?: \"mysql\"/" \
     -e "s/\['user'\] = 'phpipam'/\['user'\] = getenv(\"MYSQL_ENV_MYSQL_USER\") ?: \"root\"/" \
     -e "s/\['pass'\] = 'phpipamadmin'/\['pass'\] = getenv(\"MYSQL_ENV_MYSQL_PASSWORD\")/" \
     -e "s/\['port'\] = 3306;/\['port'\] = 3306;\n\n\$password_file = getenv(\"MYSQL_ENV_MYSQL_PASSWORD_FILE\");\nif(file_exists(\$password_file))\n\$db\['pass'\] = preg_replace(\"\/\\\\s+\/\", \"\", file_get_contents(\$password_file));/" \
     ${WEB_REPO}/config.php && \
    apk del .build_deps

EXPOSE 80
