FROM php:7.2-cli

# update packaging tool
RUN apt-get update 

ARG swoole_version=4.2.11
ARG php_extension_stub_generator_version=0.0.4

# prepare environment
RUN apt install -y openssl
RUN apt install -y libssl-dev
RUN apt install -y git

# download, install and enable Swoole extension
RUN pecl download swoole-${swoole_version} && \
    tar xvzf swoole-${swoole_version}.tgz && \
    cd swoole-${swoole_version} && \
    phpize && \
    ./configure --enable-openssl && \
    make && \
    make install && \
    touch /usr/local/etc/php/conf.d/swoole.ini && \
    echo 'extension=swoole.so' > /usr/local/etc/php/conf.d/swoole.ini && \
    echo "\\nlog_errors=On\\nerror_log=/dev/stderr" >> /usr/local/etc/php/conf.d/swoole.ini

# download, install and run PHP extension stub generator
RUN mkdir -p /util && \
    cd /util && \
    git clone https://github.com/Maxdw/php-extension-stub-generator-wrapper && \
    cd php-extension-stub-generator-wrapper && \
    ./generate.sh ${php_extension_stub_generator_version} swoole

# run server
COPY ./server.php /server.php
EXPOSE 8101
CMD ["/usr/local/bin/php", "/server.php"]