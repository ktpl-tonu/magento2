FROM ubuntu:16.04

MAINTAINER Tonu V

ENV DEBIAN_FRONTEND=noninteractive
ARG branch
RUN apt-get update && apt-get install -y vim software-properties-common python-software-properties apt-transport-https curl zip language-pack-en-base net-tools nginx git \
#    && apt-get update \
#    && locale-gen en_US.UTF-8 \
#    && export LANG=en_US.UTF-8 \
#    && LC_ALL=en_US.UTF-8 \
#    && add-apt-repository -y ppa:ondrej/php \
#    && apt-get update \
#    && apt-get install -y php7.0 php7.0-fpm php7.0-cli php7.0-common php7.0-gd php7.0-mysql php7.0-mcrypt php7.0-curl php7.0-intl php7.0-xsl php7.0-mbstring php7.0-zip php7.0-bcmath php7.0-iconv php7.0-soap \
##    && apt-get remove -y --purge software-properties-common python-software-properties \
#    && echo "daemon off;" >> /etc/nginx/nginx.conf \
#    && apt-get clean \
#    && useradd -m -d /var/www/html/magento -u 1001 magento \
#    && usermod -G magento www-data \
#    && curl -sS https://getcomposer.org/installer | php -- \
#    --install-dir=/usr/bin \
#    --filename=composer \
    && mkdir -p /var/www/html/magento/webroot \
    && cd /var/www/html/magento/webroot \
    && git clone -b $branch https://github.com/ktpl-tonu/magento2.git .

WORKDIR /var/www/html/magento/webroot

ADD files/php-cli.ini /etc/php/7.0/cli/php.ini
ADD files/docker-entrypoint.sh  /docker-entrypoint.sh
ADD files/php-fpm.conf /etc/php/7.0/fpm/php-fpm.conf
ADD files/www.conf /etc/php/7.0/fpm/pool.d/www.conf
ADD files/php-fpm.ini /etc/php/7.0/fpm/php.ini
ADD files/default /etc/nginx/sites-available/default
ADD files/magento-nginx.conf /etc/nginx/sites-available/magento-nginx.conf

#COPY /mnt/data/env.php .
#COPY /mnt/data/composer.json ./composer.json
#COPY /mnt/data/config.php ./app/config.php
#COPY /mnt/data/auth.json ./auth.json


RUN mkdir /run/php \
    && chown -R magento:magento /var/www/html/magento \
    && su magento \
#    && composer install \
    && php bin/magento setup:upgrade && php bin/magento deploy:mode:set production \
    && rm -rf update LICENSE.txt LICENSE_AFL.txt Gruntfile.js.sample COPYING.txt CHANGELOG.md app/code app/design dev index.php grunt-config.json.sample lib phpserver php.ini.sample package.json.sample nginx.conf.sample var/* \
    && exit \
    && chown -R magento:magento /var/www/html/magento/webroot/var \
    && chmod -R 775 /var/www/html/magento/webroot/var

EXPOSE 22 9000 80

ENTRYPOINT ["/docker-entrypoint.sh"]

