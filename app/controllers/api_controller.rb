class ApiController < ApplicationController

  def index
      test = FinancialSummary.new(user_id: 1, currency: "USD")

      puts "--- tes test"
      puts test.one_day.count(:deposit)
       # puts test.one_day.amount(:deposit)
  end

end 