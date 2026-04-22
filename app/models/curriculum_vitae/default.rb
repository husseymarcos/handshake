class CurriculumVitae
  class Default
    PATH = Rails.root.join("config/default.typst")

    def content
      File.read(PATH)
    end
  end
end
