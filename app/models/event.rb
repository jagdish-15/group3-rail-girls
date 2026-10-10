class Event < ApplicationRecord
  MODES = %w[offline online].freeze
  CATEGORIES = %w[Music Tech Comedy Sports].freeze

  has_many :bookings, dependent: :destroy

  validates :title, presence: true
  validates :mode, inclusion: { in: MODES }
  validates :duration, numericality: { greater_than: 0 }, allow_nil: true

  def online?
    mode == "online"
  end

  def duration_text
    return "" if duration.blank?
    hours, minutes = duration.divmod(60)
    [("#{hours}h" if hours > 0), ("#{minutes}m" if minutes > 0)].compact.join(" ")
  end
end
