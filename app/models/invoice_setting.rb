class InvoiceSetting < ApplicationRecord
  belongs_to :corporation
  has_many :provided_services
  has_many :invoice_setting_nurses
  has_many :nurses, through: :invoice_setting_nurses
  has_many :invoice_setting_services
  has_many :services, through: :invoice_setting_services

  validates :operator, inclusion: 0..1
  # 0 for sum, 1 for multiplication
  validates :invoice_line_option, inclusion: 0..2
  # 0 => same line as service, 1 => different line, unique per planning and nurse, 2 => different line for each service
  validates :target_services_by_1, inclusion: 0..1
  # 0 => all provided_services that belong to a service, 1 => all these services from the weekend and holidays
end
