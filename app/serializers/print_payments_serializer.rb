class PrintPaymentsSerializer < ActiveModel::Serializer
  attributes :id, :batch_id, :payments_attributes

  def payments_attributes
    return object.check_payments.map{ |payment|
      {
        id: payment.id,
        tranzaction_attributes: {
          id: payment.tranzaction.id,
        }
      }
    }
  end
end
