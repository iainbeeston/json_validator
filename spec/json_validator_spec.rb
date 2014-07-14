require 'spec_helper'

describe JsonValidator do
  describe '#validate_each' do
  end

  describe '#schema' do
    context 'when not initialized with a schema' do
      subject { JsonValidator.new(attributes: [:name]) }

      it 'is an empty hash' do
        expect { subject.schema(double) }.to raise_error(ArgumentError).with_message(':schema cannot be blank')
      end
    end

    context 'when initialized with a :schema option' do
      context 'that is a lambda' do
        subject { JsonValidator.new(attributes: [:name], schema: ->(model) { { foo: model.name } }) }

        it 'is the result of the lambda (passed the model)' do
          expect(subject.schema(double(name: 'ack'))).to eq(foo: 'ack')
        end
      end

      context 'that is a hash' do
        subject { JsonValidator.new(attributes: [:name], schema: { foo: :bar }) }

        it 'is the hash' do
          expect(subject.schema(double)).to eq(foo: :bar)
        end
      end
    end
  end
end
