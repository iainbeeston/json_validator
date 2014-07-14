require 'json_validator_meta'
# activemodel validators have an undeclared dependency on the hash extensions from active support
require 'active_support/core_ext/hash'
require 'active_model/validator'
require 'json-schema'

class JsonValidator < ActiveModel::EachValidator
  VERSION = JsonValidatorMeta::VERSION

  def validate_each(record, attribute, value)
    raw_errors = JSON::Validator.fully_validate(schema(record), value)
    translated_errors = raw_errors.map do |e|
      translate_message(e)
    end
    translated_errors.each do |e|
      record.errors.add(attribute, e)
    end
  end

  def schema(record)
    if options[:schema].respond_to?(:call)
      options[:schema].call(record)
    else
      options[:schema].to_hash
    end
  end

  def translate_message(msg)
    # remove suffix
    msg.gsub!(/ in schema .*$/, '')
  end

  def check_validity!
    fail ArgumentError, :'Schema unspecified. Please specify :schema as either a Proc or a hash' if options[:schema].nil?
  end
end
