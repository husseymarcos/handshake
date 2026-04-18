class JobApplicationsController < ApplicationController
  before_action :set_job_application, only: %i[ show ]

  def index
    @job_applications = Current.user.job_applications.reverse_chronologically
  end

  def show
  end

  def new
    @job_application = Current.user.job_applications.build
  end

  def create
    @job_application = Current.user.job_applications.build(job_application_params)
    unless @job_application.save
      return render :new, status: :unprocessable_entity
    end

    @job_application.generate_resume!
    if @job_application.job_description_truncated?
      flash[:warning] = "Job description was shortened to stay within the #{Handshake::JOB_DESCRIPTION_MAX_TOKENS} token limit."
    end
    redirect_to @job_application, notice: "Resume generated."
  rescue JobApplication::UnableToFitOnePage => e
    @job_application&.destroy
    flash.now[:alert] = e.to_s
    @job_application = Current.user.job_applications.build(job_application_params)
    render :new, status: :unprocessable_entity
  rescue RubyLLM::Error, ResumeTypstPdf::Error => e
    @job_application&.destroy
    flash.now[:alert] = e.message
    @job_application = Current.user.job_applications.build(job_application_params)
    render :new, status: :unprocessable_entity
  end

  private

    def set_job_application
      @job_application = Current.user.job_applications.find(params[:id])
    end

    def job_application_params
      params.require(:job_application).permit(:company_name, :job_description)
    end
end
