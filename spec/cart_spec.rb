# frozen_string_literal: true

require 'spec_helper'
require_relative '../cart'
require_relative '../products/product'

describe Cart do
  let(:product1) { Products::Product.build({ 'code' => 'asd', 'name' => 'Asdberry', 'price' => 1234 }) }
  let(:product2) { Products::Product.build({ 'code' => 'asd', 'name' => 'Asdberry', 'price' => 1234 }) }
  let(:other_product) { Products::Product.build({ 'code' => 'def', 'name' => 'Defruit', 'price' => 1001 }) }
  let(:summary_regexp) { /.*PRODUCTS:\s+\|\s+PRICE:\s+\|\s+DISCOUNT:\s+\|\n.*/ }

  before { allow(::Loaders::Discounts::DiscountConfig).to receive(:load).and_return([]) }

  subject { described_class.new }

  shared_examples 'cart that adds product' do
    it 'prints product added to the cart' do
      expected_output_regexp = /#{Regexp.escape(product.name)} added to the cart/
      expect { subject.add_product(product) }.to output(expected_output_regexp).to_stdout
    end

    include_examples 'cart that calculates discounts'
  end

  shared_examples 'cart that can not find the product' do
    it 'prints product not found in the cart' do
      expected_output = "Product not found in the cart! \n\n"
      expect { subject.remove_product(product) }.to output(expected_output).to_stdout
    end
  end

  shared_examples 'cart that removes product' do
    it 'prints product removed from the cart' do
      expected_output_regexp = /#{Regexp.escape(product.name)} removed from the cart/
      expect { subject.remove_product(product) }.to output(expected_output_regexp).to_stdout
    end

    include_examples 'cart that calculates discounts'
  end

  shared_examples 'cart that calculates discounts' do
    it 'calculates discounts' do
      expect(subject).to receive(:calculate_discounts).and_call_original
      expect(subject).to receive(:clear_discounts)
      expect(subject).to receive(:apply_discounts)

      subject.remove_product(product)
    end
  end

  describe '#add_product' do
    context 'when the cart is empty' do
      let(:product) { product1 }

      it 'adds a product to the cart' do
        expect { subject.add_product(product) }.to change { subject.products }.from([]).to([product])
      end

      it_behaves_like 'cart that adds product'
    end

    context 'when the cart contains other products' do
      let(:product) { product2 }

      before { subject.products = [product1] }

      it 'adds a product to the cart' do
        expect { subject.add_product(product) }.to change { subject.products }.from([product1]).to([product1, product2])
      end

      it_behaves_like 'cart that adds product'
    end

    context 'when the cart already contains the same product' do
      let(:product) { product1 }

      before { subject.products = [product1] }

      it 'adds a product to the cart' do
        expect { subject.add_product(product1) }.to change {
                                                      subject.products
                                                    }.from([product1]).to([product1, product1])
      end

      it_behaves_like 'cart that adds product'
    end

    context 'when whe product is not found' do
      let(:product) { nil }

      it 'does not add a product to the cart' do
        expect { subject.add_product(product) }.not_to(change { subject.products })
      end

      it 'prints product not found' do
        expect { subject.remove_product(product) }.to output(/Product not found/).to_stdout
      end 
    end
  end

  describe '#remove_product' do
    context 'when the cart is empty' do
      let(:product) { product1 }

      it 'does not remove a product from the cart' do
        expect { subject.remove_product(product1) }.not_to(change { subject.products })
      end

      it_behaves_like 'cart that can not find the product'
    end

    context 'when the cart contains other products' do
      let(:product) { product2 }

      before { subject.products = [other_product] }

      it 'does not remove a product from the cart' do
        expect { subject.remove_product(product2) }.not_to(change { subject.products })
      end

      it_behaves_like 'cart that can not find the product'
    end

    context 'when the cart already contains the same products' do
      before { subject.products = [product1, other_product, product2] }

      let(:product) { product1 }

      it 'removes the last product with the same code from the cart' do
        expect { subject.remove_product(product) }.to change { subject.products }
          .from([product1, other_product, product2]).to([product1, other_product])
      end

      it 'calculates discounts' do
        expect(subject).to receive(:calculate_discounts).and_call_original
        expect(subject).to receive(:clear_discounts)
        expect(subject).to receive(:apply_discounts)

        subject.remove_product(product)
      end

      it_behaves_like 'cart that removes product'
    end
  end

  describe '#total' do
    context 'price' do
      context 'when the cart is empty' do
        it 'returns 0' do
          expect(subject.total('price')).to eq(0)
        end
      end

      context 'when the cart contains products' do
        before { subject.products = [product1, product2, other_product] }

        it 'returns the total amount of all products' do
          expect(subject.total('price')).to eq(3469) # 1234 + 1234 + 1001
        end
      end
    end

    context 'discount' do
      context 'when the cart is empty' do
        it 'returns 0' do
          expect(subject.total('discount')).to eq(0)
        end
      end

      context 'when the cart contains products' do
        before { subject.products = [product1, product2, other_product] }

        context 'with discounts' do
          before do
            product1.discount = 100
            product2.discount = 200
            other_product.discount = 300
          end

          it 'returns the total amount of all discounts' do
            expect(subject.total('discount')).to eq(600)
          end
        end

        context 'without discounts' do
          it 'returns the total amount of all discounts' do
            expect(subject.total('discount')).to eq(0)
          end
        end
      end
    end
  end

  describe '#print_summary' do
    context 'when the cart contains products' do
      before { subject.products = [product1, product2, other_product] }

      context 'with discounts' do
        before do
          product1.discount = 100
          product2.discount = 200
          other_product.discount = 300
        end

        it 'prints the cart summary' do
          expected_output_regexp = /Total: 28.69€/
          expect { subject.print_summary }.to output(expected_output_regexp).to_stdout
        end
      end

      context 'without discounts' do
        it 'prints the cart summary' do
          expected_output_regexp = /Total: 34.69€/
          expect { subject.print_summary }.to output(expected_output_regexp).to_stdout
        end
      end
    end
  end

  describe '#run' do
    let(:product1) { Products::Product.build({ 'code' => 'GR1', 'name' => 'Green Tea', 'price' => 1234 }) }
    let(:product2) { Products::Product.build({ 'code' => 'SR1', 'name' => 'Strawberries', 'price' => 4321 }) }

    context 'when user adds a product' do
      before do
        allow_any_instance_of(Cart).to receive(:gets).and_return('1', 'GR1', '4')
        allow(Products::Product).to receive(:build).and_return(product1)
      end

      it 'adds the product to the cart' do
        expect { subject.run }.to change { subject.products }.from([]).to([product1])
      end

      it 'prints a message indicating the product was added' do
        expect { subject.run }.to output(/#{Regexp.escape(product1.name)} added to the cart/m).to_stdout
      end
    end

    context 'when user removes a product' do
      before do
        subject.products = [product1, product2]
        allow_any_instance_of(Cart).to receive(:gets).and_return('2', 'GR1', '4')
      end

      it 'removes the product from the cart' do
        expect { subject.run }.to change { subject.products }.from([product1, product2]).to([product2])
      end

      it 'prints a message indicating the product was removed' do
        expect { subject.run }.to output(/#{Regexp.escape(product1.name)} removed from the cart/m).to_stdout
      end
    end

    context 'when user prints the cart summary' do
      before do
        subject.products = [product1, product2]
        allow_any_instance_of(Cart).to receive(:gets).and_return('3', '4')
      end

      it 'prints the cart summary' do
        expect { subject.run }.to output(/Total: /).to_stdout
      end
    end

    context 'when user selects an invalid option' do
      before do
        allow_any_instance_of(Cart).to receive(:gets).and_return('invalid', '4')
      end

      it 'prints an "Invalid option" message' do
        expect { subject.run }.to output(/Invalid option/).to_stdout
      end
    end

    context 'when user chooses to exit' do
      before do
        allow_any_instance_of(Cart).to receive(:gets).and_return('4')
      end

      it 'exits the loop and ends the run' do
        expect { subject.run }.to output(/Thank you and good bye/).to_stdout
      end
    end
  end
end
