# frozen_string_literal: true

require 'rspec'

require_relative '../spec_helper'

RSpec.describe 'card title' do
  it 'correct command' do
    message = "title @centralhardware  исправить   #backlog     оптимизацию @afgan0r в проекте #bug

    description  text "
    card_title = Mattermost::Wekan::CardTitle.new(text: message)
    expect(card_title.description).to eq('description  text')
    expect(card_title.assign_to).to eq(['centralhardware'])
    tags = %w[backlog bug]
    expect(card_title.tag).to eq(tags)
    expect(card_title.title).to eq('title исправить оптимизацию в проекте')
  end
end
