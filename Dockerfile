#
# Docker Uchiwa
#

FROM ubuntu:trusty
MAINTAINER Exequiel Pierotto <epierotto@abast.es>

#
# Prerequisites
#

# Install NodeJS
RUN \
        apt-get update && apt-get install -y \
	build-essential \
	curl \
	git && \
	curl -sL https://deb.nodesource.com/setup | bash - && \
	apt-get update && apt-get install -y \
	nodejs

# Install Go
RUN \
	mkdir -p /goroot && \
	curl https://storage.googleapis.com/golang/go1.3.1.linux-amd64.tar.gz | tar xvzf - -C /goroot --strip-components=1

# Set environment variables.
ENV GOROOT /goroot
ENV GOPATH /gopath
ENV PATH $GOROOT/bin:$GOPATH/bin:$PATH

# Install Uchiwa
RUN \
	go get github.com/sensu/uchiwa && \
	cd $GOPATH/src/github.com/sensu/uchiwa && \
	npm -g cache clean && \
	npm install --production --unsafe-perm

# Add the config file
COPY files/uchiwa.json $GOPATH/src/github.com/sensu/uchiwa/uchiwa.json
COPY files/uchiwa-start /usr/local/bin/uchiwa-start

RUN chmod +x /usr/local/bin/uchiwa-start

# Sync with a local directory or a data volume container
#VOLUME /etc/sensu

WORKDIR /gopath/src/github.com/sensu/uchiwa

EXPOSE 3000

CMD ["uchiwa-start"]
