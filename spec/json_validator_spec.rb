require 'json_validator'
require 'spec_helper'
require 'active_model'

describe JsonValidator do
  let(:fake) do
    Class.new do
      include ActiveModel::Validations

      attr_accessor :json_data

      def initialize(json_data)
        self.json_data = json_data.to_hash
      end
    end
  end

  describe '#validate_each' do
    let(:model) { fake.new(json_data) }
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
            json_data: ["The property '#/' did not contain a required property of 'soup' in schema f14d8cc1-b124-5b71-a05a-6407e9297d65#"]
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
            json_data: ["The property '#/menu' was not of a minimum string length of 200 in schema 40148e2f-45d6-51b7-972a-179bd9de61d6#"]
          }
        )
      end
    end
  end

  describe '#schema' do
    context 'when not initialized with a schema' do
      subject { described_class.new(attributes: [:name]) }

      it 'is an empty hash' do
        expect { subject.schema(double) }.to raise_error(ArgumentError).with_message(':schema cannot be blank')
      end
    end

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
end
