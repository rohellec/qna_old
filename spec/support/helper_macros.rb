module HelperMacros
  def last_attachment
    Attachment.last
  end

  def second_to_last_attachment
    Attachment.second_to_last
  end
end
