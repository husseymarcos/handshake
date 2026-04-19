class OpportunitiesController < ApplicationController
  before_action :set_opportunity, only: %i[ show ]

  def index
    @opportunity = Current.user.opportunities.build
    @opportunities = Current.user.opportunities.reverse_chronologically
  end

  def list
    @opportunities = Current.user.opportunities.reverse_chronologically
  end

  def show
  end

  def new
    @opportunity = Current.user.opportunities.build
  end

  def create
    @opportunity = Current.user.opportunities.build(opportunity_params)
    unless @opportunity.save
      return render :new, status: :unprocessable_entity
    end

    @opportunity.generate_resume!
    if @opportunity.job_description_truncated?
      flash[:warning] = "Job description was shortened to stay within the #{Handshake::JOB_DESCRIPTION_MAX_TOKENS} token limit."
    end
    redirect_to @opportunity, notice: "Resume generated."
  rescue Opportunity::UnableToFitOnePage => e
    @opportunity&.destroy
    flash.now[:alert] = e.to_s
    @opportunity = Current.user.opportunities.build(opportunity_params)
    render :new, status: :unprocessable_entity
  rescue RubyLLM::Error, ResumeTypstPdf::Error => e
    @opportunity&.destroy
    flash.now[:alert] = e.message
    @opportunity = Current.user.opportunities.build(opportunity_params)
    render :new, status: :unprocessable_entity
  end

  private

    def set_opportunity
      @opportunity = Current.user.opportunities.find(params[:id])
    end

    def opportunity_params
      params.require(:opportunity).permit(:company_name, :job_description)
    end
end
