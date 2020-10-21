from ruby:2.7.1-alpine as build

WORKDIR /app

COPY Gemfile* ./

RUN apk update && \
    apk upgrade && \
    apk add --no-cache --update alpine-sdk && \
    apk add --no-cache make && \
    bundler config set without 'test' && \
    bundler install --path=vendor/bundle


from ruby:2.7.1-alpine

COPY --from=build /app /app
ADD . /app
WORKDIR /app

EXPOSE 4567

ENV PATH "$PATH:/app/vendor/bundle/ruby/2.7.0/bin"
ENV GEM_HOME "/app/vendor/bundle/ruby/2.7.0"

CMD ["rackup"]
