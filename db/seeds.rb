# db/seeds.rb
#
# Dummy data for building and testing the Event App.
# Run with:  bin/rails db:seed
#
# Safe to run again and again: it clears bookings and events, then
# recreates them. Users are kept (found or created by email).
# Every dummy user's password is: password

srand(42) # same "random" data every time, so everyone sees the same thing

puts "Clearing old bookings and events..."
Booking.delete_all
Event.delete_all

# ---------- Users ----------
puts "Creating users..."

users = [
  ["Demo User",       "demo@example.com"],
  ["Asha Patil",      "asha@example.com"],
  ["Meera Kulkarni",  "meera@example.com"],
  ["Riya Sharma",     "riya@example.com"],
  ["Sneha Deshpande", "sneha@example.com"]
].map do |name, email|
  User.find_or_create_by!(email_address: email) do |user|
    user.name = name
    user.password = "password"
  end
end

# ---------- Events ----------
puts "Creating events..."

events_data = [
  # Music
  { title: "Jazz Night at Koregaon Park", category: "Music", mode: "offline", venue: "Koregaon Park, Pune",
    duration: 120, price: 499, days: 3, hour: 19,
    description: "An evening of live jazz with local bands. Grab a seat early!" },
  { title: "Indie Rock Live", category: "Music", mode: "offline", venue: "Baner, Pune",
    duration: 150, price: 699, days: 10, hour: 20,
    description: "Three indie bands, one stage, and a lot of noise." },
  { title: "Lo-fi Beats Livestream", category: "Music", mode: "online", venue: "Online",
    duration: 60, price: 0, days: 1, hour: 21,
    description: "Relax with a live lo-fi set streamed straight to your laptop." },

  # Tech
  { title: "Pune Ruby Meetup", category: "Tech", mode: "offline", venue: "Hinjewadi, Pune",
    duration: 180, price: 0, days: 7, hour: 10,
    description: "Talks, lightning demos and chai with the Pune Ruby community." },
  { title: "Intro to Hotwire", category: "Tech", mode: "online", venue: "Online",
    duration: 90, price: 199, days: 5, hour: 18,
    description: "Learn how Turbo and Stimulus make Rails apps feel fast." },
  { title: "Women in Tech Panel", category: "Tech", mode: "offline", venue: "Kharadi, Pune",
    duration: 120, price: 149, days: 14, hour: 17,
    description: "Engineers and founders share their journeys and answer your questions." },

  # Comedy
  { title: "Stand-up Saturday", category: "Comedy", mode: "offline", venue: "FC Road, Pune",
    duration: 75, price: 399, days: 2, hour: 20,
    description: "Five comics, fresh material, and no phones allowed." },
  { title: "Open Mic Night", category: "Comedy", mode: "offline", venue: "Viman Nagar, Pune",
    duration: 90, price: 199, days: 6, hour: 19,
    description: "New comedians try their first five minutes on stage. Be kind!" },
  { title: "Improv Online", category: "Comedy", mode: "online", venue: "Online",
    duration: 60, price: 99, days: 4, hour: 21,
    description: "An improv troupe makes up scenes from audience suggestions in chat." },

  # Sports
  { title: "Cricket Screening: India vs Australia", category: "Sports", mode: "offline", venue: "Aundh, Pune",
    duration: 240, price: 299, days: 8, hour: 14,
    description: "Big screen, loud crowd, and snacks. Wear blue!" },
  { title: "Sunday Morning 5K Run", category: "Sports", mode: "offline", venue: "Pashan Lake, Pune",
    duration: 90, price: 249, days: 9, hour: 6,
    description: "A friendly 5K run around Pashan Lake. All paces welcome." },
  { title: "Yoga Live Class", category: "Sports", mode: "online", venue: "Online",
    duration: 45, price: 0, days: 1, hour: 7,
    description: "Start your day with a gentle 45-minute yoga session at home." }
]

# Approximate coordinates for each venue (used for the "distance from you" label)
VENUE_COORDINATES = {
  "Koregaon Park, Pune" => [18.5362, 73.8940],
  "Baner, Pune"         => [18.5590, 73.7868],
  "Hinjewadi, Pune"     => [18.5912, 73.7389],
  "Kharadi, Pune"       => [18.5515, 73.9348],
  "FC Road, Pune"       => [18.5236, 73.8412],
  "Viman Nagar, Pune"   => [18.5679, 73.9143],
  "Aundh, Pune"         => [18.5580, 73.8075],
  "Pashan Lake, Pune"   => [18.5372, 73.7916]
}.freeze

events = events_data.map do |data|
  latitude, longitude = VENUE_COORDINATES[data[:venue]]
  Event.create!(
    data.except(:days, :hour).merge(
      latitude: latitude,
      longitude: longitude,
      starts_at: data[:days].days.from_now.change(hour: data[:hour], min: 0),
      image_url: "https://picsum.photos/seed/#{data[:title].parameterize}/600/400"
    )
  )
end

# ---------- Bookings ----------
puts "Creating bookings..."

# The same seat grid the booking page will draw: rows A-E, seats 1-8
ALL_SEATS = ("A".."E").flat_map { |row| (1..8).map { |n| "#{row}#{n}" } }

# Give the first 8 events a few bookings each, so some seats show as taken
events.first(8).each do |event|
  free_seats = ALL_SEATS.shuffle

  users.sample(rand(1..3)).each do |user|
    seats = free_seats.shift(rand(1..5)) # never more than 5 seats per booking
    confirmed = [true, false].sample

    Booking.create!(
      user: user,
      event: event,
      seats: seats.join(","),
      status: confirmed ? "confirmed" : "pending",
      booked_at: confirmed ? rand(1..48).hours.ago : nil
    )
  end
end

# A known booking for the demo user, handy for testing the checkout page
demo_event = events.last
Booking.create!(
  user: users.first,
  event: demo_event,
  seats: "C3,C4",
  status: "confirmed",
  booked_at: 1.hour.ago
)

puts "Done! #{User.count} users, #{Event.count} events, #{Booking.count} bookings."
puts "Log in with demo@example.com / password"
