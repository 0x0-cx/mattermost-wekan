from ruby:2.7.1-alpine

RUN apk update && apk upgrade && apk add --update alpine-sdk && \
    apk add --no-cache make

RUN mkdir /usr/src/app
ADD . /usr/src/app/
WORKDIR /usr/src/app/
RUN bundler install

cmd ["ruby", "./bin/mattermost_wekan.rb"]
