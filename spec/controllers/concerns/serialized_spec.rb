require "rails_helper"

describe ApplicationController do
  before(:all) do
    I18n.backend.store_translations(
      I18n.locale,
      { anonymous: { create: { message: "anonymous created" } } }
    )
  end

  with_model :WithComment do
    table { |t| t.string :body }
    model { validates :body, presence: true }
  end

  controller do
    include Serialized

    before_action :check_resource_found, only: :edit
    before_action :render_unprocessable_with_message, only: :index

    def create
      @example = WithComment.new(body: params[:text])
      @example.save ? render_json_with_message(@example) : render_errors(@example)
    end

    def edit
    end

    def index
    end
  end

  let(:user) { create(:confirmed_user) }

  subject { response.body }

  before  { sign_in user }

  describe "POST #create" do
    before  { post :create, params: params }

    context "valid" do
      let(:params) { { text: "Test Serialized" } }

      specify { expect(response).to be_success }
      it { is_expected.to match '"message":"anonymous created"' }
      it { is_expected.to match '"body":"Test Serialized"' }
    end

    context "invalid" do
      let(:params) { {} }

      specify { expect(response).to have_http_status :forbidden }
      it { is_expected.to match "Body can't be blank" }
    end
  end

  describe "GET #edit" do
    let(:example) { WithComment.create(body: "random") }

    before { get :edit, params: { id: example } }

    specify { expect(response).to have_http_status :not_found }
    it { is_expected.to match I18n.translate("http_error.not_found") }
  end

  describe "POST #index" do
    before { post :index }

    specify { expect(response).to have_http_status :unprocessable_entity }
    it { is_expected.to match I18n.translate("http_error.unprocessable_entity") }
  end
end
