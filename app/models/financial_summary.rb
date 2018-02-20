class FinancialSummary
  include ConfigHelper

  attr_accessor :user_id, :currency

  def initialize(user_id: , currency: )
    @user_id = user_id
    @currency = currency.to_s.upcase
  end 

  def one_day
    @transactions = transactions.where("created_at >= ? ", Time.now - 1.day)
    self
  end

  def seven_days
    @transactions = transactions.where("created_at >= ? ", Time.now - 7.days)
    self
  end

  def lifetime
    @transactions = transactions
    self
  end

  def count(category)
    @transactions.where("category = ?", category).count
  end 

  def amount(category)
    @transactions.where("category = ?", category).inject(0){|sum,t|sum + t.amount}
  end

  def total_amount
    @transactions.inject(0) do |sum,t|
        if t.category.in? ConfigHelper::TRANSACTION_CREDIT
           sum + t.amount
        elsif t.category.in? ConfigHelper::TRANSACTION_DEBIT
           sum - t.amount
        end

    end 
  end

  def total_count
    @transactions.count
  end

  private

  def transactions
      Transaction.where("user_id = ? and amount_currency = ?",  @user_id, @currency)
  end 

end