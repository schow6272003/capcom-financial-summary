class FinancialSummary

  attr_accessor :user_id, :currency

  def initialize(user_id: , currency: )
    @user_id = user_id
    @currency = currency.to_s.upcase
    @user = User.find(user_id)
  end 

  def one_day
    @transaction = Transaction.where("user_id = ? and created_at between ? and ? and amount_currency = ?",  @user.id, Time.now - 1.day, Time.now, @currency)
    self
  end

  def seven_days
    @transaction = Transaction.where("user_id = ? and created_at between ? and ? and amount_currency = ?",  @user.id, Time.now - 7.days, Time.now, @currency)
    self
  end

  def lifetime
    @transaction = Transaction.where("user_id = ? and  amount_currency = ?",  @user.id, @currency)
    self
  end

  def count(category)
    @transaction.where("category = ?", category).count
  end 

  def amount(category)
    @transaction.where("category = ?", category).inject(0){|sum,x|sum + x.amount}
  end

end