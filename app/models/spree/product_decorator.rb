module Spree
  Product.class_eval do 
    delegate_belongs_to :master, :visual_code
    attr_accessible :visual_code   

    def has_active_taxons? 
      self.master.variant_container_taxons.active.any?
    end
  end
end