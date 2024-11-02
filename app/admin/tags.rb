ActiveAdmin.register Tag do

  menu :label => "Kategorien", :parent => "Games"
  
  filter :value, :as => :string
  filter :context, :as => :select, :collection => proc { Tag.select('context').order('context asc').uniq.collect{|t|t.context} }
  
end
