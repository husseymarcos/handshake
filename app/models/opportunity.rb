class Opportunity < ApplicationRecord
  class UnableToFitOnePage < StandardError
    def to_s
      "Unable to fit content to one page. Try removing skills or shortening job description."
    end
  end

  REFINEMENT_HINTS = [
    "Tighten vertical spacing, reduce margin sizes slightly, and remove blank lines between sections.",
    "Use a slightly smaller body font (e.g. 9–9.5pt) and compact section headings.",
    "Aggressively shorten bullets: one line each, drop lowest-priority items if needed."
  ].freeze

  belongs_to :user
  has_one_attached :pdf

  validates :company_name, presence: true
  validates :job_description, presence: true

  before_validation :normalize_job_description

  scope :reverse_chronologically, -> { order(created_at: :desc) }

  def generate_resume!
    raise ActiveRecord::RecordInvalid, self unless valid?

    typst = resume_synthesizer.synthesize(company_name:, job_description:, refinement: nil)
    pdf_bytes, final_typst = compile_pdf_bytes!(typst:)

    transaction do
      pdf.attach(
        io: StringIO.new(pdf_bytes),
        filename: "#{company_name.parameterize.presence || 'resume'}.pdf",
        content_type: "application/pdf"
      )
      update!(generated_typst: final_typst)
    end
  end

  private

    def resume_synthesizer
      @resume_synthesizer ||= User::ResumeSynthesizer.new(user)
    end

    def normalize_job_description
      text = job_description.to_s
      if Handshake.estimate_tokens(text) > Handshake::JOB_DESCRIPTION_MAX_TOKENS
        self.job_description = text.truncate(Handshake::JOB_DESCRIPTION_MAX_CHARS, omission: "")
        self.job_description_truncated = true
      else
        self.job_description_truncated = false
      end
    end

    def compile_pdf_bytes!(typst:)
      4.times do |i|
        pdf_bytes = ResumeTypstPdf.compile_to_pdf_bytes(typst)
        pages = ResumeTypstPdf.page_count(pdf_bytes)
        return [ pdf_bytes, typst ] if pages == 1

        raise UnableToFitOnePage if i == 3

        typst = resume_synthesizer.synthesize(
          company_name:,
          job_description:,
          refinement: REFINEMENT_HINTS[i]
        )
      end

      raise UnableToFitOnePage
    end
end
