require 'spec_helper'
require 'active_model'
require 'json_validator'

class FakeValidatingModel
  include ActiveModel::Validations

  attr_accessor :json_data

  def initialize(json_data)
    self.json_data = json_data.to_hash
  end
end

describe JsonValidator do
  describe '#validate_each' do
    let(:model) { FakeValidatingModel.new(json_data) }
    subject { described_class.new(attributes: [:json_data], schema: json_schema) }

    context 'when the schema is empty' do
      let(:json_data) do
        {
          'soup' => 'tastes good'
        }
      end
      subject { described_class.new(attributes: [:json_data], schema: {}) }

      it 'does not set any errors' do
        expect { subject.validate_each(model, :json_data, json_data) }.to_not change { model.errors.empty? }
      end
    end

    context 'when a schema specifies required fields' do
      let(:json_data) do
        {
          'bread' => 'is crusty'
        }
      end
      let(:json_schema) do
        {
          'type' => 'object',
          'required' => ['soup']
        }
      end

      it 'sets errors for required fields that are blank' do
        expect {
          subject.validate_each(model, :json_data, json_data)
        }.to change {
          model.errors.to_hash
        }.from(
          {}
        ).to(
          {
            json_data: ["The property '#/' did not contain a required property of 'soup'"]
          }
        )
      end
    end

    context 'when a schema specifies minLength' do
      let(:json_data) do
        {
          'menu' => 'does not have enough variety',
          'address' => 'is fine'
        }
      end
      let(:json_schema) do
        {
          'type' => 'object',
          'properties' => {
            'menu' => {
              'type' => 'string',
              'minLength' => 200
            },
            'address' => {
              'type' => 'string',
              'minLength' => 3
            }
          }
        }
      end

      it 'sets errors for fields with minLength that do not meet the required length' do
        expect {
          subject.validate_each(model, :json_data, json_data)
        }.to change {
          model.errors.to_hash
        }.from(
          {}
        ).to(
          {
            json_data: ["The property '#/menu' was not of a minimum string length of 200"]
          }
        )
      end
    end
  end

  describe '#initialize' do
    context 'when a schema is not specified' do
      it 'raises an error' do
        expect {
          described_class.new(attributes: [:name])
        }.to raise_error(ArgumentError).with_message(
          'Schema unspecified. Please specify :schema as either a Proc or a hash'
        )
      end
    end
  end

  describe '#schema' do
    context 'when initialized with a :schema option' do
      context 'that is a lambda' do
        subject { described_class.new(attributes: [:name], schema: ->(model) { { foo: model.name } }) }

        it 'is the result of the lambda (passed the model)' do
          expect(subject.schema(double(name: 'ack'))).to eq(foo: 'ack')
        end
      end

      context 'that is a hash' do
        subject { described_class.new(attributes: [:name], schema: { foo: :bar }) }

        it 'is the hash' do
          expect(subject.schema(double)).to eq(foo: :bar)
        end
      end
    end
  end

  describe '#json' do
    subject { described_class.new(attributes: [:name], schema: {}) }

    it 'returns the input when passed a hash' do
      expect(subject.json('foo' => 'bar')).to eq('foo' => 'bar')
    end

    it 'parses the input as JSON when passed a string' do
      expect(subject.json('{"foo": "bar"}')).to eq('foo' => 'bar')
    end

    it 'calls #to_hash when passed any other object' do
      expect(subject.json(double(to_hash: { 'foo' => 'bar' }))).to eq('foo' => 'bar')
    end
  end

  describe '#translate_message' do
    subject { described_class.new(attributes: [:name], schema: { foo: :bar }) }

    it 'translates json-schema messages to slightly more readable ones' do
      msg = "The property '#/menu' was not of a minimum string length of 200 in schema 40148e2f-45d6-51b7-972a-179bd9de61d6#"
      expect(subject.translate_message(msg)).to eq("The property '#/menu' was not of a minimum string length of 200")
    end
  end

  describe '#VERSION' do
    it 'is the same as JsonValidatorMeta::VERSION' do
      expect(described_class.const_get(:VERSION)).to eq(JsonValidatorMeta::VERSION)
    end
  end
end
