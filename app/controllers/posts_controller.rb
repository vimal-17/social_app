class PostsController < ApplicationController
  skip_before_action :verify_authenticity_token # todo - check for token from form element

  before_action :set_post, only: %i[ show update destroy ]

  before_action :authorize_post_owner, only: [:update, :destroy]

  attr_accessor :page, :page_limit, :sort_by, :sort_type

  POSSIBLE_DIRECT_FILTERS = [:id, :status, :like_count, :dislike_count, :comment_count, :group_id]
  POSSIBLE_INDIRECT_FILTERS = [:title, :owner_id ,:user_id]

  # GET /posts or /posts.json
  def index
    query = get_query

    query = apply_filters(query)

    data = get_data(query)
    pagination_data = get_pagination_data(query)

    return render json: { list: data }.merge!(pagination_data)
  end

  # GET /posts/1 or /posts/1.json
  def show
    post = Post.includes(:user, :group).find(params[:id]).as_json(
      include:
        {
          user: { only: [:id, :name] },
          group: { only: [:id, :name] }
        }
    )

    return render json: post
  end

  # POST /posts or /posts.json
  def create
    post_params = get_create_params
    post = Post.new(post_params)

    unless post.save
      return render json: post.errors.full_messages
    end

    return render json: post
  end

  # POST /posts/1 or /posts/1.json
  def update
    post_params = get_updated_post_params

    unless @post.update(post_params)
      return render json: @post.errors.full_messages
    end

    return self.show
  end

  # DELETE /posts/1 or /posts/1.json
  def destroy
    @post.destroy

    return render json: @post
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_post
    @post = Post.where(id: params[:id]).take

    if @post.blank?
      return render json: { error: "Post does not exist!" }, status: :internal_server_error
    end
  end

  def get_query
    @page = params[:page] || 1
    @page_limit = params[:page_limit] || 10
    sort_by = params[:sort_by] || 'updated_at'
    sort_type = params[:sort_type] || 'desc'

    query = Post.includes(:user, :group).page(@page).per(@page_limit).order("posts.#{sort_by} #{sort_type}")

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

  def apply_title_filter(query)
    query.where("posts.title ILIKE ? ", "%#{params[:title]}%")
  end

  def apply_owner_id_filter(query)
    query.where(user_id: params[:owner_id])
  end

  def apply_user_id_filter(query)
    query.joins(group: :group_users).where(group_users: { user_id: params[:user_id], status: 'active' })
  end

  def get_data(query)
    posts = query.as_json(
      include:
        {
          user: { only: [:id, :name] } ,
          group: { only: [:id, :name] }
        }
    ).map(&:deep_symbolize_keys)

    return posts
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
    params.require(:post).permit(:title, :body, :user_id, :status, :group_id)
  end

  def get_updated_post_params
    params.require(:post).permit(:title, :body, :status)
  end

  # Check if the current user is the owner of the post
  def authorize_post_owner
    if params[:user_id].blank?
      return render json: { error: "Kindly provide post owner" }, status: :forbidden
    end

    unless @post.user_id == params[:user_id]
      return render json: { error: "You are not authorized to update this post" }, status: :forbidden
    end
  end
end
