module WishedSlotsHelper

  def background_wished_slot_css(wished_slot)
    case wished_slot.rank 
    when 0
      "colibri-bg-red"
    when 1
      "colibri-bg-yellow"
    when 2
      "colibri-bg-green"
    else
    end
  end

end