class InvoiceSettingNurse < ApplicationRecord
  belongs_to :invoice_setting
  belongs_to :nurse
end
