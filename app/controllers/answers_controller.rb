class AnswersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_question,  only: :create
  before_action :set_answer,    only: :destroy
  before_action :correct_user?, only: :destroy

  def create
    @answer = @question.answers.build(answer_params)
    @answer.user = current_user
    @answer.save
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
    return if current_user.author_of?(@answer)
    flash[:notice] = "You need to be an author of the answer"
    redirect_back(fallback_location: root_url)
  end

  def set_answer
    @answer = Answer.find(params[:id])
  end

  def set_question
    @question = Question.find(params[:question_id])
    @answers  = @question.answers
  end
end
