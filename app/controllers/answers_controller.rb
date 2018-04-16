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
      render "questions/show"
    end
  end

  def destroy
    @answer.destroy
    flash[:success] = "Answer has been successfully deleted"
    redirect_to @answer.question
  end

  private

  def answer_params
    params.require(:answer).permit(:body)
  end

  def correct_user?
    @answer = Answer.find(params[:id])
    redirect_to root_path unless current_user.author_of?(@answer)
  end

  def set_question
    @question = Question.find(params[:question_id])
    @answers  = @question.answers
  end
end
