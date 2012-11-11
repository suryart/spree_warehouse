module Spree
  module Admin
    class StockController < BaseController

      before_filter :load_variant, :only => [:restocking, :destocking]
      
      respond_to :html, :js
      
      def new
        @container_taxons = ContainerTaxon.all
        @suppliers = Supplier.all
      end

      def products
        if params[:term]
          like= "%".concat(params[:term].concat("%"))
          products = Product.where("name like ?", like).includes([:variants])
        else
          products = Product.all
        end
        list = products.map do |p| 
          Hash[ 
            :id => p.id, 
            :label => p.name,
            :name => p.name,
            :variants => p.variants_including_master.map do |v| 
              { :id => v.id, :sku => v.sku } 
            end
          ] 
        end
        render :json => list
      end
     
      def index 
        @search = Product.includes(master_includes, variant_includes).search(params[:q])
        @page_count = params[:per_page].nil? ? page_count : params[:per_page]
        @products = @search.result.page(params[:page]).per(@page_count)
        respond_with(@products) do |format|
          format.html
        end
      end
      
      def restocked_items
        params[:q] ||= {} 
        params[:q][:s] ||= "created_at.desc"
        @search = StockRecord.restocked.includes({:variant => :product}, :supplier, :container_taxon).search(params[:q])
        @restocked_items = @search.result.page(params[:page]).per(page_count)
        respond_with(@restocked_items) do |format|
          format.html { render 'spree/admin/stock/restocked_items/index' }
        end
      end
      
      def destocked_items
        params[:q] ||= {} 
        params[:q][:s] ||= "created_at.desc"
        @search = StockRecord.destocked.includes({:variant => :product}, :container_taxon).search(params[:q])
        @destocked_items = @search.result.page(params[:page]).per(page_count)
        respond_with(@restocked_items) do |format|
          format.html { render 'spree/admin/stock/destocked_items/index' }
        end
      end
      
      def restocking
        @container_taxons = ContainerTaxon.all
        @suppliers = Supplier.all
        @container_taxon_id = params[:container_taxon_id].nil? ? 'nil' : params[:container_taxon_id]
        @supplier_id = params[:supplier_id].nil? ? 'nil' : params[:supplier_id]
        respond_to do |format|
          format.js { render 'spree/admin/stock/restocking/restocking' }
        end
      end

      def restock
        unless params[:stock_record][:variant_id].nil?
          @variant = Variant.find(params[:stock_record][:variant_id])
          if params[:stock_record][:container_taxon_id].nil?
            restock_without_container_taxon 
          end
      
          if @stock_record = StockRecord.create(params[:stock_record])
            flash[:notice] = "#{@variant.name} #{ t(:successfully_restocked) }"
            respond_with { |format| format.html { redirect_to :admin_stock } }
          end
      
        else # no variant given
          flash[:error] = t('errors.messages.could_not_restock_no_variant_selected')
          respond_with { |format| format.html { redirect_to :admin_stock } }
        end
      end

      def destocking
        @reasons = DestockingReason.all
        @container_taxon_id = params[:container_taxon_id].nil? ? 'nil' : params[:container_taxon_id]
        respond_to do |format|
          format.js { render 'spree/admin/stock/destocking/destocking' }
        end
      end
      
      def destock
        unless params[:stock_record][:variant_id].nil?
          @variant = Variant.find(params[:stock_record][:variant_id])
          if @variant.container_taxons.exists?(:id => params[:stock_record][:container_taxon_id])
            variant_ct = @variant.variant_container_taxons.find_by_container_taxon_id(params[:stock_record][:container_taxon_id])
            unless variant_ct.quantity.nil?
              variant_ct.quantity = variant_ct.quantity - params[:stock_record][:quantity].to_i 
              variant_ct.deactivate if variant_ct.quantity == 0 # won't show
            else
              #TODO Do we need negative values? 
              variant_ct.quantity = 0 - params[:stock_record][:quantity].to_i 
              variant_ct.deactivate # won't show
            end 
            variant_ct.save
          end
          @variant.save

          if @stock_record = StockRecord.create(params[:stock_record])
            flash[:notice] = "#{@variant.name} #{t(:successfully_destocked) }"
            respond_with { |format| format.html { redirect_to :admin_stock } }
          end
        else # no variant given
          flash[:error] = t('errors.messages.could_not_destock_no_variant_selected')
          respond_with { |format| format.html { redirect_to :admin_stock } }
        end
      end
      
      def reassign
        restock
      end

      def reassigning
        @container_taxons = ContainerTaxon.all
        @variant = Variant.find(params[:id])
        @container_taxon_id = params[:container_taxon_id].nil? ? 'nil' : params[:container_taxon_id]
        respond_to do |format|
          format.js { render 'spree/admin/stock/reassigning/reassigning' }
        end
      end

      private 
      
        def load_variant
          @variant = Variant.find(params[:id])
        end 

        def master_includes
          {:master => [{:active_variant_container_taxons => :container_taxon}, :images]}
        end

        def variant_includes
          {:variants => [{:active_variant_container_taxons => :container_taxon}, :images, :product, {:option_values => :option_type}]}
        end

        def page_count
          Spree::Config[:admin_products_per_page]
        end

        def restock_without_container_taxon
          if @variant.container_taxons.exists?(:id => params[:stock_record][:container_taxon_id])
            variant_ct = @variant.variant_container_taxons.find_by_container_taxon_id(params[:stock_record][:container_taxon_id])
            variant_ct.activate if variant_ct.quantity == 0  #will show
            variant_ct.quantity += params[:stock_record][:quantity].to_i 
            variant_ct.save
          else 
            ct = ContainerTaxon.find(params[:stock_record][:container_taxon_id])
            @variant.variant_container_taxons.create(:container_taxon_id => ct.id, :quantity => params[:stock_record][:quantity])
          end
          @variant.save
        end

    end
  end
end