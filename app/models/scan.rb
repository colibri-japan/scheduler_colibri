class Scan < ApplicationRecord
  mount_uploader :teikyohyo, TeikyohyoUploader
  
  belongs_to :planning
end
