class OpportunitiesController < ApplicationController
  before_action :set_opportunity, only: %i[ show ]

  def index
    @opportunities = Current.professional.opportunities.reverse_chronologically
  end

  def show
  end

  def new
    @opportunity = Current.professional.opportunities.build
  end

  def create
    @opportunity = Current.professional.opportunities.build(opportunity_params)
    unless @opportunity.save
      return render :new, status: :unprocessable_entity
    end

    @opportunity.adapt!
    redirect_to @opportunity, notice: "Resume adapted."
  rescue RubyLLM::Error, GeneratedResume::Error => e
    @opportunity&.destroy
    flash.now[:alert] = e.message
    @opportunity = Current.professional.opportunities.build(opportunity_params)
    render :new, status: :unprocessable_entity
  end

  private

    def set_opportunity
      @opportunity = Current.professional.opportunities.find(params[:id])
    end

    def opportunity_params
      params.require(:opportunity).permit(:organization_name, :posting, :tone)
    end
end
