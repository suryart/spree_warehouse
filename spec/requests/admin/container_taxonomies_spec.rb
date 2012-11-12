require 'spec_helper'

describe "ContainerTaxonomies" do
  stub_authorization!

  before(:each) do
    visit spree.admin_path
    click_link "Warehouses"
    click_link "Container Taxonomies"
  end

  context "show" do
    it "should display existing taxonomies" do
      Factory(:container_taxonomy, :name => 'Food Hall 1')
      Factory(:container_taxonomy, :name => 'Drinks Hall 1')
      click_link "Container Taxonomies"
      find('table#listing_container_taxonomies tr:nth-child(2) td:nth-child(1)').text.should include("Food Hall 1")
      find('table#listing_container_taxonomies tr:nth-child(3) td:nth-child(1)').text.should include("Drinks Hall 1")
    end
  end

  context "create" do
    before(:each) do
      Factory(:warehouse, :name => "Subaru")
      click_link "admin_new_container_taxonomy_link"
    end

    it "should allow an admin to create a new taxonomy" do
      page.should have_content("New Container Taxonomy")
      fill_in "container_taxonomy_name", :with => "sports"
      select "Subaru", :from => "container_taxonomy_warehouse_id"
      click_button "Create"
      page.should have_content("successfully created!")
    end

    it "should display validation errors" do
      fill_in "container_taxonomy_name", :with => ""
      click_button "Create"
      page.should have_content("Name can't be blank")
      page.should have_content("Warehouse can't be blank")
    end
  end

  context "edit" do
    it "should allow an admin to update an existing taxonomy" do
      Factory(:container_taxonomy)
      click_link "Container Taxonomies"
      within(:css, 'table#listing_container_taxonomies tr:nth-child(2)') { click_link "Edit" }
      page.should have_content("Edit Container Taxonomy")
      fill_in "container_taxonomy_name", :with => "sports 99"
      click_button "Update"
      page.should have_content("successfully updated!")
      page.should have_content("sports 99")
    end
  end
end