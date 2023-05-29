module FormatHelper
  def moneyfy(amount)
    number_to_currency(amount, unit: '')
  end
end
