# SET BASE IMAGE
FROM	debian:buster

LABEL	"webserver"="jna"

# DOWNLOAD MIDDLEWERE AND SERVICES
RUN		apt-get update && apt-get -y install \
		nginx \
		openssl \
		php7.3-fpm \
		mariadb-server \
		php-mysql \
		wget \
		vim

# Nginx DEFAULT FILE COPY
COPY	./srcs/default ./etc/nginx/sites-available/default

# SSL CA CREATE
RUN		openssl req -newkey rsa:4096 -days 365 -nodes -x509 -subj "/C=KR/ST=Seoul/L=Seoul/O=42Seoul/CN=jna" -keyout /etc/ssl/private/localhost.dev.key -out /etc/ssl/certs/localhost.dev.crt

# wordpress DOWNLOAD
RUN		wget https://wordpress.org/latest.tar.gz && \
		tar -xvf /latest.tar.gz && \
		mv /wordpress/ /var/www/html/ && \
		chown -R www-data:www-data /var/www/html/wordpress

COPY	./srcs/wp-config.php ./var/www/html/wordpress/

# phpmyadmin DOWNLOAD
RUN 	wget https://files.phpmyadmin.net/phpMyAdmin/5.0.2/phpMyAdmin-5.0.2-all-languages.tar.gz && \
		tar -xvf phpMyAdmin-5.0.2-all-languages.tar.gz && \
		mv phpMyAdmin-5.0.2-all-languages phpmyadmin && \
		mv phpmyadmin /var/www/html/

COPY	./srcs/config.inc.php ./var/www/html/phpmyadmin/

# SET PORT
EXPOSE	80 443

# DB RUN
CMD		service mysql start; \
		service php7.3-fpm start; \
		echo "CREATE DATABASE IF NOT EXISTS wordpress;" | mysql -u root --skip-password; \
		echo "CREATE USER IF NOT EXISTS 'jna'@'localhost' IDENTIFIED BY 'jna';" | mysql -u root --skip-password; \
		echo "GRANT ALL PRIVILEGES ON wordpress.* TO 'jna'@'localhost' WITH GRANT OPTION;" | mysql -u root --skip-password; \
		nginx -g "daemon off;"
