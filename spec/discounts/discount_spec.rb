# frozen_string_literal: true

require 'spec_helper'
require_relative '../../discounts/discount'

describe Discounts::Discount do
  let(:discount_json) do
    {
      'type' => 'buy_n_get_n_free',
      'product_code' => 'abc',
      'threshold_quantity' => 3
    }
  end
  let(:product_properties) { { 'code' => 'abc', 'name' => 'Abcheddar', 'price' => 997 } }

  3.times { |i| let("product#{i + 1}".to_sym) { product_properties } }

  let(:products) { [product1, product2, product3] }

  before { allow_any_instance_of(described_class).to receive(:validate_specific_discount_properties) }

  subject { described_class.new(discount_json) }

  describe '#initialize' do
    context 'when discount properties are not invalid' do
      it 'raises an error' do
        expect { described_class.new(nil) }.to raise_error('Discount properties not specified')
        expect { described_class.new({}) }.to raise_error('Discount properties not specified')
        expect { described_class.new('') }.to raise_error('Discount properties not specified')
        expect { described_class.new(' ') }.to raise_error('Discount properties should be a hash')
        expect { described_class.new('Y') }.to raise_error('Discount properties should be a hash')
      end
    end

    context 'when discount properties are specified' do
      it 'initializes the discount object' do
        expect(subject.discount_properties).to eq(discount_json)
        expect(subject.products).to be_nil
      end
    end
  end

  describe '#apply' do
    context 'when the discount is not implemented in child classes' do
      it 'raises a NotImplementedError' do
        expect { subject.apply(products) }.to raise_error(NotImplementedError)
      end
    end
  end

  describe '#validate_specific_discount_properties' do
    before do
      allow_any_instance_of(described_class).to receive(:validate_specific_discount_properties).and_call_original
    end

    it 'raises a NotImplementedError' do
      expect { subject.send(:validate_specific_discount_properties) }.to raise_error(NotImplementedError)
    end
  end

  describe '#validate_general_discount_properties' do
    context 'when the threshold quantity is not specified' do
      context 'when nil' do
        before { discount_json['threshold_quantity'] = nil }

        it 'raises an error' do
          expect do
            subject.send(:validate_general_discount_properties)
          end.to raise_error('Discount threshold quantity not specified')
        end
      end
      context 'when empty string' do
        before { discount_json['threshold_quantity'] = ' ' }

        it 'raises an error' do
          expect do
            subject.send(:validate_general_discount_properties)
          end.to raise_error('Discount threshold quantity should be a positive integer')
        end
      end
    end

    context 'when the threshold quantity is not a positive integer' do
      context 'when 0' do
        before { discount_json['threshold_quantity'] = '0' }

        it 'raises an error' do
          expect do
            subject.send(:validate_general_discount_properties)
          end.to raise_error('Discount threshold quantity should be a positive integer')
        end
      end

      context 'when string' do
        before { discount_json['threshold_quantity'] = 'asd' }

        it 'raises an error' do
          expect do
            subject.send(:validate_general_discount_properties)
          end.to raise_error('Discount threshold quantity should be a positive integer')
        end
      end
    end
  end

  describe '#validate_product_code' do
    context 'when the product code is not specified' do
      context 'when nil' do
        before { discount_json['product_code'] = nil }

        it 'raises an error' do
          expect do
            subject.send(:validate_general_discount_properties)
          end.to raise_error('Discount product code not specified')
        end
      end

      context 'when empty string' do
        before { discount_json['product_code'] = ' ' }

        it 'raises an error' do
          expect do
            subject.send(:validate_general_discount_properties)
          end.to raise_error('Discount product code not specified')
        end
      end
    end
  end

  describe '#discount_eligible?' do
    context 'when the number of products is greater than or equal to the threshold quantity' do
      before { subject.instance_variable_set(:@products, products) }

      it 'returns true' do
        expect(subject.send(:discount_eligible?)).to be true
      end
    end

    context 'when the number of products is less than the threshold quantity' do
      before { subject.instance_variable_set(:@products, [product1]) }

      it 'returns false' do
        expect(subject.send(:discount_eligible?)).to be false
      end
    end
  end
end
