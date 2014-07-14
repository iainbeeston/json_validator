# activemodel validators have an undeclared dependency on the hash extensions from active support
require 'active_support/core_ext/hash'
require 'active_model/validator'

class JsonValidator < ActiveModel::EachValidator
  VERSION = '0.0.1'

  def initialize(options)
    super
  end

  def validate_each(record, attribute, value)
  end

  def schema(record)
    if options[:schema].nil?
      fail ArgumentError, ':schema cannot be blank'
    elsif options[:schema].respond_to?(:call)
      options[:schema].call(record)
    else
      options[:schema].to_hash
    end
  end
end
