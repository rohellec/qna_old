class AnswersController < ApplicationController
  include Voted

  before_action :authenticate_user!
  before_action :set_question, only: :create
  before_action :set_answer,   only: [:update, :destroy, :accept, :remove_accept]
  before_action :set_answer_question, only: [:destroy, :accept, :remove_accept]
  before_action :answer_author?,   only: [:update, :destroy]
  before_action :question_author?, only: [:accept, :remove_accept]

  def create
    @answer = @question.answers.build(answer_params)
    @answer.user = current_user
    respond_to do |format|
      if @answer.save
        flash.now[:success] = "New answer has been successfully created"
        format.js { render "create", layout: false }
      else
        format.js { render "error_messages", layout: false }
      end
    end
  end

  def update
    respond_to do |format|
      if @answer.update(answer_params)
        flash.now[:success] = "Answer has been successfully updated"
        format.js { render "update", layout: false }
      else
        format.js { render "error_messages", layout: false }
      end
    end
  end

  def destroy
    @answer.destroy
    flash.now[:success] = "Answer has been successfully deleted"
    respond_to do |format|
      format.js { render "destroy", layout: false }
    end
  end

  def accept
    @answer.accept
    respond_to do |format|
      format.js { render "accept", layout: false }
    end
  end

  def remove_accept
    @answer.remove_accept
    @answers = @question.answers
    respond_to do |format|
      format.js { render "remove_accept", layout: false }
    end
  end

  private

  def answer_params
    params.require(:answer).permit(:body, attachments_attributes: [:id, :file, :_destroy])
  end

  def answer_author?
    return if current_user.author_of?(@answer)
    flash[:notice] = "You need to be an author of the answer"
    redirect_back(fallback_location: root_url)
  end

  def question_author?
    return if current_user.author_of?(@question)
    flash[:notice] = "You need to be an author of the question"
    redirect_back(fallback_location: root_url)
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
