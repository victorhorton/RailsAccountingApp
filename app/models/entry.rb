class Entry < ApplicationRecord
	acts_as_paranoid
	
	belongs_to :tranzaction
	belongs_to :account
	validates_presence_of :account_id, :entry_type, :amount, :designation

	enum :entry_type, {
		debit: 0,
		credit: 1,
	}

	enum :designation, {
		primary: 0,
		distribution: 1,
	}

  def checkify
    strings = amount.to_s.split(/\./)
    whole_number = strings[0].to_i.humanize.capitalize
    if strings[1] == nil
      decimal_number = '00'
    elsif strings[1].length == 1
      decimal_number = strings[1] + '0'
    else
      decimal_number = strings[1]
    end
    return "#{whole_number} and #{decimal_number}/100"
  end

end
