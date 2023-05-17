class BatchSerializer < ActiveModel::Serializer
  attributes :id, :name, :comment, :purpose, :posted_at, :tranzactions

  def tranzactions
    if object.tranzactions.blank?
      return [{entries: [{designation: 'distribution'}]}]
    else
      object.tranzactions
    end
  end
end
