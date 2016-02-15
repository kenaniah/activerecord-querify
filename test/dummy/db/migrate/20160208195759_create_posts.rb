class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.belongs_to :author, index: true, foreign_key: true
      t.string :name
      t.integer :comments_count

      t.timestamps null: false
    end
  end
end
