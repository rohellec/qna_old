class AnswersController < ApplicationController
  before_action :set_question, only: [:new, :create]

  def new
    @answer = Answer.new
  end

  def create
    @answer = @question.answers.build(answer_params)
    if @answer.save
      flash[:success] = "New answer has been successfully created"
      redirect_to @question
    else
      render :new
    end
  end

  private

  def set_question
    @question = Question.find(params[:question_id])
  end

  def answer_params
    params.require(:answer).permit(:body)
  end
end
