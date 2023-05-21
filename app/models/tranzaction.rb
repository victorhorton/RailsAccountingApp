class Tranzaction < ApplicationRecord
	belongs_to :batch
	has_many :entries

	accepts_nested_attributes_for :entries

	validates_presence_of :company_id, :date
	validate :entries_cancel?
	validates_associated :entries, message: lambda { |obj_class, obj|
		return obj[:value].map{|t| t.errors.full_messages}.flatten.compact.join(', ')
	}

	def credit_entries
		entries.select{|entry| entry.entry_type == 'credit'}
	end

	def debit_entries
		entries.select{|entry| entry.entry_type == 'debit'}
	end

	def credit_total
		credit_entries.pluck(:amount).compact.sum
	end

	def debit_total
		debit_entries.pluck(:amount).compact.sum
	end

	private

	def entries_cancel?
		errors.add(:base, "Transaction doesn't balance") if credit_total != debit_total
	end
end
