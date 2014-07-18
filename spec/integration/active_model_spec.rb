require 'spec_helper'
require 'active_model'
require 'json_validator'

class FakeActiveModel
  include ActiveModel::Validations

  attr_accessor :json_data

  def initialize(json_data)
    self.json_data = json_data.to_hash
  end

  validates :json_data, json: {
    allow_blank: true,
    schema: {
      'type' => 'object',
      'required' => ['foo']
    }
  }
end

describe 'ActiveModel' do
  it 'sets validation errors using JsonValidator' do
    expect(FakeActiveModel.new(hello: :world)).to_not be_valid
  end

  it 'does not set validation errors using JsonValidator when the json is valid' do
    expect(FakeActiveModel.new(foo: :bar)).to be_valid
  end

  it 'does not run JsonValidator when allow_blank is true and the json is an empty hash' do
    expect(FakeActiveModel.new({})).to be_valid
  end
end
