# frozen_string_literal: true

require 'commonmarker'

module RcPdfLayout
  # Text markup parser.
  #
  # The text markup used by RcPdfLayout is relatively simple. Markup tags are
  # formatted as +^(TAG[,param[,param[,...]]])+ (that is, a carat, a left
  # parenthesis, the tag name, any parameters to the tag separated by commas,
  # and then a right parenthesis to close).
  #
  # The parser will automatically "close" a single tag when a tag with the same
  # name is encountered (for example, +^(b)hello^(b) world+ will present the
  # "hello" in "hello world" as bold). All open tags can be closed with the
  # +^(r)+ (reset) tag.
  #
  # The known tags are as follows:
  #
  # * +^(b)+ - bold
  # * +^(i)+ - italic
  # * +^(u)+ - underline
  # * +^(c,COLOR)+ - set text foreground color to +COLOR+
  # * +^(f,FONT)+ - set text font to +FONT+
  # * +^(s,SIZE)+ - set text font size to +SIZE+
  # * +^(r)+ - reset all tags
  module TextMarkup
    # A CommonMarker renderer that outputs RcPdfLayout markup.
    class CommonMarkerRenderer < ::CommonMarker::Renderer
      def text(node) # :nodoc:
        out(node.string_content)
      end

      def header(_) # :nodoc:
        block do
          out('^(b)', :children, '^(b)')
        end
      end

      def paragraph(_) # :nodoc:
        blocksep unless @in_tight
        out(:children)
        blocksep unless @in_tight
      end

      def blockquote(_) # :nodoc:
        blocksep unless @in_tight
        out(:children)
        blocksep unless @in_tight
      end

      def list(_node) # :nodoc:
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
        out('^(i)', :children, '^(i)')
      end

      def strong(_) # :nodoc:
        out('^(b)', :children, '^(b)')
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
