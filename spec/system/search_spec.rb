require "rails_helper"

RSpec.describe "/search", type: :system do
  before do
    driven_by(:selenium_chrome_headless)
    11.times { create :sorn }
  end

  it "default checkboxes are as expected" do
    visit "/search"

    Sorn::DEFAULT_FIELDS.each do |default_field|
      expect(find("#fields-#{default_field}")).to be_checked
    end

    expect(find("#fields-routine_uses")).not_to be_checked
  end

  it "selected agencies are still checked after a search" do
    visit "/search?agencies[]=Fake+Parent+Agency&fields[]=system_name"
    expect(find("#agencies-fake-parent-agency")).to be_checked
  end

  it "applies the agency-separator class to the agency pipe separator" do
    visit "/search"

    expect(page).to have_css '.agency-separator'
  end

  scenario "publication date validation" do
    visit "/search"

    find("#publication-year-button").click
    within "#publication-date-fields" do
      fill_in "Starting year", with: "2020"
      fill_in "Ending year", with: "2019"
    end
    find("#general-search-button").click

    message = find("#starting_year").native.attribute("validationMessage")
    expect(message).to eq "Starting year should be earlier than the ending year."

    # Fix the years and submit should work
    within "#publication-date-fields" do
      fill_in "Starting year", with: "2019"
      fill_in "Ending year", with: "2020"
    end
    find("#general-search-button").click
    message = find("#starting_year").native.attribute("validationMessage")
    expect(message).to eq ""

    visit "/search"
    find("#publication-year-button").click
    # Just a starting year should work
    within "#publication-date-fields" do
      fill_in "Starting year", with: "2019"
    end
    find("#general-search-button").click
    message = find("#starting_year").native.attribute("validationMessage")
    expect(message).to eq ""

    visit "/search"
    find("#publication-year-button").click
    # Just an ending year should work
    within "#publication-date-fields" do
      fill_in "Ending year", with: "2019"
    end
    find("#general-search-button").click
    # validation message is always on starting year
    message = find("#starting_year").native.attribute("validationMessage")
    expect(message).to eq ""
  end

  scenario "paging doesn't break js" do
    visit "/"
    find_all("nav.pagination").first.find_all(".page")[1].click
    sleep 1
    # gov banner should remain closed
    expect(find("#gov-banner").visible?).to be_falsey
  end
end