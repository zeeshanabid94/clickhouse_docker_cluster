FROM ubuntu:trusty

RUN echo "deb http://repo.yandex.ru/clickhouse/deb/stable/ main/" \
    > /etc/apt/sources.list.d/clickhouse.list

RUN apt-get update

RUN apt-get install -y --allow-unauthenticated \
    clickhouse-server-common \
    clickhouse-client
ADD https://github.com/tianon/gosu/releases/download/1.10/gosu-amd64 /bin/gosu

COPY ["./ch_config.xml", "/etc/clickhouse-server/config.xml"]
COPY ["./include_from.xml", "/etc/clickhouse-server/include_from.xml"]
COPY ["./entrypoint.sh", "/entrypoint.sh"]
VOLUME /var/lib/clickhouse

RUN chmod +x \
    /entrypoint.sh \
    /bin/gosu
ENTRYPOINT /entrypoint.sh