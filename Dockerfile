FROM ubuntu:trusty

RUN apt-get clean && \
    apt-get update && \
    apt-get --no-install-recommends -y install wget \
                                                vim \
                                                openssh-server \
                                                openssh-sftp-server \
                                                openssh-client \
                                                telnet \
                                                unzip \
						supervisor \
						lsof \	
                                                dnsutils \
                                                git \
                                                build-essential \
                                                libldap2-dev libssl-dev libpcre3-dev

# Set time zone
RUN echo "Europe/Kiev" > /etc/timezone && dpkg-reconfigure --frontend noninteractive tzdata

# change root password and configure ssh
RUN echo root:root | chpasswd && \
    sed -i 's/^PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/UsePAM yes/UsePAM no/g' /etc/ssh/sshd_config && \
    mkdir /var/run/sshd && \
    chmod 0755 /var/run/sshd

RUN mkdir -p /nginx /web/info

WORKDIR /nginx

RUN wget http://nginx.org/download/nginx-1.8.0.tar.gz && \
    tar xzvf nginx-1.8.0.tar.gz

WORKDIR nginx-1.8.0

RUN ./configure --user=nginx --group=nginx --prefix=/etc/nginx \
    --sbin-path=/usr/sbin/nginx --conf-path=/etc/nginx/nginx.conf \
    --pid-path=/var/run/nginx.pid --lock-path=/var/run/nginx.lock \
    --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log \
    --with-http_gzip_static_module --with-http_stub_status_module --with-http_ssl_module \
    --with-pcre --with-file-aio --with-http_realip_module \
    --with-debug && \
    make && \
    make install

WORKDIR /

ADD configs/supervisord.conf /etc/supervisord.conf
ADD configs/nginx.conf /etc/nginx/
ADD configs/conf.d/default.conf /etc/nginx/conf.d/
ADD index.html /web/info/

RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    rm -rf /downloads

CMD supervisord

