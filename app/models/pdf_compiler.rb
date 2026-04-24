class PdfCompiler
  def initialize(adapter:, typst_compiler: ResumeTypstPdf)
    @adapter = adapter
    @typst_compiler = typst_compiler
  end

  def compile(organization_name:, posting:, **adapter_options)
    typst = adapter.adapt(organization_name:, posting:, **adapter_options)
    pdf_bytes = typst_compiler.compile_to_pdf_bytes(typst)

    [ pdf_bytes, typst ]
  end

  private

  attr_reader :adapter, :typst_compiler
end
