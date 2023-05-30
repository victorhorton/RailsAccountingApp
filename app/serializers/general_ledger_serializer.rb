class GeneralLedgerSerializer < ActiveModel::Serializer
  attributes :id, :name, :comment, :purpose, :posted_at, :tranzactions_attributes

  def tranzactions_attributes
    if object.tranzactions.blank?
      return [{
        tranzaction_type: 'general',
        entries_attributes: [{designation: 'distribution', position: 1}]
      }]
    else
      return object.tranzactions.map{ |tranzaction|
        {
          id: tranzaction.id,
          company_id: tranzaction.company_id,
          date: tranzaction.date,
          tranzaction_type: 'general',
          entries_attributes: tranzaction.entries.map{ |entry|
            {
              id: entry.id,
              account_id: entry.account_id,
              entry_type: entry.entry_type,
              amount: entry.amount.to_i,
              designation: entry.designation,
              position: entry.position,
            }
          }
        }
      }
    end
  end
end
