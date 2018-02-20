class Transaction < ApplicationRecord
  include ConfigHelper
  monetize :amount_cents

  validate :action_category_match
  validate :must_be_greater_than_zero

  belongs_to :user

  after_save :make_immutable
  after_find :make_immutable

  private

  def action_category_match
    if action.to_sym == :credit
      if !ConfigHelper::TRANSACTION_CREDIT.include?(category)
        errors.add(:base, 'Credits must be in category deposit, refund or purchase.')
      end
    elsif action.to_sym == :debit
      if !ConfigHelper::TRANSACTION_DEBIT.include?(category)
        errors.add(:base, 'Debits must be in category withdraw or ante.')
      end
    end
  end

  def must_be_greater_than_zero
    errors.add(:amount, 'Must be greater than 0') if amount <= Money.from_amount(0, amount_currency)
  end

  def make_immutable
    self.readonly!
  end
end