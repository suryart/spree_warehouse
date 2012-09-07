require 'spec_helper'

describe "Users" do
  stub_authorization!

  before(:each) do
    create(:user, :email => "a@example.com")
    create(:user, :email => "b@example.com")
    visit spree.admin_path
    click_link "Users"
    within('table#listing_users td.user_email') { click_link "a@example.com" }
    click_link "Edit"
    page.should have_content("Editing User")
  end

  it "admin editing email with validation error", :js => true do
    fill_in "user_email", :with => "a"
    click_button "Update"
    sleep 5 
    page.should have_content("Please enter an email address.")
  end

  it "admin editing roles", :js => true do
    sleep 5
    find_field('user_role_admin')['checked'].should be_true
    uncheck "user_role_admin"
    click_button "Update"
    page.should have_content("User has been successfully updated!")
    within('table#listing_users') { click_link "Edit" } 
    find_field('user_role_admin')['checked'].should be_false
  end

  it "listing users when anonymous users are present" do
    Spree.user_class.anonymous!
    click_link "Users"
    page.should_not have_content("@example.net")
  end

  context "API and QR code generation" do
    it "should generate API key and QR code" do
      page.should have_content("No key")
      page.should_not have_content("Generate QR Code")
      click_button "Generate API key"
      page.should have_content("Key generated")
      page.should_not have_content("No key")

      page.should have_content("Generate QR code")
      click_link "Generate QR code"

      #TODO Write better check 
      find("table.qrcode").should be_visible
    end
  end

end