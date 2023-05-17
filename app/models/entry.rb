class Entry < ApplicationRecord

	belongs_to :tranzaction

	enum :entry_type, {
		debit: 0,
		credit: 1,
	}

	enum :designation, {
		primary: 0,
		distribution: 1,
	}

end
