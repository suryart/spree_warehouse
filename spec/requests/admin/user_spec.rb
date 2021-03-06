require 'spec_helper'

describe "Users" do
  stub_authorization!

  before(:each) do
    create(:user, :email => "a@example.com")
    create(:user, :email => "b@example.com")
    visit spree.admin_path
    click_link "Users"
  end

  context "users index page with sorting" do
    before(:each) do
      click_link "users_email_title"
    end

    it "should be able to list users with order email asc" do
      page.should have_css 'table#listing_users'
      within("table#listing_users") do
        page.should have_content "a@example.com"
        page.should have_content "b@example.com"
      end
    end

    it "should be able to list users with order email desc" do
      click_link "users_email_title"
      within("table#listing_users") do
        page.should have_content "a@example.com"
        page.should have_content "b@example.com"
      end
    end
  end

  context "searching users" do
    it "should display the correct results for a user search" do
      fill_in "q_email_cont", :with => "a@example.com"
      click_button "Search"
      within("table#listing_users") do
        page.should have_content "a@example.com"
        page.should_not have_content "b@example.com"
      end
    end
  end

  context "editing users" do
    before(:each) do
      click_link "a@example.com"
      click_link "Edit"
    end

    it "should let me edit the user email" do
      fill_in "user_email", :with => "a@example.com99"
      click_button "Update"

      page.should have_content "successfully updated!"
      page.should have_content "a@example.com99"
    end

    it "should let me edit the user password" do
      fill_in "user_password", :with => "welcome"
      fill_in "user_password_confirmation", :with => "welcome"
      click_button "Update"

      page.should have_content "successfully updated!"
    end
  end

  context "API and QR code generation" do
    before do 
      click_link "a@example.com"
      click_link "Edit"
    end

    it "should generate API key and QR code" do
      page.should have_content "No key"
      page.should_not have_content "Generate QR Code"
      page.should have_content "To generate QR code you need to generate API key first"

      click_button "Generate API key"
      page.should have_content "Key generated"
      page.should_not have_content "No key"

      page.should have_content "Generate QR code"
      click_link "Generate QR code"

      #TODO Write better check 
      find("table.qrcode").should be_visible
    end
  end

end