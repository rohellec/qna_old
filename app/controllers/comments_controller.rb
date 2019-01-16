class CommentsController < ApplicationController
  include Serialized

  before_action :authenticate_user!
  before_action :set_commentable,      only: :create
  before_action :set_comment,          only: [:update, :destroy]
  before_action :check_resource_found, only: [:update, :destroy]

  def create
    @comment = @commentable.comments.build(comment_params)
    @comment.user = current_user
    if @comment.save
      flash.now[:success] = "New comment has been successfully created"
      render formats: :js, layout: false
    else
      respond_errors
    end
  end

  def update
    if @comment.update(comment_params)
      respond_json_with_message
    else
      respond_errors
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

  def set_comment
    @comment = Comment.find(params[:id])
  end

  def set_commentable
    @commentable = commentable_name.classify.constantize.find(commentable_id)
  end
end
