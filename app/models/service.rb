class Service < ApplicationRecord
  belongs_to :corporation
  has_many :invoice_setting_services
  has_many :invoice_settings, through: :invoice_setting_services
end
