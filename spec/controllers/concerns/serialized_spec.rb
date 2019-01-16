require "rails_helper"

describe ApplicationController do
  before(:all) do
    I18n.backend.store_locations(
      I18n.locale,
      { anonymous: { create: { message: "anonymous created" } } }
    )
  end

  controller do
    include Serialized

    before_action :check_resource_found, only: :edit

    def create
      @example = build(:comment)
      @example.save ? render_json_with_message(@example) : render_errors(@example)
    end

    def edit
    end
  end

  subject { response.body }

  describe "POST #create" do
    before  { post :create, params }

    context "valid" do
      let(:params) { { text: "Test Serialized" } }

      specify { expect(response).to be_success }
      it { is_expected.to match '"message":"anonymous created"' }
      it { is_expected.to match '"text":"Test Serialized"' }
    end

    context "invalid" do
      let(:params) { }

      specify { expect(response).to have_http_status(:forbidden) }
      it { is_expected.to match "Text can't be blank" }
    end
  end

  describe "GET #edit" do
    before { get :edit }

    specify { expect(response).to have_http_status(:forbidden) }
    it { is_expected.to match t("http_error.not_found") }
  end
end
