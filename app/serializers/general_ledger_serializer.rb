class GeneralLedgerSerializer < ActiveModel::Serializer
  attributes :id, :name, :comment, :purpose, :posted_at, :tranzactions_attributes

  def tranzactions_attributes
    if object.tranzactions.blank?
      return [{entries: [{designation: 'distribution'}]}]
    else
      return object.tranzactions.map{ |tranzaction|
        {
          id: tranzaction.id,
          company_id: tranzaction.company_id,
          date: tranzaction.date,
          entries_attributes: tranzaction.entries.map{ |entry|
            {
              id: entry.id,
              account_id: entry.account_id,
              entry_type: entry.entry_type,
              amount: entry.amount,
              designation: entry.designation,
            }
          }
        }
      }
    end
  end
end
