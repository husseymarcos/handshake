module ResumeGeneratable
  extend ActiveSupport::Concern

  def adapt!
    raise ActiveRecord::RecordInvalid, self unless valid?

    resume = ResumeWriter.new(professional).generate(organization_name:, posting:)

    transaction do
      attach_pdf(resume.pdf)
      update!(generated_typst: resume.source)
    end
  end

  private

  def attach_pdf(pdf_bytes)
    pdf.attach(io: StringIO.new(pdf_bytes), filename: pdf_filename, content_type: "application/pdf")
  end

  def pdf_filename
    "#{organization_name.parameterize.presence || 'resume'}.pdf"
  end
end
