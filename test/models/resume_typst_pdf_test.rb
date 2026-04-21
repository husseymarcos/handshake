require "test_helper"

class ResumeTypstPdfTest < ActiveSupport::TestCase
  test "compile_to_pdf_bytes returns PDF bytes" do
    skip unless system("which typst > /dev/null 2>&1")

    typst_source = "#set text(size: 12pt)\nHello World"

    pdf_bytes = ResumeTypstPdf.compile_to_pdf_bytes(typst_source)

    assert pdf_bytes.present?
    assert pdf_bytes.start_with?("%PDF")
  end

  test "page_count returns correct number of pages" do
    skip unless system("which typst > /dev/null 2>&1 && which pdfinfo > /dev/null 2>&1")

    typst_source = "#set text(size: 12pt)\nHello"
    pdf_bytes = ResumeTypstPdf.compile_to_pdf_bytes(typst_source)

    pages = ResumeTypstPdf.page_count(pdf_bytes)

    assert_equal 1, pages
  end

  test "page_count raises error for invalid PDF" do
    invalid_pdf = "not a pdf"

    assert_raises(ResumeTypstPdf::PdfInfoError) do
      ResumeTypstPdf.page_count(invalid_pdf)
    end
  end

  test "compile_to_pdf_bytes raises error for invalid typst" do
    skip unless system("which typst > /dev/null 2>&1")

    invalid_typst = "@#$%^&*()"

    assert_raises(ResumeTypstPdf::CompilationError) do
      ResumeTypstPdf.compile_to_pdf_bytes(invalid_typst)
    end
  end

  test "typ_bin returns default value" do
    with_env("TYPST_BIN" => nil) do
      assert_equal "typst", ResumeTypstPdf.typ_bin
    end
  end

  test "typ_bin returns environment variable value" do
    with_env("TYPST_BIN" => "/custom/typst") do
      assert_equal "/custom/typst", ResumeTypstPdf.typ_bin
    end
  end

  test "pdfinfo_bin returns default value" do
    with_env("PDFINFO_BIN" => nil) do
      assert_equal "pdfinfo", ResumeTypstPdf.pdfinfo_bin
    end
  end

  test "pdfinfo_bin returns environment variable value" do
    with_env("PDFINFO_BIN" => "/custom/pdfinfo") do
      assert_equal "/custom/pdfinfo", ResumeTypstPdf.pdfinfo_bin
    end
  end

  private

    def with_env(vars)
      original = {}
      vars.each do |key, value|
        original[key] = ENV[key]
        ENV[key] = value
      end
      yield
    ensure
      original.each do |key, value|
        ENV[key] = value
      end
    end
end
