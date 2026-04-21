class Opportunity < ApplicationRecord
  class UnableToFitOnePage < StandardError
    def to_s
      "Unable to fit content to one page. Try removing capabilities or shortening posting."
    end
  end

  REFINEMENT_HINTS = [
    "Tighten vertical spacing, reduce margin sizes slightly, and remove blank lines between sections.",
    "Use a slightly smaller body font (e.g. 9–9.5pt) and compact section headings.",
    "Aggressively shorten bullets: one line each, drop lowest-priority items if needed."
  ].freeze

  belongs_to :professional
  has_one_attached :pdf

  validates :organization_name, presence: true
  validates :posting, presence: true

  before_validation :normalize_posting

  scope :reverse_chronologically, -> { order(created_at: :desc) }

  def adapt!
    raise ActiveRecord::RecordInvalid, self unless valid?

    typst = resume_adapter.adapt(organization_name:, posting:, refinement: nil)
    pdf_bytes, final_typst = compile_pdf_bytes!(typst:)

    transaction do
      pdf.attach(
        io: StringIO.new(pdf_bytes),
        filename: "#{organization_name.parameterize.presence || 'resume'}.pdf",
        content_type: "application/pdf"
      )
      update!(generated_typst: final_typst)
    end
  end

  private

    def resume_adapter
      @resume_adapter ||= ResumeAdapter.new(professional)
    end

    def normalize_posting
      text = posting.to_s
      if Handshake.estimate_tokens(text) > Handshake::JOB_DESCRIPTION_MAX_TOKENS
        self.posting = text.truncate(Handshake::JOB_DESCRIPTION_MAX_CHARS, omission: "")
        self.posting_truncated = true
      else
        self.posting_truncated = false
      end
    end

    def compile_pdf_bytes!(typst:)
      4.times do |i|
        pdf_bytes = ResumeTypstPdf.compile_to_pdf_bytes(typst)
        pages = ResumeTypstPdf.page_count(pdf_bytes)
        return [ pdf_bytes, typst ] if pages == 1

        raise UnableToFitOnePage if i == 3

        typst = resume_adapter.adapt(
          organization_name:,
          posting:,
          refinement: REFINEMENT_HINTS[i]
        )
      end

      raise UnableToFitOnePage
    end
end
