class DirectedBatchSerializer < ActiveModel::Serializer
  attributes :id, :company_id, :date, :entries_attributes

  def entries_attributes
    if object.entries.blank?
      return [
        {designation: 'primary', position: 1, account_id: 2010},
        {designation: 'distribution', position: 2}
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
