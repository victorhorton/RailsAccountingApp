class DirectedBatchSerializer < ActiveModel::Serializer
  attributes :id, :reference_number, :company_id, :date, :entries_attributes, :batch_id

  def entries_attributes

    batch_purpose = Batch.find(object.batch_id).purpose
    if batch_purpose == 'payable'
      primary_account_id = 2010
      primary_type = 'credit'
      reversed_type = 'debit'
    else
      primary_account_id = 2010
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
end
