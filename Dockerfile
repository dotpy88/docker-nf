FROM debian:bullseye-slim

#Variables for install
ARG DEBIAN_FRONTEND=noninteractive
ARG NFSEN_VERSION=1.3.8
ARG NFDUMP_VERSION=1.6.24
ARG TIMEZONE=US/Central

#Add required files
ADD conf /artifacts/

#Install required packages
RUN apt-get update -qq \
    && apt-get install --no-install-recommends --no-install-suggests -y \
        apache2 \
        autoconf \
        autogen \
        automake \
        bison \
        build-essential \
        ca-certificates \
        flex \
        libapache2-mod-php \
        libbz2-dev \
        libmailtools-perl \
        libnet-idn-encode-perl \
        librrd-dev \
        librrds-perl \
        librrdp-perl \
        libsocket6-perl \
        libtool \
        liburi-perl \
        m4 \
        php \
        pkg-config \
        rrdtool \
        rsyslog \
        wget 

#Install nfdump from source
RUN wget -O nfdump.tar.gz https://github.com/phaag/nfdump/archive/refs/tags/v${NFDUMP_VERSION}.tar.gz \
    && tar -xzf nfdump.tar.gz \
    && cd nfdump-${NFDUMP_VERSION} \
    && bash autogen.sh \
    && mkdir -p /artifacts/nfdump \
    && ./configure \
       --prefix=/artifacts/nfdump \
       --enable-nfprofile \
       --enable-nftrack \
       --enable-sflow \
    && make \
    && make install

#Install nfsen from source
RUN wget https://sourceforge.net/projects/nfsen/files/stable/nfsen-${NFSEN_VERSION}/nfsen-${NFSEN_VERSION}.tar.gz \
    && tar -xzf nfsen-${NFSEN_VERSION}.tar.gz \
    && mv nfsen-${NFSEN_VERSION} /artifacts/nfsen \
    && sed -i -re "s|rrd_version < 1.6|rrd_version < 1.8|g" /artifacts/nfsen/libexec/NfSenRRD.pm \
    && mv /artifacts/nfsen.conf /artifacts/nfsen/etc/nfsen.conf \
    && mv /artifacts/apache-nfsen.conf /etc/apache2/sites-enabled/000-default.conf \
    && echo "ServerName 127.0.0.1" >> /etc/apache2/apache2.conf \
    && echo "$TIMEZONE" > /etc/timezone \
    && sed -i -re "s|;date.timezone.*|date.timezone = $TIMEZONE|g" /etc/php/7.4/apache2/php.ini \
    && rm /etc/localtime && dpkg-reconfigure -f noninteractive tzdata \
    && sed -i '/imklog/s/^/#/' /etc/rsyslog.conf

#Create netflow user and assign to www-data group
RUN adduser -u 5678 --disabled-password --gecos "" netflow
RUN usermod -G www-data netflow

#Set workdir for nfsen installation
#WORKDIR /artifacts/nfsen
#RUN echo | ./install.pl ./etc/nfsen.conf || true

# HTTP
#EXPOSE 80

# Netflow
#EXPOSE 9996

# sFlow
#EXPOSE 9997

#Start nfsen service
#ENTRYPOINT ["../entrypoint.sh"]

#Run apache in foreground
#CMD ["/usr/sbin/apache2ctl", "-DFOREGROUND"]
#ENTRYPOINT ["tail", "-f", "/dev/null"]