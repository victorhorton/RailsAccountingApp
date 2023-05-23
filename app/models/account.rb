class Account < ApplicationRecord

	has_many :entries, dependent: :restrict_with_error

	enum :account_type, {
		asset: 0,
		liability: 1
	}

end
