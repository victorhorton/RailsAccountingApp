class Tranzaction < ApplicationRecord
	belongs_to :batch
	has_many :entries
end
