class CreateMovies < ActiveRecord::Migration[Rails.version.to_f]
  def up
    create_table :movies, if_not_exists: true do |t|
      t.string :title
      t.string :rating
      t.text :description
      t.datetime :release_date
      # Add fields that let Rails automatically keep track
      # of when movies are added or modified:
      t.timestamps
    end
  end

  def down
    drop_table :movies, if_exists: true
  end
end
