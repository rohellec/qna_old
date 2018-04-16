class AnswersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_question,  only: :create
  before_action :correct_user?, only: :destroy

  def create
    @answer = @question.answers.build(answer_params)
    @answer.user = current_user
    if @answer.save
      flash[:success] = "New answer has been successfully created"
      redirect_to @question
    else
      render "questions/show", hidden: false
    end
  end

  def destroy
    @answer.delete
    flash[:success] = "Answer has been successfully deleted"
    redirect_to @answer.question
  end

  private

  def answer_params
    params.require(:answer).permit(:body)
  end

  def correct_user?
    @answer = Answer.find(params[:id])
    user = @answer.user
    redirect_to root_path if user != current_user
  end

  def set_question
    @question = Question.find(params[:question_id])
    @user = @question.user
    @answers = @question.answers.select { |question| question.persisted? }
  end
end
