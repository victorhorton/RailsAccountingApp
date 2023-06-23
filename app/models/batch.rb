class Batch < ApplicationRecord
	acts_as_paranoid

	after_save :post_payment, if: [:posting?, :is_directed_batch?]

	has_many :entries, through: :tranzactions
	has_many :tranzactions, dependent: :destroy

	has_and_belongs_to_many :payment_batches,
		join_table: :invoices_payments_batch,
		class_name: 'Batch',
		 foreign_key: :invoice_batch_id,
     association_foreign_key: :payment_batch_id
	has_and_belongs_to_many :invoice_batch,
		join_table: :invoices_payments_batch,
		class_name: 'Batch',
		foreign_key: :payment_batch_id,
    association_foreign_key: :invoice_batch_id

	accepts_nested_attributes_for :tranzactions
	accepts_nested_attributes_for :payment_batches

	validates_presence_of :name, :purpose
	validates_associated :tranzactions, message: lambda { |obj_class, obj|
		return obj[:value].map{|t| t.errors.full_messages}.flatten.compact.uniq.join(', ')
	}

	enum :purpose, {
		payable: 0,
		receivable: 1,
		general_ledger: 2,
		payment: 3,
	}

	def self.unposted
		where(posted_at: nil)
	end

	def direceted_tranzactions
		tranzactions.select{|tranzaction|
			tranzaction.payment.nil?
		}
	end

	def is_directed_batch?
		purpose == 'payable' || purpose == 'receivable'
	end

	def post_payment
		payment_batches.each do |payment_batch|
			payment_batch.update(posted_at: self.posted_at)
		end
	end

	def posting?
		saved_changes[:posted_at].present? &&
		saved_changes[:posted_at][0] == nil &&
		saved_changes[:posted_at][1] != nil
	end

	def posted?
		posted_at.nil? ? false : true
	end


	def pending?
		!posted?
	end

end
