module Archivable
    extend ActiveSupport::Concern 

    included do
        validates :archived_at, presence: true
    end

	def archived?
		archived_at.present?
	end

	def archive 
		archived_at = Time.current 
	end

	def archive! 
		update_column(:archived_at, Time.current)
	end


end