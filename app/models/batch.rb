class Batch < ApplicationRecord

	has_many :tranzactions
	has_many :entries, through: :tranzactions

	accepts_nested_attributes_for :tranzactions

	enum :purpose, {
		accounts_payable: 0,
		accounts_receivable: 1,
		general_ledger: 2,
	}

end
