class CreateAuthors < ActiveRecord::Migration
  def change
    create_table :authors do |t|
      t.string :name
      t.integer :posts_count
      t.integer :comments_count

      t.timestamps null: false
    end
  end
end
