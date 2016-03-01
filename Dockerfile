FROM ayen/ubuntu-sshd
MAINTAINER Ayen Ling <ling@ayen.cc>
ENV AYEN_VERSION 20160229-1238
RUN apt-get update && apt-get install build-essential libpcre3-dev  libghc-zlib-dev  libssl-dev cmake  libncurses5-dev bison libxml2 libxml2-dev  libjpeg-dev libpng12-dev libfreetype6-dev  libssl-dev libcurl4-openssl-dev libmhash-dev libmcrypt-dev  libtool patch bzip2 gzip libbz2-dev libxslt1-dev autoconf libevent-dev -y
RUN mkdir -p /opt/src
WORKDIR /opt/src
RUN wget http://mirror.bit.edu.cn/apache//httpd/httpd-2.4.18.tar.gz
RUN wget http://mirrors.hust.edu.cn/apache//apr/apr-1.5.2.tar.gz
RUN wget http://mirrors.hust.edu.cn/apache//apr/apr-util-1.5.4.tar.gz
RUN wget http://mirrors.hust.edu.cn/apache//apr/apr-iconv-1.2.1.tar.gz
RUN wget http://dev.mysql.com/get/Downloads/MySQL-5.6/mysql-5.6.28.tar.gz
RUN wget http://cn2.php.net/distributions/php-5.6.18.tar.gz
RUN wget http://downloads.sourceforge.net/mcrypt/libmcrypt-2.5.8.tar.gz
RUN wget http://downloads.sourceforge.net/mcrypt/mcrypt-2.6.8.tar.gz
RUN wget http://downloads.sourceforge.net/mhash/mhash-0.9.9.9.tar.gz
RUN wget http://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.14.tar.gz
RUN tar zxvf apr-1.5.2.tar.gz
RUN tar zxvf apr-util-1.5.4.tar.gz
RUN tar zxvf apr-iconv-1.2.1.tar.gz
RUN tar zxvf httpd-2.4.18.tar.gz
RUN mv apr-1.5.2 httpd-2.4.18/srclib/apr
RUN mv apr-util-1.5.4 httpd-2.4.18/srclib/apr-util
RUN mv apr-iconv-1.2.1 httpd-2.4.18/srclib/apr-iconv
WORKDIR httpd-2.4.18
RUN ./configure --prefix=/usr/local/apache --with-included-apr --enable-so --enable-deflate=shared --enable-expires=shared --enable-ssl=shared --enable-headers=shared --enable-rewrite=shared --enable-static-support --with-mpm=prefork
RUN make
RUN make install
RUN ln -s /usr/local/apache/bin/apachectl /etc/init.d/httpd
RUN chmod 755 /etc/init.d/httpd
RUN update-rc.d httpd defaults
RUN ln -s /usr/local/apache/conf  /etc/httpd
RUN ln -sf /usr/local/apache/bin/httpd  /usr/sbin/httpd
RUN ln -sf /usr/local/apache/bin/apachectl  /usr/sbin/apachectl
RUN ln -s /usr/local/apache/logs  /var/log/httpd
RUN groupadd apache
RUN useradd -g apache -s /usr/sbin/nologin apache
RUN chown -R apache:apache /usr/local/apache
RUN cp /etc/httpd/httpd.conf /etc/httpd/httpd.conf.back-ayen
RUN sed -i 's/#ServerName www.example.com:80/ServerName 0.0.0.0:80/g' /etc/httpd/httpd.conf
RUN sed -i 's/ServerAdmin you@example.com/ServerAdmin ling@ayen.cc/g' /etc/httpd/httpd.conf
RUN sed -i 's/User daemon/User apache/' /etc/httpd/httpd.conf
RUN sed -i 's/Group daemon/Group apache/' /etc/httpd/httpd.conf
RUN mkdir -p /data/www/apache/default
RUN mv /usr/local/apache/htdocs/index.html /data/www/apache/default
RUN mv /usr/local/apache/cgi-bin /data/www/apache/cgi-bin
RUN chown -R apache:apache /data/www/apache
RUN sed -i 's;/usr/local/apache/htdocs;/data/www/apache/default;g' /etc/httpd/httpd.conf
RUN sed -i 's;/usr/local/apache/cgi-bin;/data/www/apache/cgi-bin;g' /etc/httpd/httpd.conf
#PHP
WORKDIR /opt/src
RUN tar zxvf libmcrypt-2.5.8.tar.gz
WORKDIR libmcrypt-2.5.8
RUN ./configure --prefix=/usr
RUN make && make install
WORKDIR /opt/src
RUN tar zxvf mhash-0.9.9.9.tar.gz
WORKDIR mhash-0.9.9.9
RUN ./configure --prefix=/usr
RUN  make && make install
WORKDIR /opt/src
RUN /sbin/ldconfig
RUN tar zxvf mcrypt-2.6.8.tar.gz
WORKDIR mcrypt-2.6.8
RUN ./configure
RUN make && make install
WORKDIR /opt/src
RUN tar zxvf libiconv-1.14.tar.gz
WORKDIR libiconv-1.14
RUN ./configure --prefix=/usr/local/libiconv
RUN sed -i '698d' /opt/src/libiconv-1.14/srclib/stdio.in.h
RUN make && make install
WORKDIR /opt/src
RUN tar zxvf php-5.6.18.tar.gz
WORKDIR php-5.6.18
RUN ./configure --prefix=/usr/local/php --with-apxs2=/usr/local/apache/bin/apxs --with-config-file-path=/etc --with-config-file-scan-dir=/etc/php.d --with-bz2 --with-gettext --with-mhash --with-mcrypt --with-iconv=/usr/local/libiconv --with-curl --with-gd --with-jpeg-dir --with-png-dir --with-freetype-dir --with-jpeg-dir=/usr --with-freetype-dir=/usr --with-kerberos --with-openssl --with-mcrypt=/usr/local/lib --with-mhash --with-mysql=mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-pcre-regex --with-pear --with-png-dir=/usr --with-xsl --with-zlib --with-zlib-dir=/usr --with-iconv --enable-bcmath --enable-calendar --enable-exif --enable-ftp --enable-gd-native-ttf --enable-soap --enable-sockets --enable-mbstring --enable-zip --enable-wddx --enable-posix --enable-pcntl --enable-maintainer-zts
RUN make && make install
RUN libtool --finish /opt/src/php-5.6.18/libs
RUN cp php.ini-development /etc/php.ini
RUN sed -i 's/;date.timezone =/date.timezone = PRC/' /etc/php.ini
RUN echo 'AddType application/x-httpd-php .php' >> /etc/httpd/httpd.conf
RUN echo 'PhpIniDir /etc' >> /etc/httpd/httpd.conf
RUN sed -i 's/index.html/index.html index.php/' /etc/httpd/httpd.conf
copy files/info.php /usr/local/apache/htdocs/info.php
RUN echo 'export PATH=$PATH:/usr/local/php/bin' >> ~/.bashrc
RUN echo 'source ~/.bashrc'
#MYSQL
WORKDIR /opt/src
RUN mkdir -pv /data/mysql
RUN groupadd mysql
RUN useradd -g mysql -s /usr/sbin/nologin mysql
RUN tar zxvf mysql-5.6.28.tar.gz
WORKDIR mysql-5.6.28
RUN cmake . -DCMAKE_INSTALL_PREFIX=/usr/local/mysql  -DMYSQL_DATADIR=/data/mysql  -DDEFAULT_CHARSET=utf8  -DWITH_READLINE=1  -DWITH_SSL=system  -DWITH_EMBEDDED_SERVER=1  -DENABLED_LOCAL_INFILE=1  -DDEFAULT_COLLATION=utf8_general_ci  -DWITH_MYISAM_STORAGE_ENGINE=1  -DWITH_INNOBASE_STORAGE_ENGINE=1  -DWITH_DEBUG=0 -DMYSQL_UNIX_ADDR=/var/lib/mysql/mysql.sock
RUN make && make install
RUN chmod +x /usr/local/mysql
RUN chown -R mysql:mysql /usr/local/mysql
RUN chown -R mysql:mysql /data/mysql
RUN cp ./support-files/mysql.server /etc/init.d/mysqld
RUN chmod +x /etc/init.d/mysqld
RUN update-rc.d mysqld defaults
RUN ln -sv /usr/local/mysql/bin/mysql  /usr/sbin/mysql
RUN ln -sv /usr/local/mysql/bin/mysqladmin  /usr/sbin/mysqladmin
RUN ln -sv /usr/local/mysql/bin/mysqldump  /usr/sbin/mysqldump
COPY files/my.cnf /etc/my.cnf
RUN /usr/local/mysql/scripts/mysql_install_db  --user=mysql  --basedir=/usr/local/mysql  --datadir=/data/mysql
#CLEAN
RUN apt-get clean \
    && apt-get autoclean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
	&& rm -rf /opt/src/*
#AUTO RUN
COPY files/auto_run.sh /usr/sbin/auto_run.sh
RUN chmod +x /usr/sbin/auto_run.sh
ENTRYPOINT ["/usr/sbin/auto_run.sh"]
