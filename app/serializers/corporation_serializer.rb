class CorporationSerializer
  include FastJsonapi::ObjectSerializer
  attributes :name, :identifier, :email
end
