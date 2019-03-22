class QuestionsController < ApplicationController
  include Voted

  before_action :authenticate_user!,  except: [:show, :index]
  before_action :set_question, only: [:show, :edit, :update, :destroy]
  before_action :gon_question, only: :show
  before_action :check_author, only: [:edit, :update, :destroy]

  after_action  :publish_question, only: :create

  respond_to :json, only: [:update, :destroy]
  respond_to :html

  def index
    respond_with(@questions = Question.all)
  end

  def show
    @answers = @question.answers_by_rating
    respond_with(@question)
  end

  def new
    @question = Question.new
  end

  def edit
  end

  def create
    respond_with(@question = current_user.questions.create(question_params))
  end

  def update
    @question.update(question_params)
    respond_with(@question, include: :attachments)
  end

  def destroy
    respond_with(@question.destroy)
  end

  private

  def gon_question
    gon.question_id      = @question.id
    gon.question_user_id = @question.user_id
  end

  def question_params
    params.require(:question).permit(:title, :body, attachments_attributes: [:id, :file, :_destroy])
  end

  def publish_question
    return if @question.errors.any?
    ActionCable.server.broadcast('questions', @question.as_json(include: :attachments))
  end

  def set_question
    @question = Question.find(params[:id])
  end
end
