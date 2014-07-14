# JsonValidator

JsonValidator is an ActiveModel validator that validates any hash field against [JSONSchema](http://json-schema.org), returning errors in the model's own `errors` attribute.

## Installation

Add this line to your application's Gemfile:

    gem 'json_validator'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install json_validator

## Usage

If you're using Ruby on Rails and ActiveRecord, add a validation to your model like this:

    class Foo < ActiveRecord::Base
      validates :bar, json: {
        schema: JSON.parse(File.read("#{model.class.table_name}_schema.json"))
      }
    end

Then whenever an instance of `Foo` is saved, `Foo.bar` (assumed to be a hash) will be validated against `foo_schema.json`.

Notes:
* `schema` can be a hash or a Proc (if you'd like to define it dynamically)
* If you're using ActiveModel without Rails the process is the same.

## Contributing

1. Fork it ( https://github.com/[my-github-username]/json_validator/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
