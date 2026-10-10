class BookingsController < ApplicationController
  before_action :expire_stale_bookings
  before_action :set_event, only: %i[ new create ]

  rescue_from ActiveRecord::RecordNotFound do
    redirect_to bookings_path, alert: "That booking has expired or doesn't exist."
  end

  def new
    @booking = Booking.new
    @taken = @event.bookings.active.flat_map(&:seat_list)
  end

  def create
    @booking = @event.bookings.new(
      user: Current.user,
      seats: Array(params[:seats]).join(","),
      status: "pending"
    )

    if @booking.save
      redirect_to @booking
    else
      @taken = @event.bookings.active.where.not(id: nil).flat_map(&:seat_list)
      render :new, status: :unprocessable_content
    end
  end

  def index
    @bookings = Current.user.bookings.includes(:event).order(created_at: :desc)
  end

  def show
    @booking = Current.user.bookings.find(params[:id])
  end

  def update
    @booking = Current.user.bookings.find(params[:id])
    if @booking.pending?
      @booking.update!(status: "confirmed", booked_at: Time.current)
      redirect_to @booking, notice: "Payment successful! Your booking is confirmed."
    else
      redirect_to @booking, alert: "This booking can't be paid for."
    end
  end

  def cancel
    @booking = Current.user.bookings.find(params[:id])
    if @booking.cancelled?
      redirect_to bookings_path, alert: "That booking is already cancelled."
    else
      @booking.update!(status: "cancelled")
      redirect_to refund_booking_path(@booking)
    end
  end

  def refund
    @booking = Current.user.bookings.find(params[:id])
    redirect_to @booking unless @booking.cancelled?
  end

  private
    def expire_stale_bookings
      Booking.expire_stale!
    end

    def set_event
      @event = Event.find(params[:event_id])
    end
end
