class Contact < ApplicationRecord
  validates_presence_of :name
  has_many :tranzactions
end
