class BatchSerializer < ActiveModel::Serializer
  attributes :id, :name, :comment, :purpose, :posted_at, :tranzactions

  private

  def tranzactions
    if object.tranzactions.blank?
      return [{entries: [{}]}]
    else
      object.tranzactions
    end
  end

end
