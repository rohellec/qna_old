class QuestionsController < ApplicationController
  include Voted

  before_action :authenticate_user!,  except: [:show, :index]
  before_action :set_question, only: [:show, :edit, :update, :destroy]
  before_action :gon_question, only: :show
  before_action :check_author, only: [:edit, :update, :destroy]

  after_action  :publish_question, only: :create

  def index
    @questions = Question.all
  end

  def show
    @attachments = @question.attachments
    @answers = @question.answers_by_rating
    @answer = Answer.new
  end

  def new
    @question = Question.new
  end

  def edit
  end

  def create
    @question = Question.new(question_params)
    @question.user = current_user
    if @question.save
      redirect_to @question, flash: { success: t(".message") }
    else
      render :new
    end
  end

  def update
    respond_to do |format|
      if @question.update(question_params)
        format.json { render_json_with_message(@question.as_json(include: :attachments)) }
        format.html do
          flash[:success] = t(".message")
          redirect_to @question
        end
      else
        format.json { render_errors }
        format.html { render :edit }
      end
    end
  end

  def destroy
    @question.destroy
    respond_to do |format|
      format.json { render_json_with_message }
      format.html do
        flash[:success] = t(".message")
        redirect_to questions_path
      end
    end
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
