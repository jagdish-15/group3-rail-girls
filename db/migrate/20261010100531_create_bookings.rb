class CreateBookings < ActiveRecord::Migration[8.0]
  def change
    create_table :bookings do |t|
      t.references :user, null: false, foreign_key: true
      t.references :event, null: false, foreign_key: true
      t.string :seats
      t.string :status
      t.datetime :booked_at

      t.timestamps
    end
  end
end
