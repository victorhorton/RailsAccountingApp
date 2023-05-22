class Account < ApplicationRecord

	has_many :entries

	enum :account_type {
		asset: 0,
		liability: 1
	}

end
