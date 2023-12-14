require 'spec_helper'
require_relative '../../loaders/products'

describe Loaders::Products do
  let(:config_file) { 'config.json' }
  
  describe '#initialize' do
    context 'when products are found in the config file' do
      it 'loads the products' do
        expect(subject.products).not_to be_empty
      end
    end
    
    context 'when no products are found in the config file' do
      before do 
        allow(JSON).to receive(:parse).with(anything).and_return({ 'products' => [] })
      end

      it 'raises an error' do
        expect { described_class.new }.to raise_error('No products found in config!')
      end
    end
  end

  describe '#by_code' do
    let(:products) { subject.products }

    context 'when a product with the given code exists' do
      it 'returns a duplicate of the product' do
        product = products.first
        duplicate_product = subject.by_code(product['code'])

        expect(duplicate_product).to eq(product)
        expect(duplicate_product).not_to be(product)
      end
    end

    context 'when no product with the given code exists' do
      it 'returns nil' do
        non_existing_code = 'XYZ'
        product = subject.by_code(non_existing_code)

        expect(product).to be_nil
      end
    end
  end
end