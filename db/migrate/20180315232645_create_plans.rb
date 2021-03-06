class CreatePlans < ActiveRecord::Migration[5.1]
  def change
    create_table :plans do |t|
      t.references :user, foreign_key: true
      t.string :name
      t.float :price

      t.timestamps
    end
  end
end
