class ResumeTypstPdf
  class Error < StandardError; end
  class CompilationError < Error; end
  class PdfInfoError < Error; end

  class << self
    def compile_to_pdf_bytes(source)
      Dir.mktmpdir("handshake-typst") do |dir|
        typ_path = File.join(dir, "cv.typ")
        pdf_path = File.join(dir, "cv.pdf")
        File.write(typ_path, source)
        run!(typ_bin, "compile", typ_path, pdf_path)
        File.binread(pdf_path)
      end
    end

    def page_count(pdf_bytes)
      Dir.mktmpdir("handshake-pdfinfo") do |dir|
        path = File.join(dir, "doc.pdf")
        File.binwrite(path, pdf_bytes)
        out = IO.popen([ pdfinfo_bin, path ], err: [ :child, :out ], &:read)
        raise PdfInfoError, "pdfinfo failed: #{out}" unless $?.success?

        if (m = out.match(/Pages:\s*(\d+)/i))
          m[1].to_i
        else
          raise PdfInfoError, "could not parse Pages from pdfinfo output"
        end
      end
    end

    def typ_bin
      ENV.fetch("TYPST_BIN", "typst")
    end

    def pdfinfo_bin
      ENV.fetch("PDFINFO_BIN", "pdfinfo")
    end

    private

      def run!(*cmd)
        output = IO.popen([ *cmd ], err: [ :child, :out ], &:read)
        raise CompilationError, "#{cmd.join(" ")} failed: #{output}" unless $?.success?
      end
  end
end
