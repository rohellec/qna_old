class QuestionsController < ApplicationController
  before_action :authenticate_user!,  except: [:show, :index, :up_vote]
  before_action :authenticate_voting, only:   [:up_vote]
  before_action :set_question,  only: [:show, :edit, :update, :destroy, :up_vote, :delete_vote]
  before_action :check_author,  only: [:edit, :update, :destroy]
  before_action :check_votable, only: [:up_vote]

  def index
    @questions = Question.all
  end

  def show
    @attachments = @question.attachments
    @answers = @question.answers
    @answer  = Answer.new
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

  def up_vote
    @vote = current_user.up_vote(@question)
    respond_to do |format|
      if @vote
        format.json { render json: up_vote_response }
      else
        message = "You have already voted for this question"
        format.json { render json: message, status: :unprocessable_entity }
      end
    end
  end

  def delete_vote
    @vote = current_user.delete_vote_from(@question)
    respond_to do |format|
      if @vote
        format.json { render json: delete_vote_response }
      else
        message = "You haven't voted for this question"
        format.json { render json: message, status: :unprocessable_entity }
      end
    end
  end

  private

  def check_author
    return if current_user.author_of?(@question)
    flash[:notice] = "You need to be an author of the question"
    redirect_back(fallback_location: root_url)
  end

  def authenticate_voting
    return if user_signed_in?
    message = "You need to sign in before you can vote"
    respond_to do |format|
      format.json { render json: message, status: :unprocessable_entity }
      format.html do
        flash[:notice] = message
        redirect_back(fallback_location: root_url)
      end
    end
  end

  def check_votable
    return unless current_user.author_of?(@question)
    message = "You can't vote up for your own question"
    respond_to do |format|
      format.json { render json: message, status: :unprocessable_entity }
      format.html do
        flash[:notice] = message
        redirect_back(fallback_location: root_url)
      end
    end
  end

  def delete_vote_response
    {
      resource_id:  @question.id,
      rating:       @question.vote_rating,
      message:      "Your vote has been successfully deleted"
    }
  end

  def up_vote_response
    {
      resource_id:  @question.id,
      rating:       @question.vote_rating,
      message:      "Your vote has been counted"
    }
  end

  def set_question
    @question = Question.find(params[:id])
  end

  def question_params
    params.require(:question).permit(:title, :body, attachments_attributes: [:id, :file, :_destroy])
  end
end
