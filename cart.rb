# frozen_string_literal: true

require_relative 'loaders/products'
require_relative 'loaders/discounts'

class Cart
  CURRENCY_SYMBOL = '€'
  attr_accessor :products

  def initialize
    @products_loader = ::Loaders::Products.new
    @products_in_shop = @products_loader.products
    @discounts = ::Loaders::Discounts.new.discounts
    @products = []
  end

  def run
    loop do
      print_menu

      option = gets.chomp

      case option
      when '1'
        p 'Enter product code: '
        
        code = gets.chomp

        add_product(product(code))
      when '2'
        p 'Enter product code: '

        code = gets.chomp

        remove_product(product(code))
      when '3'
        if products.empty?
          print "\n\nCart is empty!\n\n"
          next
        end

        print_summary
      when '4'
        print "\n\nThank you and good bye!\n\n"
        break
      else
        p 'Invalid option'
      end
    end
  end

  def total(attribute)
    raise 'Invalid attribute' unless %w[price discount].include?(attribute)

    total = @products.reduce(0) do |total, product|
      value = product[attribute]
      total += value if value

      total
    end

    total || 0
  end

  def print_menu
    print '   Available products:'
    new_line
    print 'CODE      NAME      PRICE'
    new_line
    print '-------------------------'
    new_line

    @products_in_shop.each do |product|
      print "#{product['code']} - #{product['name']} - #{priceify(product['price'])}"
      new_line
    end

    new_line
    new_line
    print '1. Add product'
    new_line
    print '2. Remove product'
    new_line
    print '3. Print cart summary'
    new_line
    print '4. Exit'
    new_line
  end

  def new_line
    print "\n"
  end

  def product(code)
    product = @products_loader.by_code(code)
  end

  def add_product(product)
    products << product

    print "\n\n#{product['name']} added to the cart! \n\n"
  end

  # remove the last product with matching code
  def remove_product(product)
    index_to_remove = products.rindex { |p| p['code'] == product['code'] }

    if index_to_remove
      products.delete_at(index_to_remove)


      print "\n\n #{product['name']} removed from the cart! \n\n"
    else
      print "\n\n#{product['name']} not found in the cart! \n\n"
    end
  end

  def apply_discounts
    return unless @discounts.any?

    @discounts.each do |discount|
      discount.apply(products)
    end
  end

  def priceify(value)
    return unless value

    (value / 100.0).to_s + CURRENCY_SYMBOL
  end

  def print_summary
    apply_discounts

    discounts_total = total('discount')
    prices_total = total('price')
    total = prices_total - discounts_total

    products_rows = products.map do |product|
      "#{product['name']} | #{priceify(product['price'])}    | #{priceify(product['discount'])}"
    end

    summary = 
      <<~SUMMARY


        PRODUCTS: | PRICE:     | DISCOUNT:  
        ----------------------------------
        #{ products_rows.join("\n") }
        ----------------------------------


        Total prices: #{priceify(prices_total)}
        Total discounts: #{priceify(discounts_total)} 

        Total: #{priceify(total)}


      SUMMARY

    print summary
  end
end

# Cart.new.run
