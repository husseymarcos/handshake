class GeneratedResume
  class Error < StandardError; end
  class EmptySourceError < Error; end
  class CompilationError < Error; end

  def self.from_response(response)
    new(strip_code_fence(response))
  end

  def self.strip_code_fence(response)
    source = response.to_s.strip

    if (match = source.match(/\A```(?:typst)?\s*\n(.+?)\n```\z/m))
      match[1].strip
    elsif source.start_with?("```")
      source.sub(/\A```(?:typst)?\s*\n?/, "").sub(/\n```\z/, "").strip
    else
      source
    end
  end

  def initialize(source)
    @source = source.to_s.strip
  end

  def source
    raise EmptySourceError, "empty model response" if @source.blank?

    @source
  end

  def pdf
    Dir.mktmpdir("handshake-typst") do |dir|
      source_path = File.join(dir, "resume.typ")
      pdf_path = File.join(dir, "resume.pdf")

      File.write(source_path, source)
      output = IO.popen([ typst_bin, "compile", source_path, pdf_path ], err: [ :child, :out ], &:read)
      raise CompilationError, output unless $?.success?

      File.binread(pdf_path)
    end
  end

  private

  def typst_bin
    ENV.fetch("TYPST_BIN", "typst")
  end
end
