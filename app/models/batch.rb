class Batch < ApplicationRecord
	acts_as_paranoid

	after_save :post_payment, if: [:posting?, :is_directed_batch?]

	has_many :entries, through: :tranzactions
	has_many :tranzactions, dependent: :destroy

	accepts_nested_attributes_for :tranzactions

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
		tranzactions.each do |tranzaction|
			tranzaction.payments.each do |payment|
				payment.tranzaction.batch.update(posted_at: self.posted_at)
			end
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
