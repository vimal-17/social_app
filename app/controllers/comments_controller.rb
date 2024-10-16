class CommentsController < ApplicationController
  skip_before_action :verify_authenticity_token # todo - check for token from form element

  before_action :set_comment, only: %i[ show update destroy ]

  before_action :authorize_comment_owner, only: [:update, :destroy]

  attr_accessor :page, :page_limit

  POSSIBLE_DIRECT_FILTERS = [:id, :status, :post_id, :user_id, :like_count, :dislike_count]
  POSSIBLE_INDIRECT_FILTERS = []

  # GET /comments or /comments.json
  def index
    query = get_query

    query = apply_filters(query)

    data = get_data(query)
    pagination_data = get_pagination_data(query)

    return render json: { list: data }.merge!(pagination_data)
  end

  # GET /comments/1 or /comments/1.json
  def show
    comment = Comment.includes(:user).find(params[:id]).as_json(
      include: {
        user: { only: [:id, :name] },
        post: { only: [:id, :title, :body] }
      }
    )

    return render json: comment
  end

  # POST /comments or /comments.json
  def create
    comment_params = get_create_params
    comment = Comment.new(comment_params)

    unless comment.save
      return render json: comment.errors.full_messages
    end

    return render json: comment
  end

  # POST /comment/1 or /comment/1.json
  def update
    comment_params = get_updated_comment_params

    unless @comment.update(comment_params)
      return render json: @comment.errors.full_messages
    end

    return self.show
  end

  # DELETE /comments/1 or /comments/1.json
  def destroy
    @comment.destroy

    return render json: @comment
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_comment
    @comment = Comment.where(id: params[:id]).take

    if @comment.blank?
      return render json: { error: "Comment does not exist!" }, status: :internal_server_error
    end
  end

  def get_query
    @page = params[:page] || 1
    @page_limit = params[:page_limit] || 10
    sort_by = params[:sort_by] || 'updated_at'
    sort_type = params[:sort_type] || 'desc'

    query = Comment.includes(:user, :post).page(@page).per(@page_limit).order("comments.#{sort_by} #{sort_type}")

    return query
  end

  def apply_filters(query)
    query = apply_direct_filters(query)
    query = apply_indirect_filters(query)

    return query
  end

  def apply_direct_filters(query)
    direct_filters = params.select { |k, _v| POSSIBLE_DIRECT_FILTERS.include?(k.to_sym) }.as_json
    query.where(direct_filters)
  end

  def apply_indirect_filters(query)
    indirect_filters = params.select { |k, _v| POSSIBLE_INDIRECT_FILTERS.include?(k.to_sym) }
    indirect_filters.keys.each do |filter|
      query = send("apply_#{filter}_filter", query)
    end
    query
  end

  def get_data(query)
    comments = query.as_json(
      include: {
        user: { only: [:id, :name] },
        post: { only: [:id, :title, :body] }
      }
    ).map(&:deep_symbolize_keys)

    return comments
  end

  def get_pagination_data(query)
    return {
      current_page: @page.to_i,
      total_pages: query.total_pages,
      total_count: query.total_count,
      page_limit: @page_limit.to_i
    }
  end

  # Only allow a list of trusted parameters through.
  def get_create_params
    params.require(:comment).permit(:post_id, :user_id, :body, :status)
  end

  def get_updated_comment_params
    params.require(:comment).permit(:body, :status)
  end

  # Check if the current user is the owner of the comment
  def authorize_comment_owner
    if params[:user_id].blank?
      return render json: { error: "Kindly provide comment owner" }, status: :forbidden
    end

    unless @comment.user_id == params[:user_id]
      return render json: { error: "You are not authorized to update this comment" }, status: :forbidden
    end
  end
end
