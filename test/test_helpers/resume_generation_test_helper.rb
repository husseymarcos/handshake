module ResumeGenerationTestHelper
  def with_fake_resume_generation(pdf_bytes: minimal_pdf)
    original_generate = ResumeWriter.instance_method(:generate)
    ResumeWriter.define_method(:generate) do |**_args|
      GeneratedResume.new("#set text[Hello]")
    end

    original_pdf = GeneratedResume.instance_method(:pdf)
    GeneratedResume.define_method(:pdf) { pdf_bytes }

    yield
  ensure
    ResumeWriter.define_method(:generate, original_generate)
    GeneratedResume.define_method(:pdf, original_pdf)
  end

  def minimal_pdf
    <<~PDF
      %PDF-1.4
      1 0 obj
      << /Type /Catalog /Pages 2 0 R >>
      endobj
      2 0 obj
      << /Type /Pages /Kids [3 0 R] /Count 1 >>
      endobj
      3 0 obj
      << /Type /Page /Parent 2 0 R /MediaBox [0 0 612 792] >>
      endobj
      xref
      0 4
      0000000000 65535 f
      0000000009 00000 n
      00000000058 00000 n
      0000000115 00000 n
      trailer
      << /Size 4 /Root 1 0 R >>
      startxref
      196
      %%EOF
    PDF
  end
end
