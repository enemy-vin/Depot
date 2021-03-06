require 'test_helper'

class ProductTest < ActiveSupport::TestCase
  # load test data in products table
  fixtures :products

  test "product attributes must not be empty" do
  # свойства товара не должны оставаться пустыми
    product = Product.new
    assert product.invalid?
    assert product.errors[:title].any?
    assert product.errors[:description].any?
    assert product.errors[:price].any?
    assert product.errors[:image_url].any?
  end

  test "product price must be positive" do
  # цена товара должна быть положительной
    product = Product.new(title: "My Book Title",
                          description: "yyy",
                          image_url: "zzz.jpg")
    product.price = -1
    assert product.invalid?
    # должна быть больше или равна 0.01
    assert_equal ["must be greater than or equal to 0.01"],
    product.errors[:price]

    product.price = 0
    assert product.invalid?
    assert_equal ["must be greater than or equal to 0.01"],
    product.errors[:price]

    product.price = 1
    assert product.valid?
  end

  def new_product(image_url)
    Product.new(title: "My Book Title",
                description: "yyy",
                price: 1,
                image_url: image_url)
  end

  test "image url" do
  # url изображения
    ok = %w{ fred.gif fred.jpg fred.png FRED.JPG FRED.Jpg
            http://a.b.c/x/y/z/fred.gif }
    bad = %w{ fred.doc fred.gif/more fred.gif.more }

    ok.each do |name|
      assert new_product(name).valid?, "#{name} shouldn't be invalid"
  # не должно быть неприемлемым
    end

    bad.each do |name|
      assert new_product(name).invalid?, "#{name} shouldn't be valid"
  # не должно быть приемлемым
    end
  end

  test "product is not valid without a unique title" do
  # если у товара нет уникального названия, то он недопустим
    product = Product.new(title: products(:ruby).title,
                          description: "yyy",
                          price: 1,
                          image_url: "fred.gif")
    assert product.invalid?

    # уже было использовано
    assert_equal ["has already been taken"], product.errors[:title]
  end

  test "product is not valid without a unique title - i18n" do
    # если у товара нет уникального названия, то он недопустим
    product = Product.new(title: products(:ruby).title,
                          description: "yyy",
                          price: 1,
                          image_url: "fred.gif")
    assert product.invalid?

    #assert_equal [I18n.translate('activerecord.errors.messages.taken')],
     #            product.errors[:title]
  end

  test "product title must be at least 10 character long" do
    product = Product.new(title: products(:ruby).title,
                          description: "description",
                          price: 1,
                          image_url: "img.png")
    assert product.invalid?

    product.title = "Any Title"

    assert product.invalid?

    min_title_size = Product.validators_on(:title).select {
        |v| v.class == ActiveModel::Validations::LengthValidator
    }.first.options[:minimum]
    assert_equal ["must have at least #{min_title_size} characters"],
                 product.errors[:title]
  end
end
