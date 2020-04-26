FROM lsiobase/nginx:3.11

# set version label
ARG BUILD_DATE
ARG VERSION
ARG BOOKSTACK_RELEASE
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="homerr"

# package versions
ARG BOOKSTACK_RELEASE

RUN apk --no-cache add curl && \
 		msttcorefonts-installer && \
 		fontconfig && \
 		update-ms-fonts && \
    	fc-cache -f && \
 		memcached && \
 		netcat-openbsd && \
 		php7-ctype && \
 		php7-curl && \
 		php7-dom && \
 		php7-gd && \
 		php7-ldap && \
 		php7-mbstring && \
 		php7-memcached && \
 		php7-mysqlnd && \
 		php7-openssl && \
 		php7-pdo_mysql && \
 		php7-phar && \
 		php7-simplexml && \
 		php7-tidy && \
 		php7-tokenizer && \
 		qt5-qtbase && \
 		xvfb && \
 		dbus && \
 		tar && \
 		ttf-freefont && \
 		wkhtmltopdf && \ 		
 echo "**** tidy bug fix ****" && \
 curl -s \
 		http://dl-cdn.alpinelinux.org/alpine/v3.7/community/x86_64/tidyhtml-libs-5.4.0-r0.apk | \
 		tar xfz - -C / && \
 rm -f /usr/lib/libtidy.so.5.6.0 && \
 echo "**** configure php-fpm ****" && \
 sed -i 's/;clear_env = no/clear_env = no/g' /etc/php7/php-fpm.d/www.conf && \
 echo "env[PATH] = /usr/local/bin:/usr/bin:/bin" >> /etc/php7/php-fpm.conf && \
 echo "**** fetch bookstack ****" && \
 mkdir -p\
 		/var/www/html && \
 if [ -z ${BOOKSTACK_RELEASE+x} ]; then \
 		BOOKSTACK_RELEASE=$(curl -sX GET "https://api.github.com/repos/bookstackapp/bookstack/releases/latest" \
 		| awk '/tag_name/{print $4;exit}' FS='[""]'); \
 fi && \
 curl -o \
 /tmp/bookstack.tar.gz -L \
 		"https://github.com/BookStackApp/BookStack/archive/${BOOKSTACK_RELEASE}.tar.gz" && \
 tar xf \
 /tmp/bookstack.tar.gz -C \
 		/var/www/html/ --strip-components=1 && \
 echo "**** install  composer ****" && \
 cd /tmp && \
 curl -sS https://getcomposer.org/installer | php && \
 mv /tmp/composer.phar /usr/local/bin/composer && \
 echo "**** install composer dependencies ****" && \
 composer install -d /var/www/html/ && \
 echo @edge http://mirrors.ustc.edu.cn/alpine/edge/testing >> /etc/apk/repositories && \
 apk add wqy-zenhei@edge && \
 apk add wqy-zenhei --update-cache --repository http://mirrors.ustc.edu.cn/alpine/edge/testing --allow-untrusted && \
 apk add --update font-adobe-100dpi ttf-dejavu fontconfig && \
 echo "**** cleanup ****" && \
 rm -rf \
	/root/.composer \
	/tmp/*

# copy local files
COPY root/ /

# ports and volumes
VOLUME /config
