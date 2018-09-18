class InvoiceSetting < ApplicationRecord
  belongs_to :corporation
  has_many :provided_services
  has_many :invoice_setting_nurses
  has_many :nurses, through: :invoice_setting_nurses
  has_many :invoice_setting_services
  has_many :services, through: :invoice_setting_services
end
