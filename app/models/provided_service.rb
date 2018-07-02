class ProvidedService < ApplicationRecord
	belongs_to :payable, polymorphic: true
	belongs_to :nurse
end
