class Batch < ApplicationRecord
	acts_as_paranoid

	has_many :entries, through: :tranzactions
  has_many :payment_batches, class_name: "Batch", foreign_key: "invoice_batch_id"
	has_many :tranzactions, dependent: :destroy

  belongs_to :invoice_batch, class_name: "Batch", optional: true

	accepts_nested_attributes_for :tranzactions

	validates_presence_of :name, :purpose
	validates_associated :tranzactions, message: lambda { |obj_class, obj|
		return obj[:value].map{|t| t.errors.full_messages}.flatten.compact.uniq.join(', ')
	}

	enum :purpose, {
		payable: 0,
		receivable: 1,
		general_ledger: 2,
	}

	def self.unposted
		where(posted_at: nil)
	end

	def direceted_tranzactions
		tranzactions.select{|tranzaction|
			tranzaction.payment.nil?
		}
	end

	def posted?
		posted_at.nil? ? false : true
	end


	def pending?
		!posted?
	end

end
