class UsersController < ApplicationController
  skip_before_action :verify_authenticity_token # todo - check for token from form element

  before_action :set_user, only: %i[ show update destroy ]

  attr_accessor :page, :page_limit, :sort_by, :sort_type

  POSSIBLE_DIRECT_FILTERS = [:id, :status, :username, :email, :mobile_number]
  POSSIBLE_INDIRECT_FILTERS = [:name]

  # GET /users or /users.json
  def index
    query = get_query

    query = apply_filters(query)

    data = get_data(query)
    pagination_data = get_pagination_data(query)

    return render json: { list: data }.merge!(pagination_data)
  end

  # GET /users/1 or /users/1.json
  def show
    user = User.includes(:groups, :posts, :comments, :interactions).find(params[:id]).as_json(
      include:
        {
          posts: { only: [:id, :title, :body, :status] },
          groups: { only: [:id, :name, :status] },
          comments: { only: [:id, :body, :status, :post_id] },
          interactions: { only: [:id, :is_like, :status, :object_id, :object_type] },
        }
    )

    return render json: user
  end

  # POST /users or /users.json
  def create
    user_params = get_create_params
    user = User.new(user_params)

    unless user.save
      return render json: user.errors.full_messages
    end

    return render json: user
  end

  # PATCH/PUT /users/1 or /users/1.json
  def update
    user_params = get_updated_user_params

    unless @user.update(user_params)
      return render json: @user.errors.full_messages
    end

    return self.show
  end

  # DELETE /users/1 or /users/1.json
  def destroy
    @user.destroy

    return render json: @user
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.where(id: params[:id]).take

    if @user.blank?
      return render json: { error: "User does not exist!" }, status: :internal_server_error
    end
  end

  def get_query
    @page = params[:page] || 1
    @page_limit = params[:page_limit] || 10
    sort_by = params[:sort_by] || 'updated_at'
    sort_type = params[:sort_type] || 'desc'

    query = User.includes(:groups, :posts, :comments, :interactions).page(@page).per(@page_limit).order("users.#{sort_by} #{sort_type}")

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

  def apply_name_filter(query)
    query.where("users.name ILIKE ? ", "%#{params[:name]}%")
  end

  def get_data(query)
    users = query.as_json(
      include:
        {
          posts: { only: [:id, :title, :body, :status] },
          groups: { only: [:id, :name, :status] },
          comments: { only: [:id, :body, :status, :post_id] },
          interactions: { only: [:id, :is_like, :status, :object_id, :object_type] },
        }
    ).map(&:deep_symbolize_keys)

    return users
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
    params.require(:user).permit(:name, :username, :email, :mobile_number, :profile_picture, :bio, :password, :status)
  end

  def get_updated_user_params
    params.require(:user).permit(:name, :username, :email, :mobile_number, :profile_picture, :bio, :password, :status)
  end
end
