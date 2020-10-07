# Mattermost::Wekan

simple ruby bot for interact with [wekan-mattermost](https://github.com/lunatic-cat/wekan-mattermost)

just comment wekan-mattermost message and it automataic add to the related wekan card

## Installation

```bash
docker build -t mattermost-wekan .
```

## Usage

```yaml
version: "3"
services:
  mattermost-wekan:
    image: mattermost-wekan
    environment:
      MATTERMOST_TOKEN: "" # token giving after create mattermost outgoing webhook
      MATTERMOST_WEBHOOK_PATH: "" # path to callback 
      MATTERMOST_BOT_USERNAME: "" # some mattermost user username
      MATTERMOST_BOT_PASSWORD: "" # some mattermost user password
      MATTERMOST_URL: "" 
      WEKAN_DB_URL: "" # example: localhost:27017
      WEKAN_USER_LIST: "" # wekan user_ids with  space separated 
      MATTERMOST_USER_LIST: "" # maattermost user_ids with space separated
```

you need to:

1. create mattermost user
1. create mattermost outgoing webhook (more simply use via reverse proxy)
1. expose wekan-db port or add mattermost-wekan container to the wekan docker network
1. if all okay you see 'token successfully retrieve' 

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/mattermost-wekan.

