class CreateUrls < ActiveRecord::Migration[5.2]
  def change
    create_table :urls do |t|
      t.string :domain
      t.text :long_url
      t.string :short_url

      t.timestamps
    end
    add_index :urls, :domain
  end
end
