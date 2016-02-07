class CreateTestDummies < ActiveRecord::Migration
  def change
    create_table :test_dummies do |t|

      t.timestamps null: false
    end
  end
end
