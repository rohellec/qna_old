class AnswersController < ApplicationController
  include Voted

  before_action :authenticate_user!
  before_action :set_question, only: :create
  before_action :set_answer,   only: [:update, :destroy, :accept, :remove_accept]
  before_action :set_answer_question, only: [:destroy, :accept, :remove_accept]
  before_action :check_author, only: [:update, :destroy]
  before_action(only: [:accept, :remove_accept]) { check_author(@question) }

  after_action :publish_answer, only: :create

  def create
    @answer = @question.answers.build(answer_params)
    @answer.user = current_user
    if @answer.save
      render_json_with_message(@answer.as_json(include: :attachments))
    else
      render_errors
    end
  end

  def update
    if @answer.update(answer_params)
      render_json_with_message(@answer.as_json(include: :attachments))
    else
      render_errors
    end
  end

  def destroy
    @answer.destroy
    render_json_with_message
  end

  def accept
    @answer.accept
    render json: @answer
  end

  def remove_accept
    @answer.remove_accept
    render json: @answer
  end

  private

  def answer_params
    params.require(:answer).permit(:body, attachments_attributes: [:id, :file, :_destroy])
  end

  def publish_answer
    return if @answer.errors.any?
    AnswersChannel.broadcast_to(@question, @answer.as_json(include: :attachments))
  end

  def set_answer
    @answer = Answer.find(params[:id])
  end

  def set_answer_question
    @question = @answer.question
  end

  def set_question
    @question = Question.find(params[:question_id])
    @answers  = @question.answers
  end
end
