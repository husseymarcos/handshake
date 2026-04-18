class JobApplications::DownloadsController < ApplicationController
  def show
    application = Current.user.job_applications.find(params[:job_application_id])
    raise ActiveRecord::RecordNotFound unless application.pdf.attached?

    send_data application.pdf.download,
      filename: application.pdf.filename.to_s,
      type: application.pdf.content_type,
      disposition: "attachment"
  end
end
