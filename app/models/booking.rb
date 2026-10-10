class Booking < ApplicationRecord
  belongs_to :user
  belongs_to :event

  ROWS = ("A".."E").to_a.freeze
  SEATS_PER_ROW = 8
  ALL_SEATS = ROWS.flat_map { |row| (1..SEATS_PER_ROW).map { |n| "#{row}#{n}" } }.freeze
  MAX_SEATS = 5

  validate :seats_are_valid
  validate :seats_are_available, on: :create

  def seat_list
    seats.to_s.split(",")
  end

  def total_price
    seat_list.size * event.price.to_d
  end

  def confirmed?
    status == "confirmed"
  end

  private
    def seats_are_valid
      if seat_list.empty?
        errors.add(:base, "Please pick at least one seat")
      elsif seat_list.size > MAX_SEATS
        errors.add(:base, "You can book at most #{MAX_SEATS} seats")
      elsif (seat_list - ALL_SEATS).any? || seat_list.uniq.size != seat_list.size
        errors.add(:base, "Invalid seat selection")
      end
    end

    def seats_are_available
      return unless event
      taken = event.bookings.where.not(id: id).flat_map(&:seat_list)
      clash = seat_list & taken
      errors.add(:base, "Seat #{clash.to_sentence} just got taken, please pick another") if clash.any?
    end
end
