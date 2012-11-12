module Spree
  module Admin
    module QrHelper
      def qr_code(container_taxon)

        @code = { :container_taxon => { 
                      :name => container_taxon.name, 
                      :permalink => container_taxon.permalink,
                      :updated_at => container_taxon.updated_at,
                      :container_taxonomy => {  :id =>    @container_taxonomy.id,
                                                :name =>  @container_taxonomy.name 
                                              }, 

                      :warehouse =>         {  :id => @container_taxonomy.warehouse.id,
                                                :name => @container_taxonomy.warehouse.name
                                             } 
                  } 
                }
      end
    end
  end
end