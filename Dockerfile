FROM debian:latest

MAINTAINER timegrid@pega.sh

RUN apt-get update && \
    apt-get -y --no-install-recommends install \
    apt-utils \
    ca-certificates \
    curl

RUN gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4

RUN curl -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/1.10/gosu-$(dpkg --print-architecture)" \
    && curl -o /usr/local/bin/gosu.asc -SL "https://github.com/tianon/gosu/releases/download/1.10/gosu-$(dpkg --print-architecture).asc" \
    && gpg --verify /usr/local/bin/gosu.asc \
    && rm /usr/local/bin/gosu.asc \
    && chmod +x /usr/local/bin/gosu

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

RUN cp .env.example .env && \
    mkdir /tmp/timegrid_storage

RUN sed -i -e 's/^DB_HOST.*/DB_HOST="127.0.0.1"/g' -e 's/^DB_DATABASE.*/DB_DATABASE="timegrid_dev"/g' -e 's/^DB_USERNAME.*/DB_USERNAME="timegrid_dev"/g' -e 's/^DB_PASSWORD.*/DB_PASSWORD="tgpass"/g' -e 's/^STORAGE_PATH=.*/STORAGE_PATH="\/tmp\/timegrid_storage"/g' .env

RUN /etc/init.d/mysql start && \
    php artisan migrate --seed --database=testing && \
    php artisan key:generate && \
    php artisan migrate && \
    php artisan db:seed && \
    php artisan geoip:update && \
    /etc/init.d/mysql stop

CMD /etc/init.d/mysql start && \
    php artisan serve --host 0.0.0.0

COPY entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chmod 755 /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

EXPOSE 8000