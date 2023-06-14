class Payment < ApplicationRecord
  has_and_belongs_to_many :invoices, class_name: "Tranzaction"
  belongs_to :tranzaction

  accepts_nested_attributes_for :tranzaction
  accepts_nested_attributes_for :invoices

  enum :payment_type, {
    check: 0,
    wire: 1,
    credit_card: 2,
    receipt: 3,
  }


end
