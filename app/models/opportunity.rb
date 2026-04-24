class Opportunity < ApplicationRecord
  TONES = %w[Professional Enthusiastic Technical Formal Casual].freeze

  belongs_to :professional
  has_one_attached :pdf

  validates :organization_name, presence: true
  validates :posting, presence: true
  validates :tone, inclusion: { in: TONES, allow_blank: true }

  before_validation :normalize_posting

  scope :reverse_chronologically, -> { order(created_at: :desc) }

  def adapt!
    raise ActiveRecord::RecordInvalid, self unless valid?

    pdf_bytes, final_typst = pdf_compiler.compile(organization_name:, posting:, tone:)

    transaction do
      pdf.attach(
        io: StringIO.new(pdf_bytes),
        filename: pdf_filename,
        content_type: "application/pdf"
      )
      update!(generated_typst: final_typst)
    end
  end

  private

    def normalize_posting
      self.posting, self.posting_truncated = PostingNormalizer.new(posting).normalize
    end

    def pdf_compiler
      PdfCompiler.new(adapter: resume_adapter)
    end

    def resume_adapter
      ResumeAdapter.new(professional)
    end

    def pdf_filename
      "#{organization_name.parameterize.presence || 'resume'}.pdf"
    end
end
