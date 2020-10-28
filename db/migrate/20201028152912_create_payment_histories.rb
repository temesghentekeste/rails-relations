class CreatePaymentHistories < ActiveRecord::Migration[6.0]
  def change
    create_table :payment_histories do |t|
      t.references :purse, null: false, foreign_key: true

      t.timestamps
    end
  end
end
