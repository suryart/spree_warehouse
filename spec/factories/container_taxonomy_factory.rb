FactoryGirl.define do
  factory :container_taxonomy, :class => Spree::ContainerTaxonomy do
    name 'Racks'
    association(:warehouse)
  end
end