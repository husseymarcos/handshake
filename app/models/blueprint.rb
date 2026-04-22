class Blueprint
  def self.for(_professional)
    Default.new
  end

  def initialize(source)
    @source = source
  end

  def content
    source.content
  end

  private

  attr_reader :source
end
