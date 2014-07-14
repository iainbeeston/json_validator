require 'spec_helper'
require 'active_model'
require 'json_validator'

class FakeActiveModel
  include ActiveModel::Model

  attr_accessor :json_data

  validates :json_data, json: {
    allow_blank: true,
    schema: {
      'type' => 'object',
      'required' => ['foo']
    }
  }
end

describe FakeActiveModel do
  it 'sets validation errors using JsonValidator' do
    expect(FakeActiveModel.new(json_data: { hello: :world })).to_not be_valid
  end

  it 'does not set validation errors using JsonValidator when the json is valid' do
    expect(FakeActiveModel.new(json_data: { foo: :bar })).to be_valid
  end

  it 'does not run JsonValidator when allow_blank is true and the json is an empty hash' do
    expect(FakeActiveModel.new(json_data: {})).to be_valid
  end
end
