class CreateDailyReports < ActiveRecord::Migration[5.2]
  def change
    create_table :daily_reports do |t|
      t.date :date
      t.integer :count

      t.timestamps
    end
  end
end
