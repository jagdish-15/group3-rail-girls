require "application_system_test_case"

class EventsTest < ApplicationSystemTestCase
  setup do
    @event = events(:one)
  end

  test "visiting the index" do
    visit events_url
    assert_selector "h1", text: "Events"
  end

  test "should create event" do
    visit events_url
    click_on "New event"

    fill_in "Category", with: @event.category
    fill_in "Description", with: @event.description
    fill_in "Duration", with: @event.duration
    fill_in "Image url", with: @event.image_url
    fill_in "Mode", with: @event.mode
    fill_in "Price", with: @event.price
    fill_in "Starts at", with: @event.starts_at
    fill_in "Title", with: @event.title
    fill_in "Venue", with: @event.venue
    click_on "Create Event"

    assert_text "Event was successfully created"
    click_on "Back"
  end

  test "should update Event" do
    visit event_url(@event)
    click_on "Edit this event", match: :first

    fill_in "Category", with: @event.category
    fill_in "Description", with: @event.description
    fill_in "Duration", with: @event.duration
    fill_in "Image url", with: @event.image_url
    fill_in "Mode", with: @event.mode
    fill_in "Price", with: @event.price
    fill_in "Starts at", with: @event.starts_at.to_s
    fill_in "Title", with: @event.title
    fill_in "Venue", with: @event.venue
    click_on "Update Event"

    assert_text "Event was successfully updated"
    click_on "Back"
  end

  test "should destroy Event" do
    visit event_url(@event)
    click_on "Destroy this event", match: :first

    assert_text "Event was successfully destroyed"
  end
end
