# frozen_string_literal: true

require 'spec_helper'
require 'bigdecimal'
require_relative '../../discounts/bulk'

describe Discounts::Bulk do
  let(:code) { 'PBZ' }
  let(:other_product) { { 'code' => 'TBZ', 'name' => 'Testberries', 'price' => 1 } }
  let(:product_properties) { { 'code' => code, 'name' => 'Plumberries', 'price' => 2345 } }
  let(:other_product_properties) { { 'code' => 'TBZ', 'name' => 'Testberry', 'price' => 5432 } }

  4.times { |i| let("product#{i + 1}".to_sym) { product_properties } }
  3.times { |i| let("other_product#{i + 1}".to_sym) { other_product_properties } }

  let(:discount_json) do
    {
      'name' => 'Very berry week! Bulk discount, greag deal, no kidding!',
      'product_code' => code,
      'threshold_quantity' => 3,
      'type' => 'bulk'
    }
  end

  before { allow_any_instance_of(::Loaders::Products).to receive(:by_code).with(code).and_return(product1) }

  subject { described_class.new(discount_json) }

  shared_examples 'a not eligible discount' do
    it 'does not apply any discounts and removes existing ones' do
      subject.apply(products)

      products.each { |product| expect(product['discount']).to be_nil }
    end
  end

  shared_examples 'a bulk discount' do
    context 'when there are no matching products in the products list' do
      let(:products) { [other_product1] }
      it_behaves_like 'a not eligible discount'
    end

    context 'when there is not enough matching products in the products list' do
      let(:products) { [product1, product2] }

      context 'when there are only matching products in the products list' do
        it_behaves_like 'a not eligible discount'
      end

      context 'when there are other products in the products list' do
        before { products << other_product }

        it_behaves_like 'a not eligible discount'
      end
    end

    context 'when the discount is eligible' do
      let(:products) { [product1, product2, product3] }

      context 'when there are only matching products in the products list' do
        it 'applies the discount to all products' do
          subject.apply(products)

          products.each { |product| expect(product['discount']).to eq(discount_amount) }
        end
      end

      context 'when there are other products in the products list' do
        before { products << other_product }

        it 'applies the discount only to discountable products' do
          subject.apply(products)

          expect(product1['discount']).to eq(discount_amount)
          expect(product2['discount']).to eq(discount_amount)
          expect(product3['discount']).to eq(discount_amount)
          expect(other_product['discount']).to be_nil
        end
      end
    end

    context 'when the discount becomes not eligible' do
      let(:products) { [product1, product2] }

      before { products.each { |product| product['discount'] = discount_amount } }

      it_behaves_like 'a not eligible discount'
    end
  end

  describe '#apply' do
    context 'fractional discount' do
      before do
        discount_json['discount_fraction'] = '1/17'
        discount_json['name'] = 'Plumberries Week! Buy 3 or more and get 1/17 off!'
      end

      let(:discount_amount) { 138 } # 2345 / 17 = 138.5294117647059

      it_behaves_like 'a bulk discount'
    end

    context 'fixed price discount' do
      before do
        discount_json['name'] = 'Plumberries Week! Buy 5 or more and get them for 50€ each !'
        discount_json['fixed_price'] = 50
      end

      let(:products) { [product1] }
      let(:discount_amount) { 2295 } # 2345 - 50 = 2295

      it_behaves_like 'a bulk discount'
    end
  end

  describe '#validate_discount_fraction' do
    before { discount_json['discount_fraction'] = '1/17' }

    context 'when discount fraction is a positive fraction' do
      it 'does not raise an error' do
        expect { subject.send(:validate_discount_fraction) }.not_to raise_error
      end
    end

    context 'when discount fraction is not a positive fraction' do
      before { discount_json['discount_fraction'] = 'a/5' }

      it 'raises an error' do
        expect do
          subject.send(:validate_discount_fraction)
        end.to raise_error('Discount fraction should be a positive fraction')
      end
    end

    context 'when denominator is zero' do
      before { discount_json['discount_fraction'] = '1/0' }

      it 'raises an error' do
        expect { subject.send(:validate_discount_fraction) }.to raise_error('Denominator cannot be zero')
      end
    end

    context 'when discount fraction is greater than or equal to 1' do
      before { discount_json['discount_fraction'] = '2/1' }

      it 'raises an error' do
        error_msg = 'Discount fraction should be less than 1 and more than 0'
        expect { subject.send(:validate_discount_fraction) }.to raise_error(error_msg)
      end
    end
  end

  describe '#validate_fixed_price' do
    before { discount_json['fixed_price'] = 50 }

    context 'when fixed price is an integer' do
      it 'does not raise an error' do
        expect { subject.send(:validate_fixed_price) }.not_to raise_error
      end
    end

    context 'when fixed price is not an integer' do
      before { discount_json['fixed_price'] = 50.5 }

      it 'raises an error' do
        expect { subject.send(:validate_fixed_price) }.to raise_error('Fixed price should be an integer')
      end
    end

    context 'when fixed price is not a positive integer' do
      before { discount_json['fixed_price'] = -50 }

      it 'raises an error' do
        expect { subject.send(:validate_fixed_price) }.to raise_error('Fixed price should be a positive integer')
      end
    end

    context 'when fixed price is greater than or equal to product price' do
      before { discount_json['fixed_price'] = 3000 }

      it 'raises an error' do
        expect { subject.send(:validate_fixed_price) }.to raise_error('Fixed price should be less than product price')
      end
    end
  end

  describe '#calculate_fixed_price_discount' do
    before { discount_json['fixed_price'] = 2344 }

    it 'returns discount amount' do
      expect(subject.send(:calculate_fixed_price_discount)).to eq(1)
    end
  end

  describe '#calculate_fraction_discount' do
    before { discount_json['discount_fraction'] = '1/17' }

    it 'returns discount amount' do
      expect(subject.send(:calculate_fraction_discount)).to eq(138) # 2345 / 17 = 137.94117647058823529411764705882352886
    end
  end
end
