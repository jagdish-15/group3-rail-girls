class BookingsController < ApplicationController
  before_action :set_event, only: %i[ new create ]

  def new
    @booking = Booking.new
    @taken = @event.bookings.flat_map(&:seat_list)
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
      @taken = @event.bookings.where.not(id: nil).flat_map(&:seat_list)
      render :new, status: :unprocessable_content
    end
  end

  def show
    @booking = Current.user.bookings.find(params[:id])
  end

  def update
    @booking = Current.user.bookings.find(params[:id])
    @booking.update!(status: "confirmed", booked_at: Time.current)
    redirect_to @booking, notice: "Payment successful! (not really)"
  end

  private
    def set_event
      @event = Event.find(params[:event_id])
    end
end
