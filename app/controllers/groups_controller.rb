class GroupsController < ApplicationController
  skip_before_action :verify_authenticity_token # todo - check for token from form element

  before_action :set_group, only: %i[ show update destroy ]

  before_action :authorize_group_owner, only: [:update, :destroy]

  attr_accessor :page, :page_limit, :sort_by, :sort_type

  POSSIBLE_DIRECT_FILTERS = [:id, :status, :admin_id]
  POSSIBLE_INDIRECT_FILTERS = [:name]

  # GET /groups or /groups.json
  def index
    query = get_query

    query = apply_filters(query)

    data = get_data(query)
    pagination_data = get_pagination_data(query)

    return render json: { list: data }.merge!(pagination_data)
  end

  # GET /groups/1 or /groups/1.json
  def show
    group = Group.includes(:admin).find(params[:id]).as_json(
      include:
        {
          admin: { only: [:id, :name] }
        }
    )

    return render json: group
  end

  # POST /groups or /groups.json
  def create
    group_params = get_create_params
    group = Group.new(group_params)

    unless group.save
      return render json: group.errors.full_messages
    end

    return render json: group
  end

  # PATCH/PUT /groups/1 or /groups/1.json
  def update
    group_params = get_updated_group_params

    unless @group.update(group_params)
      return render json: @group.errors.full_messages
    end

    return self.show
  end

  # DELETE /groups/1 or /groups/1.json
  def destroy
    @group.destroy

    return render json: @group
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_group
    @group = Group.where(id: params[:id]).take

    if @group.blank?
      return render json: { error: "Group does not exist!" }, status: :internal_server_error
    end
  end

  def get_query
    @page = params[:page] || 1
    @page_limit = params[:page_limit] || 10
    sort_by = params[:sort_by] || 'updated_at'
    sort_type = params[:sort_type] || 'desc'

    query = Group.includes(:admin).page(@page).per(@page_limit).order("groups.#{sort_by} #{sort_type}")

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
    query.where("groups.name ILIKE ? ", "%#{params[:name]}%")
  end

  def get_data(query)
    groups = query.as_json(
      include:
        {
          admin: { only: [:id, :name] }
        }
    ).map(&:deep_symbolize_keys)

    return groups
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
    params.require(:group).permit(:name, :admin_id, :description, :profile_picture, :status)
  end

  def get_updated_group_params
    params.require(:group).permit(:name, :description, :status, :admin_id)
  end

  # Check if the current user is the owner of the group
  def authorize_group_owner
    if params[:user_id].blank?
      return render json: { error: "Kindly provide Group owner" }, status: :forbidden
    end

    unless @group.admin_id == params[:user_id]
      return render json: { error: "You are not authorized to update this Group" }, status: :forbidden
    end
  end
end
