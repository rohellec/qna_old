class CommentsController < ApplicationController
  include Serialized

  STREAM_MODEL = Question

  before_action :authenticate_user!
  before_action :set_commentable,      only: :create
  before_action :set_comment,          only: [:update, :destroy]
  before_action :check_author,         only: [:update, :destroy]
  before_action :check_resource_found, only: [:update, :destroy]

  after_action :publish_comment, only: :create

  def create
    @comment = @commentable.comments.build(comment_params)
    @comment.user = current_user
    if @comment.save
      render_json_with_message
    else
      render_errors
    end
  end

  def update
    if @comment.update(comment_params)
      render_json_with_message
    else
      render_errors
    end
  end

  def destroy
    @comment.destroy
    render_json_with_message
  end

  private

  def comment_params
    params.require(:comment).permit(:body)
  end

  def commentable_name
    params[:commentable]
  end

  def commentable_id
    params[commentable_name.singularize + "_id"]
  end

  def publish_comment
    return if @comment.errors.any?
    question = if @comment.commentable_type == STREAM_MODEL.to_s
                 @comment.commentable
               else
                 @comment.commentable.question
               end
    CommentsChannel.broadcast_to(question, @comment)
  end

  def set_comment
    @comment = Comment.find(params[:id])
  end

  def set_commentable
    @commentable = commentable_name.classify.constantize.find(commentable_id)
  end
end
