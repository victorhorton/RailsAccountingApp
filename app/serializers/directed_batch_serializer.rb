class DirectedBatchSerializer < ActiveModel::Serializer
  attributes :id,
    :reference_number,
    :company_id,
    :contact_id,
    :tranzaction_type,
    :date,
    :entries_attributes,
    :batch_id,
    :payments_attributes

  def tranzaction_type
    return object.tranzaction_type || 'general'
  end

  def entries_attributes

    batch_purpose = Batch.find(object.batch_id).purpose
    if batch_purpose == 'payable'
      primary_account_id = 2010
      primary_type = 'credit'
      reversed_type = 'debit'
    else
      primary_account_id = 1200
      primary_type = 'debit'
      reversed_type = 'credit'
    end

    if object.entries.blank?
      return [
        {designation: 'primary', position: 1, account_id: primary_account_id, entry_type: primary_type},
        {designation: 'distribution', position: 2, entry_type: reversed_type}
      ]
    else
      return object.entries.map{ |entry|
        {
          id: entry.id,
          account_id: entry.account_id,
          entry_type: entry.entry_type,
          amount: entry.amount.to_i,
          designation: entry.designation,
          position: entry.position,
        }
      }
    end
  end

  def payments_attributes

    batch_purpose = Batch.find(object.batch_id).purpose
    if batch_purpose == 'payable'
      primary_account_id = 2010
      primary_type = 'credit'
      reversed_type = 'debit'
      payment_type = 'check'
    else
      primary_account_id = 1200
      primary_type = 'debit'
      reversed_type = 'credit'
      payment_type = 'receipt'
    end

    if object.payments.blank?
      return [
        {
          payment_type: payment_type,
          tranzaction_attributes: {
            tranzaction_type: 'payment',
            batch_id: object.batch_id,
            company_id: object.company_id,
            entries_attributes: [
              {designation: 'primary', position: 1, account_id: primary_account_id, entry_type: reversed_type},
              {designation: 'distribution', position: 2, entry_type: primary_type}
            ]
          }
        }
      ]
    else
      return object.payments.map{ |payment|
        {
          id: payment.id,
          payment_type: payment.payment_type,
          addressee: payment.addressee,
          memo: payment.memo,
          tranzaction_attributes: {
            id: payment.tranzaction.id,
            reference_number: payment.tranzaction.reference_number,
            company_id: payment.tranzaction.company_id,
            date: payment.tranzaction.date,
            tranzaction_type: payment.payment_type || 'payment',
            entries_attributes: payment.tranzaction.entries.map{|entry|
              {
                id: entry.id,
                account_id: entry.account_id,
                entry_type: entry.entry_type,
                amount: entry.amount.to_i,
                designation: entry.designation,
                position: entry.position,
              }
            },
          }
        }
      }
    end
  end

end
