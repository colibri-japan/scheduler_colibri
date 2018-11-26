class Scan < ApplicationRecord
  mount_uploader :teikyohyo, TeikyohyoUploader
  
  belongs_to :planning

  def done!
    self.update(done_at: Time.current)
  end

  def done?
    self.done_at.present?
  end

  def cancel!
    self.update(cancelled_at: Time.current)
  end

  def cancelled?
    self.cancelled_at.present?
  end


end
