class GroupUsersController < ApplicationController
  skip_before_action :verify_authenticity_token # todo - check for token from form element

  before_action :set_group_user, only: %i[ show update destroy ]

  before_action :set_group, only: [:create]

  before_action :authorize_group_user_owner, only: [:create, :update, :destroy]

  attr_accessor :page, :page_limit, :sort_by, :sort_type

  POSSIBLE_DIRECT_FILTERS = [:id, :status, :group_id, :user_id]
  POSSIBLE_INDIRECT_FILTERS = []

  # GET /group_users or /group_users.json
  def index
    query = get_query

    query = apply_filters(query)

    data = get_data(query)
    pagination_data = get_pagination_data(query)

    return render json: { list: data }.merge!(pagination_data)
  end

  # GET /group_users/1 or /group_users/1.json
  def show
    group_user = GroupUser.includes(:user, :group).find(params[:id]).as_json(
      include:
        {
          user: { only: [:id, :name] },
          group: { only: [:id, :name] }
        }
    )

    return render json: group_user
  end

  # POST /group_users or /group_users.json
  def create
    group_user_params = get_create_params
    group_user = @group.group_users.new(group_user_params)

    unless group_user.save
      return render json: group_user.errors.full_messages
    end

    return render json: group_user
  end

  # PATCH/PUT /group_users/1 or /group_users/1.json
  def update
    group_user_params = get_updated_group_user_params

    unless @group_user.update(group_user_params)
      return render json: @group_user.errors.full_messages
    end

    return self.show
  end

  # DELETE /group_users/1 or /group_users/1.json
  def destroy
    @group_user.destroy

    return render json: @group_user
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_group_user
    @group_user = GroupUser.where(id: params[:id]).take

    if @group_user.blank?
      return render json: { error: "Group user does not exist!" }, status: :internal_server_error
    end

    @group = @group_user.group
  end

  def get_query
    @page = params[:page] || 1
    @page_limit = params[:page_limit] || 10
    sort_by = params[:sort_by] || 'updated_at'
    sort_type = params[:sort_type] || 'desc'

    query = GroupUser.includes(:user, :group).page(@page).per(@page_limit).order("group_users.#{sort_by} #{sort_type}")

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
    group_users = query.as_json(
      include:
        {
          user: { only: [:id, :name] },
          group: { only: [:id, :name] }
        }
    ).map(&:deep_symbolize_keys)

    return group_users
  end

  def get_pagination_data(query)
    return {
      current_page: @page,
      total_pages: query.total_pages,
      total_count: query.total_count,
      page_limit: @page_limit
    }
  end

  # Only allow a list of trusted parameters through.
  def get_create_params
    params.require(:group_user).permit(:group_id, :user_id, :status)
  end

  def get_updated_group_user_params
    params.require(:group_user).permit(:status)
  end

  def set_group
    @group = Group.find(params[:group_user][:group_id]) rescue nil

    unless @group.present?
      return render json: { error: "Kindly provide valid Group." }, status: :forbidden
    end
  end

  # Check if the current user is the owner of the group
  def authorize_group_user_owner
    admin_id = params[:admin_id] rescue  nil
    if admin_id.blank?
      return render json: { error: "Kindly provide Group admin." }, status: :forbidden
    end

    unless @group.admin_id == admin_id
      return render json: { error: "You are not authorized to update group user." }, status: :forbidden
    end
  end
end
