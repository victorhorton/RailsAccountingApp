class Batch < ApplicationRecord
	acts_as_paranoid
	
	has_many :tranzactions, dependent: :destroy
	has_many :entries, through: :tranzactions

	accepts_nested_attributes_for :tranzactions

	validates_presence_of :name, :purpose
	validates_associated :tranzactions, message: lambda { |obj_class, obj|
		return obj[:value].map{|t| t.errors.full_messages}.flatten.compact.join(', ')
	}

	enum :purpose, {
		accounts_payable: 0,
		accounts_receivable: 1,
		general_ledger: 2,
	}

	def self.unposted
		where(posted_at: nil)
	end

end
