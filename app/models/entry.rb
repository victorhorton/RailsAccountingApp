class Entry < ApplicationRecord

	belongs_to :tranzaction

	enum :entry_type, {
		debit: 0,
		credit: 1,
	}

end
