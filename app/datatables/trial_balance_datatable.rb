class TrialBalanceDatatable < ApplicationDatatable

  def_delegators :@view, :number_to_currency

  def view_columns
    # Declare strings in this format: ModelName.column_name
    # or in aliased_join_table.column_name format
    @view_columns ||= {
      account_id: { source: "Entry.account_id" },
      purpose: { source: "Batch.purpose", cond: filter_type_condition },
      contact: { source: "Contact.name" },
      date: { source: "Tranzaction.date", cond: filter_date_condition },
      reference_number: { source: "Tranzaction.reference_number" },
      company: { source: "Company.code" },
      debit: { source: "Entry.amount", cond: filter_debit_condition },
      credit: { source: "Entry.amount", cond: filter_credit_condition },
    }
  end

  def data
    records.map do |record|
      amount = number_to_currency(record.amount, unit: '')
      {
        account_id: record.account_id,
        purpose: record.tranzaction.batch.purpose.titleize,
        contact: record.tranzaction.contact.try(:name),
        date: record.tranzaction.date.to_fs(:masked),
        reference_number: record.tranzaction.reference_number,
        company: record.tranzaction.company.code,
        debit: record.entry_type == 'debit' ? amount : nil,
        credit: record.entry_type == 'credit' ? amount : nil,
      }
    end
  end

  def get_raw_records
    Entry.eager_load(tranzaction: [:batch, :company, :contact]).where.not(
      tranzactions: {
        batches: {
          posted_at: nil
        }
      }
    )
  end

  private

  def sort_records(records)
    sort_by = datatable.orders.inject([]) do |queries, order|
      column = order.column

      if column.sort_query == 'entries.amount'
        type_order = column.column_name == :debit ? 'DESC' : 'ASC'
        queries << "entries.entry_type #{type_order}"
      end

      queries << order.query(column.sort_query) if column && column.orderable?
      queries
    end
    records.order(Arel.sql(sort_by.join(', ')))
  end

  def filter_debit_condition
    ->(column, value) {
      entries = Arel::Table.new(:entries)
      return entries[:entry_type].matches(0).and(
        entries[:amount].matches(format_amount(column.search.value))
      )
    }
  end

  def filter_credit_condition
    ->(column, value) {
      entries = Arel::Table.new(:entries)
      return entries[:entry_type].matches(1).and(
        entries[:amount].matches(format_amount(column.search.value))
      )
    }
  end

  def filter_date_condition
    ->(column, value) {
      search_date = format_date(value)
      return ::Arel::Nodes::SqlLiteral.new("tranzactions.date").matches("%#{ search_date }%")
    }
  end

  def filter_type_condition
    ->(column, value) {

      batch_purpose = nil

      Batch.purposes.each do |string_purpose, integer_purpose|
        if string_purpose.titleize.downcase.start_with? value.titleize.downcase
          batch_purpose = integer_purpose
        end
      end

      return ::Arel::Nodes::SqlLiteral.new("batches.purpose").eq(batch_purpose)
    }
  end

  def format_amount(amount)
    split_amount = amount.split('.')

    if split_amount.blank?
      return `%`
    end

    whole_number = split_amount[0]
    decimal_number = split_amount[1]

    if whole_number.blank?
      whole_number = "0"
    else
      whole_number = whole_number.gsub(',', '')
    end

    if amount.include?(".") && decimal_number.blank?
      return "#{whole_number}.%"
    elsif decimal_number.blank?
      return "#{whole_number}%"
    else
      return "#{whole_number}.#{decimal_number}%"
    end
  end

  def format_date(date)
    split_date = date.split('-')
    month = split_date[0]
    day = split_date[1]
    year = split_date[2] || Date.current.year.to_s

    if month.present? && month.length == 1
      month = "0#{month}"
    end

    if day.present? && day.length == 1
      day = "0#{day}"
    end

    if year.present? && year.length == 2
      year = "20#{year}"
    end

    if month.present? && day.present? && year.present?
      return "#{year}-#{month}-#{day}"
    elsif month.present? && day.present? && year.nil?
      return "#{month}-#{day}"
    else
      return "#{month}"
    end
  end

  def valid_date(date)
    begin
       Date.strptime(date, '%Y-%m-%d')
       return true
    rescue ArgumentError
       return false
    end
  end

end
