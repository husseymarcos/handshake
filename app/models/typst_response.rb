module TypstResponse
  module_function

  def extract(raw)
    s = raw.to_s.strip
    if (m = s.match(/\A```(?:typst)?\s*\n(.+?)\n```\z/m))
      m[1].strip
    elsif s.start_with?("```")
      s.sub(/\A```(?:typst)?\s*\n?/, "").sub(/\n```\z/, "").strip
    else
      s
    end
  end
end
