class InteractionsController < ApplicationController
  skip_before_action :verify_authenticity_token # todo - check for token from form element

  before_action :set_interaction, only: %i[ show update destroy ]

  before_action :authorize_interaction_owner, only: [:update, :destroy]

  attr_accessor :page, :page_limit

  POSSIBLE_DIRECT_FILTERS = [:id, :status, :is_like, :object_id, :user_id, :object_type]
  POSSIBLE_INDIRECT_FILTERS = [:post_id, :comment_id]

  # GET /interactions or /interactions.json
  def index
    query = get_query

    query = apply_filters(query)

    data = get_data(query)
    pagination_data = get_pagination_data(query)

    return render json: { list: data }.merge!(pagination_data)
  end

  # GET /interactions/1 or /interactions/1.json
  def show
    interaction = Interaction.includes(:user, :object).find(params[:id]).as_json(
      include:
        {
          user: { only: [:id, :name] },
          object: { only: [:id, :body] }
        }
    )

    return render json: interaction
  end

  # POST /interactions or /interactions.json
  def create
    interaction_params = get_create_params
    interaction = Interaction.new(interaction_params)

    unless interaction.save
      return render json: interaction.errors.full_messages
    end

    return render json: interaction
  end

  # PATCH/PUT /interactions/1 or /interactions/1.json
  def update
    interaction_params = get_updated_interaction_params

    unless @interaction.update(interaction_params)
      return render json: @interaction.errors.full_messages
    end

    return self.show
  end

  # DELETE /interactions/1 or /interactions/1.json
  def destroy
    @interaction.destroy

    return render json: @interaction
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_interaction
    @interaction = Interaction.where(id: params[:id]).take

    if @interaction.blank?
      return render json: { error: "Interaction does not exist!" }, status: :internal_server_error
    end
  end

  def get_query
    @page = params[:page] || 1
    @page_limit = params[:page_limit] || 10
    sort_by = params[:sort_by] || 'updated_at'
    sort_type = params[:sort_type] || 'desc'

    query = Interaction.includes(:user, :object).page(@page).per(@page_limit).order("interactions.#{sort_by} #{sort_type}")

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

  def apply_post_id_filter(query)
    post_ids = [params[:post_id].split(',')].flatten.compact.uniq

    query.where("interactions.object_type = 'Post' AND interactions.object_id in ( ? )", post_ids)
  end

  def apply_comment_id_filter(query)
    comment_ids = [params[:comment_id].split(',')].flatten.compact.uniq
    query.where("interactions.object_type = 'Comment' AND interactions.object_id in ( ? )", comment_ids)
  end

  def get_data(query)
    interactions = query.as_json(
      include: {
        user: { only: [:id, :name] },
        object: { only: [:id, :body] }
      }
    ).map(&:deep_symbolize_keys)

    return interactions
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
    params.require(:interaction).permit(:object_id, :object_type, :user_id, :is_like, :status)
  end

  def get_updated_interaction_params
    params.require(:interaction).permit(:is_like, :status)
  end

  # Check if the current user is the owner of the Interaction
  def authorize_interaction_owner
    if params[:user_id].blank?
      return render json: { error: "Kindly provide Interaction owner" }, status: :forbidden
    end

    unless @interaction.user_id == params[:user_id]
      return render json: { error: "You are not authorized to update this interaction" }, status: :forbidden
    end
  end
end
