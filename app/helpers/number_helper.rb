module NumberHelper
  def decimal_to_two_digits(number)
    ((number * 10000).floor) / 100.0
  end
end
