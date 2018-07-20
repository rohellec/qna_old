class QuestionsController < ApplicationController
  before_action :authenticate_user!, except: [:show, :index]
  before_action :set_question,  only: [:show, :edit, :update, :destroy]
  before_action :correct_user?, only: [:edit, :update, :destroy]

  def index
    @questions = Question.all
  end

  def show
    @answers = @question.answers
    @answer  = Answer.new
  end

  def new
    @question = Question.new
    @question.attachments.build
  end

  def edit
  end

  def create
    @question = Question.new(question_params)
    @question.user = current_user
    if @question.save
      redirect_to @question, flash: { success: "New question has been successfully created" }
    else
      render :new
    end
  end

  def update
    respond_to do |format|
      if @question.update(question_params)
        format.html do
          flash[:success] = "Question has been successfully updated"
          redirect_to @question
        end
        format.js do
          flash.now[:success] = "Question has been successfully updated"
          render "update", layout: false
        end
      else
        format.html { render :edit }
        format.js   { render "error_messages", layout: false }
      end
    end
  end

  def destroy
    @question.destroy
    message = "Question has been successfully deleted"
    respond_to do |format|
      format.js do
        flash.now[:success] = message
        render "destroy", layout: false
      end
      format.html do
        flash[:success] = message
        redirect_to questions_path
      end
    end
  end

  private

  def correct_user?
    return if current_user.author_of?(@question)
    flash[:notice] = "You need to be an author of the question"
    redirect_back(fallback_location: root_url)
  end

  def set_question
    @question = Question.find(params[:id])
  end

  def question_params
    params.require(:question).permit(:title, :body, attachments_attributes: [:id, :file])
  end
end
