# frozen_string_literal: true

$:.unshift "#{File.dirname(__FILE__)}/lib"
require 'mattermost/wekan/server'

run Server
