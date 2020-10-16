from ruby:2.7.1-alpine

RUN mkdir /usr/src/app
ADD . /usr/src/app/
WORKDIR /usr/src/app/

RUN apk update && \
    apk upgrade && \
    apk add --no-cache --update alpine-sdk && \
    apk add --no-cache make && \
    bundler config set without 'test' 'ci'&& \
    bundler install

EXPOSE 4567

CMD ["ruby", "./lib/mattermost/wekan/server.rb"]
