class AssociationPresenceValidator < ActiveModel::EachValidator

  def validate_each(object, attribute, value)
    id_attr = "#{attribute}_id"
    id_attr = "#{attribute.to_s.singularize}_ids" unless object.respond_to?(id_attr)

    if value.blank? and (!object.respond_to?(id_attr) or object.send(id_attr).blank?)
      object.errors[attribute] << 'is required'
    end
  end

end
