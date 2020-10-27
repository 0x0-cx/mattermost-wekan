# Mattermost::Wekan

simple ruby bot for interact with [wekan-mattermost](https://github.com/lunatic-cat/wekan-mattermost)

just comment wekan-mattermost message and it automataic add to the related wekan card

## NOTE: 

minimum ruby version is 2.7

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
      MATTERMOST_TOKEN: "token giving after create mattermost outgoing webhook" 
      mattermost_bot_token: "some mattermost user password" 
      MATTERMOST_URL: ""
      wekan_url: "" 
      WEKAN_DB_URL: "example: mongodb://localhost:27017/wekan"
      WEKAN_USER_LIST: "wekan user_ids with  space separated"  
      MATTERMOST_USER_LIST: "maattermost user_ids with space separated"
      DEBUG: ""
```

you need to:

1. create mattermost bot account and add it to channel
1. create mattermost outgoing webhook
1. expose wekan-db port or add mattermost-wekan container to the wekan docker network
