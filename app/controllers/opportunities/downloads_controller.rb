class Opportunities::DownloadsController < ApplicationController
  def show
    opportunity = Current.professional.opportunities.find(params[:opportunity_id])
    raise ActiveRecord::RecordNotFound unless opportunity.pdf.attached?

    send_data opportunity.pdf.download,
      filename: opportunity.pdf.filename.to_s,
      type: opportunity.pdf.content_type,
      disposition: params.fetch(:disposition, "attachment")
  end
end
