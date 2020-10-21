# frozen_string_literal: true

$LOAD_PATH.unshift "#{File.dirname(__FILE__)}/lib"

require 'mattermost/wekan/server'

Mattermost::Wekan::Server.run!
