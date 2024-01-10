# frozen_string_literal: true

require 'spec_helper'
require_relative '../../discounts/buy_n_get_n_free'
require_relative '../../products/product'

describe Discounts::BuyNGetNFree do
  let(:code) { 'PBZ' }
  let(:discount_json) do
    { 'name' => 'Buy 3 plumberries and get 1 Free!',
      'type' => 'buy_n_get_n_free',
      'product_code' => code,
      'free_quantity' => 1,
      'threshold_quantity' => 3 }
  end

  let(:product_properties) { { 'code' => code, 'name' => 'Plumberry', 'price' => 100 } }
  let(:other_product_properties) { { 'code' => 'TBZ', 'name' => 'Testberry', 'price' => 1 } }

  7.times { |i| let("product#{i + 1}".to_sym) { Products::Product.build(product_properties) } }
  3.times { |i| let("other_product#{i + 1}".to_sym) { Products::Product.build(other_product_properties) } }

  shared_examples 'an eligible discount for less than double threshold' do
    let(:products) { [product1, product2, product3, product4, product5] }

    it 'applies the discount only to discountable products' do
      subject.apply(products)

      expect(product1.discount).to eq(100)
      expect(product2.discount).to be_nil
      expect(product3.discount).to be_nil
      expect(product4.discount).to be_nil
      expect(product5.discount).to be_nil
    end
  end

  shared_examples 'an eligible discount for exactly double threshold' do
    let(:products) { [product1, product2, product3, product4, product5, product6] }

    it 'applies the discount only to discountable products' do
      subject.apply(products)

      expect(product1.discount).to eq(100)
      expect(product2.discount).to eq(100)
      expect(product3.discount).to be_nil
      expect(product4.discount).to be_nil
      expect(product5.discount).to be_nil
      expect(product6.discount).to be_nil
    end
  end

  shared_examples 'an eligible discount for more than double threshold' do
    let(:products) { [product1, product2, product3, product4, product5, product6, product7] }

    it 'applies the discount only to discountable products' do
      subject.apply(products)

      expect(product1.discount).to eq(100)
      expect(product2.discount).to eq(100)
      expect(product3.discount).to be_nil
      expect(product4.discount).to be_nil
      expect(product5.discount).to be_nil
      expect(product6.discount).to be_nil
      expect(product7.discount).to be_nil
    end
  end

  describe '#apply' do
    subject { described_class.new(discount_json) }

    context 'when there are no matching products in the products list' do
      let(:products) { [other_product1, other_product2, other_product3] }

      it 'does not apply any discount' do
        expect(subject).not_to receive(:discount_products)

        subject.apply(products)

        products.each { |product| expect(product.discount).to be_nil }
      end
    end

    context 'when there are matching products in the products list' do
      context 'when there are other products in the products list' do
        let(:products) { [product1, product2, other_product1, other_product2, other_product3] }

        context 'when the discount is not eligible' do
          it 'does not apply any discount' do
            expect(subject).not_to receive(:discount_products)

            subject.apply(products)

            products.each { |product| expect(product.discount).to be_nil }
          end
        end

        context 'when the discount is eligible' do
          before { products << product3 }

          it 'applies the discount only to discountable products' do
            subject.apply(products)

            expect(product1.discount).to eq(100)
            expect(product2.discount).to be_nil
            expect(product3.discount).to be_nil
            expect(other_product1.discount).to be_nil
            expect(other_product2.discount).to be_nil
            expect(other_product3.discount).to be_nil
          end
        end
      end

      context 'when the discount is eligible' do
        context 'when there are less matching products than double threshold' do
          it_behaves_like 'an eligible discount for less than double threshold'
        end

        context 'when there are exactly as many matching products as double threshold' do
          it_behaves_like 'an eligible discount for exactly double threshold'
        end

        context 'when there are more matching products than double threshold' do
          it_behaves_like 'an eligible discount for more than double threshold'
        end

        context 'when products already have discounts' do
          before do
            product1.discount = 100
          end

          context 'when there are less matching products than double threshold' do
            it_behaves_like 'an eligible discount for less than double threshold'
          end

          context 'when there are exactly as many matching products as double threshold' do
            it_behaves_like 'an eligible discount for exactly double threshold'
          end

          context 'when there are more matching products than double threshold' do
            it_behaves_like 'an eligible discount for more than double threshold'
          end
        end
      end

      context 'when the discount is not eligible' do
        let(:products) { [product1, product2, other_product1] }

        before { other_product1.discount = 100 }

        it 'does not apply any discounts and removes existing ones' do
          subject.apply(products)

          expect(product1.discount).to be_nil
          expect(product2.discount).to be_nil
          expect(other_product1.discount).to eq(100)
        end
      end
    end
  end

  describe '#validate_free_quantity' do
    subject { described_class.new(discount_json) }

    context 'when the free quantity is not specified' do
      before do
        discount_json['free_quantity'] = nil
      end

      it 'raises an error' do
        expect { subject.send(:validate_free_quantity) }.to raise_error('Free quantity not specified')
      end
    end

    context 'when the free quantity is not a positive integer' do
      before do
        discount_json['free_quantity'] = 'abc'
      end

      it 'raises an error' do
        expect { subject.send(:validate_free_quantity) }.to raise_error('Free quantity should be a positive integer')
      end
    end

    context 'when the free quantity is greater than or equal to the threshold quantity' do
      before do
        discount_json['free_quantity'] = 2
        discount_json['threshold_quantity'] = 2
      end

      it 'raises an error' do
        expect do
          subject.send(:validate_free_quantity)
        end.to raise_error('Free quantity should be less than threshold quantity')
      end
    end
  end
end
