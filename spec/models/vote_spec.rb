require 'rails_helper'

describe Vote do
  it { is_expected.to belong_to :user }
  it { is_expected.to belong_to :votable }

  # due to the bug in shoulda-matchers when testing uniqueness of fields with foreign-key contraint
  # should use this hack
  it do
    subject.user = create(:user)
    is_expected.to validate_uniqueness_of(:user_id).scoped_to(:votable_type)
  end
end
