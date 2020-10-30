# frozen_string_literal: true

require 'rspec'

require_relative '../../spec_helper'

RSpec.describe Mattermost::Wekan::CardTitle do
  subject { Mattermost::Wekan::CardTitle.new(text: message) }
  let(:tags) { %w[bar baz] }
  context 'with correct command' do
    let(:message) do
      "title @alice  lorem   #bar     ipsum @bob dolor #baz\n
    description  text "
    end
    it 'work' do
      expect(subject.description).to eq('description  text')
      expect(subject.assign_to).to eq(['alice'])
      expect(subject.tags).to eq(tags)
      expect(subject.title).to eq('title lorem ipsum dolor')
    end
  end

  context 'without description' do
    let(:message) { 'title @alice  lorem   #bar     ipsum @bob dolor #baz' }
    it 'has empty description' do
      expect(subject.description).to eq('')
      expect(subject.assign_to).to eq(['alice'])
      expect(subject.tags).to eq(tags)
      expect(subject.title).to eq('title lorem ipsum dolor')
    end
  end
end
