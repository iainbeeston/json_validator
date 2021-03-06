# JsonValidator

[![Gem Version](http://img.shields.io/gem/v/json_validator.svg)](https://rubygems.org/gems/json_validator)
[![Build Status](http://img.shields.io/travis/iainbeeston/json_validator/master.svg)](https://travis-ci.org/iainbeeston/json_validator)
[![Code Climate](http://img.shields.io/codeclimate/maintainability/iainbeeston/json_validator)](https://codeclimate.com/github/iainbeeston/json_validator/maintainability)


JsonValidator is an ActiveModel validator that validates any hash field against [JSONSchema](http://json-schema.org), returning errors in the model's own `errors` attribute.

This gem was originally written to provide deep validation of JSON attributes, which are available alongside primative types in recent versions of [PostgreSQL](http://www.postgresql.org), but it works equally well with ActiveModel objects.

Most of the functionality is dependent on the wonderful [json-schema](https://github.com/hoxworth/json-schema) gem.

## Usage

If you're using Ruby on Rails and ActiveRecord, add a validation to your model like this:

~~~ruby
class Foo < ActiveRecord::Base
  validates :bar, json: {
    schema: JSON.parse(File.read('foo_schema.json'))
  }
end
~~~

And you have a schema file (ie. `foo_schema.json`) like this:

~~~json
{
  "$schema": "http://json-schema.org/draft-04/schema#",
  "title": "Universal spoons schema",
    "properties": {
      "handleSize": {
      "type": "integer",
      "minimum": 0
    }
  },
  "required": ["handleSize"]
}
~~~

Then whenever an instance of `Foo` is saved, `Foo.bar` (assumed to be a hash) will be validated against the JSON schema specified. So, for example:

~~~ruby

f = Foo.new(bar: { handleSize: -10 })
f.valid? # false
f.errors.full_messages # ["Bar is invalid (the property '#/handleSize' did not have a minimum value of 0, inclusively)"]
~~~

The attribute being validated can be either a hash or a string (which will be parsed as JSON). The schema can be either a hash or a Proc that returns a hash (if you'd like to decide on the schema at runtime), and there's no reason why you could not load your schema from a .json file.
