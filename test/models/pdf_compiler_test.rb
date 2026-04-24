require "test_helper"

class PdfCompilerTest < ActiveSupport::TestCase
  test "returns PDF bytes and typst after compiling" do
    adapter = fake_adapter
    compiler = PdfCompiler.new(
      adapter: adapter,
      typst_compiler: fake_typst_compiler
    )

    pdf_bytes, typst = compiler.compile(organization_name: "Acme", posting: "Job")

    assert_equal "pdf-bytes", pdf_bytes
    assert_equal "typst-source", typst
  end

  private

    def fake_adapter
      Class.new do
        def adapt(organization_name:, posting:, **)
          "typst-source"
        end
      end.new
    end

    def fake_typst_compiler
      Class.new do
        define_method(:compile_to_pdf_bytes) do |_|
          "pdf-bytes"
        end
      end.new
    end
end
