class Commercial::Budget
  attr_accessor :amount, :country, :start_price, :end_price, :lead_price,
                :range

  def initialize(amount, country)
    @amount = amount
    @country = country
  end

  def range
    comma_numbers(@country.price_format % @amount)
  end

  def comma_numbers(number, delimiter = ',')
    number.to_s.reverse.gsub(/([0-9]{3}(?=([0-9])))/, "\\1#{delimiter}").reverse
  end
end
