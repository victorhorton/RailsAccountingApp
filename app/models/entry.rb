class Entry < ApplicationRecord

	belongs_to :tranzaction
	validates_presence_of :account_id, :entry_type, :amount, :designation

	enum :entry_type, {
		debit: 0,
		credit: 1,
	}

	enum :designation, {
		primary: 0,
		distribution: 1,
	}

end
