class Booking < ApplicationRecord
  belongs_to :user
  belongs_to :event

  ROWS = ("A".."E").to_a.freeze
  SEATS_PER_ROW = 8
  ALL_SEATS = ROWS.flat_map { |row| (1..SEATS_PER_ROW).map { |n| "#{row}#{n}" } }.freeze
  MAX_SEATS = 5
  HOLD_DURATION = 10.minutes

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

  def pending?
    status == "pending"
  end

  def cancelled?
    status == "cancelled"
  end

  def active?
    !cancelled?
  end

  # Seats held by bookings that are neither cancelled nor an expired unpaid hold
  scope :active, -> { where.not(status: "cancelled").where.not(status: "pending", created_at: ...HOLD_DURATION.ago) }

  # Unpaid bookings older than the hold window are removed so the seats open up again
  def self.expire_stale!
    where(status: "pending", created_at: ...HOLD_DURATION.ago).destroy_all
  end

  def expires_at
    created_at + HOLD_DURATION if pending? && created_at
  end

  # booked_at is set when payment is made, so it survives cancellation
  def paid?
    booked_at.present?
  end

  # Only bookings that were paid for get money back
  def refund_amount
    paid? ? total_price : 0
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
      taken = event.bookings.active.where.not(id: id).flat_map(&:seat_list)
      clash = seat_list & taken
      errors.add(:base, "Seat #{clash.to_sentence} just got taken, please pick another") if clash.any?
    end
end
