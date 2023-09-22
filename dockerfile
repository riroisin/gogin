FROM golang:1.20.4-alpine3.18

ENV VERSION 7.17.10
ENV DOWNLOAD_URL "https://artifacts.elastic.co/downloads"
ENV ELASTICSEARCH_TARGZ "${DOWNLOAD_URL}/elasticsearch/elasticsearch-${VERSION}-linux-x86_64.tar.gz"
ENV LOGSTASH_TARGZ "${DOWNLOAD_URL}/logstash/logstash-${VERSION}-linux-x86_64.tar.gz"

RUN apk update
RUN apk add --no-cache bash vim nodejs npm
RUN apk add --no-cache -t .build-deps wget ca-certificates gnupg openssl \
	&& set -ex \
	&& cd /tmp \
	&& echo "===> Install Elasticsearch..." \
	&& wget --progress=bar:force -O elasticsearch.tar.gz "$ELASTICSEARCH_TARGZ"; \
	tar -zxvf elasticsearch.tar.gz \
	&& wget --progress=bar:force -O logstash.tar.gz "$LOGSTASH_TARGZ"; \
	tar -zxvf logstash.tar.gz \
	&& ls -lah \
	&& mv elasticsearch-$VERSION /usr/share/elasticsearch \
	&& mv logstash-$VERSION /usr/share/logstash \
	&& adduser -D -h /usr/share/elasticsearch -s /bin/bash elasticsearch \
	&& echo "===> Creating Elasticsearch Paths..." \
	&& for mkdir_path in \
	/usr/share/go \
	/usr/share/go/templates \
	; do \
	mkdir -p "$mkdir_path"; \
	done \	
	&& for path in \
	/usr/share/elasticsearch/data \
	/usr/share/elasticsearch/logs \
	/usr/share/elasticsearch/config \
	/usr/share/elasticsearch/config/scripts \
	/usr/share/elasticsearch/tmp \
	/usr/share/elasticsearch/plugins \
	/usr/share/logstash \
	/usr/share/go \
	/usr/share/go/templates \
	; do \			
	chown -R elasticsearch:elasticsearch "$path"; \
	done \
	&& rm -rf /tmp/* \
	&& apk del --purge .build-deps

LABEL COPY FROM WSL TO CONTAINER
USER elasticsearch
COPY go/main.go /usr/share/go/main.go
COPY go/common_test.go /usr/share/go/common_test.go
COPY go/handlers.article_test.go /usr/share/go/handlers.article_test.go
COPY go/handlers.article.go /usr/share/go/handlers.article.go
COPY go/models.article_test.go /usr/share/go/models.article_test.go
COPY go/models.article.go /usr/share/go/models.article.go
COPY go/routes.go /usr/share/go/routes.go
COPY go/tsconfig.json /usr/share/go/tsconfig.json
COPY go/templates/header.html /usr/share/go/templates/header.html
COPY go/templates/index.html /usr/share/go/templates/index.html
COPY go/templates/menu.html /usr/share/go/templates/menu.html
COPY go/templates/article.html /usr/share/go/templates/article.html

LABEL Install GIN
WORKDIR /usr/share/go
RUN go mod init github.com/riroisin \
	&& go get -u github.com/gin-gonic/gin \
	&& go get -u github.com/elastic/go-elasticsearch/v7 \
	&& go build -o main

EXPOSE 80 443 8080 9200 9300 9600 5601 5044
