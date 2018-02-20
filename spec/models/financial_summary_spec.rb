require 'rails_helper'

describe FinancialSummary do
  let!(:user) { create(:user) }
  let!(:user2) { create(:user) }

  # Feel free to change what the subject-block returns
  subject { FinancialSummary.new(user_id: user.id, currency: :usd) }

  describe "Financial Summary over one day" do
        it 'summarizes over one day' do
          Timecop.freeze(Time.now) do
            create(:transaction, user: user,
                   action: :credit, category: :deposit,
                   amount: Money.from_amount(2.12, :usd))

            create(:transaction, user: user,
                   action: :credit, category: :deposit,
                   amount: Money.from_amount(10, :usd))

            create(:transaction, user: user,
                   action: :credit, category: :purchase,
                   amount: Money.from_amount(7.67, :usd))

            create(:transaction, user: user,
                   action: :debit, category: :withdraw,
                   amount: Money.from_amount(10, :usd))
            create(:transaction, user: user,
                   action: :debit, category: :ante,
                   amount: Money.from_amount(5.94, :usd))
            create(:transaction, user: user,
                   action: :credit, category: :deposit,
                   amount: Money.from_amount(100.00, :usd))

          end

          Timecop.travel(Time.now - 10.days) do
            create(:transaction, user: user,
                   action: :credit, category: :deposit,
                   amount: Money.from_amount(3.12, :usd))

            create(:transaction, user: user,
                   action: :credit, category: :deposit,
                   amount: Money.from_amount(10, :usd))

            create(:transaction, user: user,
                   action: :credit, category: :purchase,
                   amount: Money.from_amount(2.67, :usd))
          end

          # pending('Not implemented yet')

          expect(subject.one_day.count(:deposit)).to eq(3)
          expect(subject.one_day.amount(:deposit)).to eq(Money.from_amount(112.12, :usd))

          expect(subject.one_day.count(:purchase)).to eq(1)
          expect(subject.one_day.amount(:purchase)).to eq(Money.from_amount(7.67, :usd))

          expect(subject.one_day.count(:refund)).to eq(0)
          expect(subject.one_day.amount(:refund)).to eq(Money.from_amount(0, :usd))

          expect(subject.one_day.total_amount).to eq(Money.from_amount(103.85, :usd))
          expect(subject.one_day.total_count).to eq(6)
        end

        it "only shows transaction from one user"  do
          Timecop.freeze(Time.now) do
            create(:transaction, user: user,
                   action: :credit, category: :deposit,
                   amount: Money.from_amount(3.22, :usd))

            create(:transaction, user: user,
                   action: :credit, category: :deposit,
                   amount: Money.from_amount(10, :usd))

            create(:transaction, user: user2,
                   action: :credit, category: :deposit,
                   amount: Money.from_amount(8.90, :usd))

            create(:transaction, user: user2,
                   action: :credit, category: :deposit,
                   amount: Money.from_amount(5, :usd))
          end
          expect(subject.one_day.amount(:deposit)).to eq(Money.from_amount(13.22, :usd))
          expect(subject.one_day.amount(:deposit)).not_to eq(Money.from_amount(27.22, :usd))
        end 
   end


  it 'summarizes over seven days' do
    Timecop.freeze(Time.now) do
      create(:transaction, user: user,
             action: :credit, category: :deposit,
             amount: Money.from_amount(2.12, :usd))

      create(:transaction, user: user,
             action: :credit, category: :deposit,
             amount: Money.from_amount(10, :usd))
    end
    Timecop.freeze(Time.now - 5.days) do
      create(:transaction, user: user,
             action: :credit, category: :purchase,
             amount: Money.from_amount(3.22, :usd))

      create(:transaction, user: user,
             action: :credit, category: :refund,
             amount: Money.from_amount(105, :usd))
      create(:transaction, user: user,
             action: :credit, category: :purchase,
             amount: Money.from_amount(22.45, :usd))
      create(:transaction, user: user,
             action: :debit, category: :ante,
             amount: Money.from_amount(34, :usd))
      create(:transaction, user: user,
             action: :debit, category: :withdraw,
             amount: Money.from_amount(21, :usd))
        create(:transaction, user: user,
             action: :debit, category: :withdraw,
             amount: Money.from_amount(23, :cad))
    end


    Timecop.travel(Time.now - 10.days) do
      create(:transaction, user: user,
             action: :credit, category: :purchase,
             amount: Money.from_amount(131, :usd))

      create(:transaction, user: user,
             action: :credit, category: :purchase,
             amount: Money.from_amount(7.67, :usd))

      create(:transaction, user: user,
             action: :credit, category: :refund,
             amount: Money.from_amount(5, :cad))
    end

    # pending('Not implemented yet')

    expect(subject.seven_days.count(:deposit)).to eq(2)
    expect(subject.seven_days.amount(:deposit)).to eq(Money.from_amount(12.12, :usd))

    expect(subject.seven_days.count(:purchase)).to eq(2)
    expect(subject.seven_days.amount(:purchase)).to eq(Money.from_amount(25.67, :usd))

    expect(subject.seven_days.count(:refund)).to eq(1)
    expect(subject.seven_days.amount(:refund)).to eq(Money.from_amount(105, :usd))

    expect(subject.seven_days.total_amount).to eq(Money.from_amount(87.79, :usd))
    expect(subject.seven_days.total_count).to eq(7)

  end

  it 'summarizes over lifetime' do
    Timecop.freeze(Time.now) do
      create(:transaction, user: user,
             action: :credit, category: :deposit,
             amount: Money.from_amount(2.12, :usd))

      create(:transaction, user: user,
             action: :credit, category: :deposit,
             amount: Money.from_amount(10, :usd))
    end

    Timecop.travel(Time.now - 30.days) do
      create(:transaction, user: user,
             action: :credit, category: :purchase,
             amount: Money.from_amount(131, :usd))

      create(:transaction, user: user,
             action: :debit, category: :withdraw,
             amount: Money.from_amount(7.67, :usd))

      create(:transaction, user: user,
             action: :credit, category: :refund,
             amount: Money.from_amount(5, :cad))

      create(:transaction, user: user,
             action: :credit, category: :refund,
             amount: Money.from_amount(13.45, :usd))
    end


    # pending('Not implemented yet')

    expect(subject.lifetime.count(:deposit)).to eq(2)
    expect(subject.lifetime.amount(:deposit)).to eq(Money.from_amount(12.12, :usd))

    expect(subject.lifetime.count(:purchase)).to eq(1)
    expect(subject.lifetime.amount(:purchase)).to eq(Money.from_amount(131.00, :usd))

    expect(subject.lifetime.count(:refund)).to eq(1)
    expect(subject.lifetime.amount(:refund)).to eq(Money.from_amount(13.45, :usd))

    expect(subject.lifetime.count(:withdraw)).to eq(1)
    expect(subject.lifetime.amount(:withdraw)).to eq(Money.from_amount(7.67, :usd))

    expect(subject.lifetime.total_count).to eq(5)
    expect(subject.lifetime.total_amount).to eq(Money.from_amount(148.9, :usd))
  end
end