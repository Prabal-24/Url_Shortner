class DailyReportsController < ApplicationController
	def index
		@daily_reports = DailyReport.all
	end
end
