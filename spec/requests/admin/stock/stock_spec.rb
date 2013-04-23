require 'spec_helper'

describe "Stock" do
  stub_authorization!

  before(:each) do
    product1 = Factory(:product, :name => 'apache baseball cap', :available_on => '2011-01-01 01:01:01', :sku => "A100")
    @product2 = Factory(:product, :name => 'zomg shirt', :available_on => '2011-01-01 01:01:01', :sku => "Z100")
    product3 = Factory(:product, :name => 'apache baseball cap2', :available_on => '2011-01-01 01:01:01', :sku => "A100")

    c_taxonomy = Factory(:container_taxonomy, :name => 'Rack#1') 
    ct_shelve = Factory(:container_taxon, :container_taxonomy => c_taxonomy, :name => 'Shelve#1') 
    ct_container = Factory(:container_taxon, :container_taxonomy => c_taxonomy, :name => 'Container#1', :parent_id => ct_shelve) 

    Factory(:stock_record, :variant => product1.master, :container_taxon => ct_shelve, :quantity => 5, :direction => 'in')
    Factory(:stock_record, :variant => @product2.master, :container_taxon => ct_container, :quantity => 10, :direction => 'in')

    visit spree.admin_path
  end

  context "searching" do
    it "searches stock by product name, sku and container taxon" do
      click_link "Stock"

      fill_in "q_name_cont", :with => "ap"
      click_button "Search"

      page.should have_content "apache baseball cap"
      page.should have_content "apache baseball cap2"
      page.should_not have_content "zomg shirt"

      fill_in "q_variants_including_master_sku_cont", :with => "A1"
      click_button "Search"
      page.should have_content "apache baseball cap"
      page.should_not have_content "apache baseball cap2"
      page.should_not have_content "zomg shirt"
    end
  end 

  context "restocking" do
    pending "restocks from top form " , :js => true do
      click_link "Stock"
      click_link "New Stock"

      wait_until { page.find("#new_stock_fieldset") }
      expect do 
        within("#new_stock_fieldset")  do
          fill_in "add_product_name", :with => "zomg"
          sleep 1
          #wait_until { find(".ui-menu").visible? }
          find("li:contains('zomg shirt')").click

          #within("ul.ui-menu") do 
          #  find("zomg shirt").click
          #end
          sleep 5 
          fill_in "stock_record_quantity", :with => 99 
          select 'Container#1', :from => 'stock_record_container_taxon_id'
          click_button "Restock"
        end
        wait_until { page.should have_content "successfully restocked" }
      end.to change(Spree::StockRecord.restocked, :count).by 1

    end

    it "restocks from products list", :js => true do
      click_link "Stock"
      find("##{@product2.id}_label").click
      wait_until { find("##{@product2.id}_content").visible? }

      click_on "Restock"
      sleep 1
      wait_until { find("#restocking_form").visible? }

      expect do 
        fill_in "stock_record_quantity", :with => "5"
        click_on "Submit"
        wait_until { page.should have_content "successfully restocked" }
      end.to change(Spree::StockRecord.restocked, :count).by 1

    end
  end
end