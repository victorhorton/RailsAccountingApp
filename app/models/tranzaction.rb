class Tranzaction < ApplicationRecord
	acts_as_paranoid
	
	belongs_to :batch
	belongs_to :company
	belongs_to :contact, optional: true
	has_one :payment, dependent: :destroy
	has_many :entries, dependent: :destroy
	has_and_belongs_to_many :payments

	accepts_nested_attributes_for :entries
	accepts_nested_attributes_for :payments

	validates_presence_of :contact_id, if: :not_gl
	validates_presence_of :company_id, :date
	validate :entries_cancel?
	validates_associated :entries, message: lambda { |obj_class, obj|
		return obj[:value].map{|t| t.errors.full_messages}.flatten.compact.uniq.join(', ')
	}

  enum :tranzaction_type, {
    general: 0,
    payment: 1,
  }

	def check_payments
		payments.select{|payment| payment.payment_type == 'check'}
	end

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

	def document_amount
		primary_entry.amount
	end

	def primary_entry
		entries.find{|entry| entry.designation == 'primary'}
	end

	private

	def not_gl
		batch.purpose != 'general_ledger'
	end

	def entries_cancel?
		errors.add(:base, "Transaction doesn't balance") if credit_total != debit_total
	end
end
