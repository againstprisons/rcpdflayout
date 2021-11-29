# frozen_string_literal: true

require 'commonmarker'

module RcPdfLayout
  module TextMarkup
    # A CommonMarker renderer that outputs RcPdfLayout markup.
    class CommonMarkerRenderer < ::CommonMarker::Renderer
      def text(node) # :nodoc:
        out(node.string_content)
      end

      def header(_) # :nodoc:
        block do
          out("^(b)", :children, "^(b)")
        end
      end

      def paragraph(_) # :nodoc:
        blocksep unless @in_tight
        out(:children)
        blocksep unless @in_tight
      end

      def list(node) # :nodoc:
        old_in_tight = @in_tight
        @in_tight = true

        out(:children)

        @in_tight = old_in_tight
      end

      def list_item(_) # :nodoc:
        block do
          out(" \u2022 ", :children)
        end
      end

      def emph(_) # :nodoc:
        out("^(i)", :children, "^(i)")
      end

      def strong(_) # :nodoc:
        out("^(b)", :children, "^(b)")
      end

      def blocksep # :nodoc:
        return if @stream.string.empty?
        out("\n")
      end

      def softbreak(_) # :nodoc:
        # do nothing
      end

      def linebreak(_) # :nodoc:
        out("\n")
      end
    end

    module_function

    # Parse a Markdown document into RcPdfLayout text markup segments
    def parse_from_markdown(text)
      doc = CommonMarker.render_doc(text)
      renderer = CommonMarkerRenderer.new

      lines = renderer.render(doc).split("\n")
      lines.map do |line|
        parse_segments(line)
      end
    end
  end
end
