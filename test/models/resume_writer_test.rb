require "test_helper"

class ResumeWriterTest < ActiveSupport::TestCase
  test "generating a resume uses the extracted system instructions" do
    chat = FakeChat.new("#set text[Hello]")
    writer = ResumeWriter.new(professionals(:alice), chat: chat)

    writer.generate(organization_name: "Acme", posting: "A posting")

    assert_equal ResumeWriter.system_instructions, chat.instructions
  end

  test "generating a resume includes the selected tone in the prompt" do
    chat = FakeChat.new("#set text[Hello]")
    writer = ResumeWriter.new(professionals(:alice), chat: chat)

    writer.generate(organization_name: "Acme", posting: "A posting", tone: "Technical")

    assert_includes chat.prompt, "Tone: Technical"
  end

  test "generating a resume returns a generated resume" do
    writer = ResumeWriter.new(professionals(:alice), chat: FakeChat.new("#set text[Hello]"))

    resume = writer.generate(organization_name: "Acme", posting: "A posting")

    assert_instance_of GeneratedResume, resume
    assert_equal "#set text[Hello]", resume.source
  end

  test "generating a resume raises when the model returns nothing" do
    writer = ResumeWriter.new(professionals(:alice), chat: FakeChat.new(""))

    assert_raises(GeneratedResume::EmptySourceError) do
      writer.generate(organization_name: "Acme", posting: "A posting")
    end
  end

  class FakeChat
    attr_reader :instructions, :prompt, :messages

    def initialize(content)
      @content = content
      @messages = []
    end

    def with_instructions(instructions)
      @instructions = instructions
    end

    def ask(prompt)
      @prompt = prompt
      @messages << Struct.new(:content).new(@content)
    end
  end
end
