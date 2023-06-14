class UnpaidTranzactionsSerializer < ActiveModel::Serializer
  attributes :id,
    :reference_number,
    :company_id,
    :contact_id,
    :tranzaction_type,
    :date,
    :pay_off_amount

  def pay_off_amount
    object.pay_off_amount
  end
end
