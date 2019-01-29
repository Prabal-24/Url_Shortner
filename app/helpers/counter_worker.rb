class CounterWorker
  include Sidekiq::Worker
  def perform
    @today_short_url_created = DailyReport.last
		if @today_short_url_created.nil?
			@today_short_url_created = DailyReport.new
			@today_short_url_created.date = Date.today
			@today_short_url_created.count = 1
			@today_short_url_created.save
		else
			if @today_short_url_created.date == Date.today
				@today_short_url_created.count +=1
				@today_short_url_created.save
			else
				@today_short_url_created = DailyReport.new
				@today_short_url_created.date = Date.today
				@today_short_url_created.count = 1
				@today_short_url_created.save
			end
		end
  end
end
