class AddAttachableReferenceToAttachments < ActiveRecord::Migration[5.1]
  def change
    add_reference    :attachments, :attachable, polymorphic: true
    remove_reference :attachments, :question, index: true, foreign_key: true
  end
end
