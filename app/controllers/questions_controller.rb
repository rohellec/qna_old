class QuestionsController < ApplicationController
  before_action :authenticate_user!, except: [:show, :index]
  before_action :set_question,  only: [:show, :update, :destroy]
  before_action :correct_user?, only: [:update, :destroy]

  def index
    @questions = Question.all
  end

  def show
    @answers = @question.answers
    @answer  = Answer.new
  end

  def new
    @question = Question.new
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
        flash.now[:success] = "Question has been successfully updated"
        format.js { render "update", layout: false }
      else
        format.js { render "error_messages", layout: false }
      end
    end
  end

  def destroy
    @question.destroy
    flash[:success] = "Question has been successfully deleted"
    redirect_to questions_path
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
    params.require(:question).permit(:title, :body)
  end
end
