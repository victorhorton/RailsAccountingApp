class Tranzaction < ApplicationRecord
	belongs_to :batch
	has_many :entries

	accepts_nested_attributes_for :entries
end
