class Account < ApplicationRecord

	enum :account_type {
		asset: 0,
		liability: 1
	}

end
