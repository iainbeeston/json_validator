require 'json_validator_meta'
# activemodel validators have an undeclared dependency on the hash extensions from active support
require 'active_support/core_ext/hash'
require 'active_model/validator'
require 'json-schema'

class JsonValidator < ActiveModel::EachValidator
  VERSION = JsonValidatorMeta::VERSION

  def validate_each(record, attribute, value)
    errors = JSON::Validator.fully_validate(schema(record), value)
    errors.each do |e|
      record.errors[attribute.to_sym] << e
    end
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
