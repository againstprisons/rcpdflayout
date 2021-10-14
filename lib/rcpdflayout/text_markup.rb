# frozen_string_literal: true

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
    # Regular expression used for capturing markup tags
    TAG_CONTENT_REGEXP = /\^\(([A-Za-z]+(?:,[^,)]+)*)\)/.freeze

    module_function

    # Parse a string of marked-up text into it's individual segments.
    #
    # A "text segment" is defined as either a whole word (where the whole word
    # uses the same tags), or a partial word (where there is a change of tag
    # state part way through the word). A "word" is defined as any text
    # separated by whitespace.
    #
    # Whitespace from the input text is not preserved intact. Any and all
    # whitespace between words in the input text sequence is transformed such
    # that the output contains a single text segment for that whitespace,
    # consisting of a single ASCII space character. As such, newline characters
    # are not preserved, and this function should only be passed a single
    # logical line of text at a time.
    #
    # @param text [String] The potentially-marked-up text to parse
    # @return [Array<Hash>]
    #   Array of hashes, one hash per text segment, where the text segment is
    #   contained in the +:word+ key, and any open tags at the time the segment
    #   was encountered are in the +:tags+ key.
    def parse_segments(text)
      words = []
      open_tags = {}

      until text.empty?
        # Consume all the whitespace at the start of the string. If we consumed
        # any whitespace, then add a single space as a word with an empty tag
        # list
        unless /^\s+/m.match(text).nil?
          text = text.lstrip
          words << {
            word: ' ',
            tags: {}
          }
        end

        # Do we have a tag at the start of our text?
        unless (tag_content = /^#{TAG_CONTENT_REGEXP}/.match(text)&.[](1)).nil?
          # Cut tag out of text string
          text = text[(3 + tag_content.length)..]

          # Parse apart the tag
          tag, *tag_params = tag_content.split(',')
          case tag
          when 'r'
            # Reset everything
            open_tags = {}

          else
            # Some other tag - if +tag_params+ is empty, close the tag,
            # otherwise store the new params
            if open_tags.key?(tag) && tag_params.empty?
              open_tags.delete(tag)
            else
              open_tags[tag] = tag_params || []
            end
          end
        end

        # Get the word up to either the next tag or the next whitespace
        # character, jumping back to the start of the loop if there isn't
        # actually a word here
        this_word = text.split(/\s/, 2).first&.split(TAG_CONTENT_REGEXP, 2)&.first
        next if this_word.nil? || this_word&.empty?

        # Cut this word out of text string
        text = text[this_word.length..]

        # Append to our word list
        words << {
          word: this_word.dup,
          tags: open_tags.dup
        }
      end

      words
    end
  end
end
