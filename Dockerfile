FROM debian:latest

MAINTAINER timegrid@pega.sh

RUN apt-get update && \
    apt-get install apt-utils -y

RUN echo 'mysql-server mysql-server/root_password password r00t' | debconf-set-selections && \
    echo 'mysql-server mysql-server/root_password_again password r00t'| debconf-set-selections && \
    apt-get install mysql-server -y && \
    /etc/init.d/mysql stop

RUN apt-get install php5 php5-mysql git wget curl php5-curl php5-intl phpunit vim -y && \
    /etc/init.d/mysql start && \
    echo "CREATE DATABASE timegrid_dev CHARACTER SET utf8 COLLATE utf8_general_ci; GRANT ALL ON timegrid_dev.* TO 'timegrid_dev'@localhost IDENTIFIED BY 'tgpass';" | mysql -pr00t && \
    echo "CREATE DATABASE testing_timegrid CHARACTER SET utf8 COLLATE utf8_general_ci; GRANT ALL ON testing_timegrid.* TO 'testing_timegrid'@localhost IDENTIFIED BY 'testing_timegrid';" | mysql -pr00t && \
    /etc/init.d/mysql stop

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

WORKDIR /var/www

RUN git clone https://github.com/timegridio/timegrid

WORKDIR /var/www/timegrid

RUN composer install

RUN cp .env.example .env && mkdir /tmp/timegrid_storage

RUN sed -i -e 's/^DB_HOST.*/DB_HOST="127.0.0.1"/g' -e 's/^DB_DATABASE.*/DB_DATABASE="timegrid_dev"/g' -e 's/^DB_USERNAME.*/DB_USERNAME="timegrid_dev"/g' -e 's/^DB_PASSWORD.*/DB_PASSWORD="tgpass"/g' -e 's/^STORAGE_PATH=.*/STORAGE_PATH="\/tmp\/timegrid_storage"/g' .env \
    && echo "* * * * * php /var/www/timegrid/artisan schedule:run >> /dev/null 2>&1" >> /etc/crontab

RUN /etc/init.d/mysql start && \
    php artisan migrate --seed --database=testing && \
    php artisan key:generate && \
    php artisan migrate && \
    php artisan db:seed && \
    php artisan geoip:update && \
    /etc/init.d/mysql stop

CMD /etc/init.d/mysql start && \
    php artisan serve --host 0.0.0.0

EXPOSE 8000