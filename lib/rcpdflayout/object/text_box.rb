# frozen_string_literal: true

module RcPdfLayout
  # The base object class
  class Object
    # A bounded text container.
    #
    # +TextBox+ will automatically perform line wrapping of text, should the
    # lines of text to be rendered not fit within the width of the boundary,
    # but line breaks can also be made explicit.
    class TextBox < RcPdfLayout::Object
      # The font to render the inner text segments with
      # @return [String]
      attr_accessor :font_name
      # The font size to render the inner text segments with
      # @return [Integer]
      attr_accessor :font_size
      # The default foreground color to render the inner text segments with
      # @return [String]
      attr_accessor :color
      # The text markup segments to render within this text box, where each
      # line is an array of hashes (the output of a parsing function within
      # +RcPdfLayout::TextMarkup).
      #
      # @return [Array<Array<Hash>>]
      attr_accessor :text_segment_lines

      # Create a new text box object.
      # @param position_mm [Array<Float>] The position of the object on the page,
      #   as an array of +x, y+ positions, in millimeters, from the top left of
      #   the page
      # @param size_mm [Array<Float>] The size of the object, as an array of
      #   +width, height+, in millimeters
      # @param ppi [Integer] Number of pixels per inch for this object, used for
      #   creating the base image object, and final rendering
      def initialize(position_mm, size_mm, ppi, opts = {})
        opts.merge!({ defer_image: true })
        super(position_mm, size_mm, ppi, opts)

        @font_name = opts.fetch(:font, 'DeJaVu-Sans')
        @font_size = opts.fetch(:font_size, 12)
        @color = opts.fetch(:color, 'black')
      end

      # Return this text box as a rendered image
      #
      # @param opts [Hash] Render options
      # @return [MiniMagick::Image] Rendered image
      def render_final(opts = {})
        # Get our PPI
        ppi = opts.fetch(:force_ppi, opts[:parent].ppi).to_f

        # We're always deferred, create base
        create_base_image(opts.merge({ force_ppi: ppi }))

        # Convert pixel size into millimeters (in case we got +:force_size+)
        @size_mm = [@image.width, @image.height]
                   .map { |px| (px.to_i / ppi) / RcPdfLayout::MM_TO_INCH }

        # Set up some state
        line_ypos = 0
        render_opts = {
          font_name: @font_name,
          font_size: @font_size,
          color: @color,
          force_ppi: ppi,
          parent: self
        }.merge(opts[:text_render_opts] || {})

        # For each of our segment lines, wrap and render them using the
        # +render_text+ class method
        @text_segment_lines.each do |mline|
          line_segs = self.class.render_text(mline, @size_mm.first, render_opts)

          line_segs.each_with_index do |line, _line_idx|
            line_xpos = 0
            line_heights = []

            line.each do |textseg|
              ch_img = textseg.render_final(render_opts)

              # Blit to our base image
              ch_geometry = "+#{line_xpos}+#{line_ypos}"
              @image = @image.composite(ch_img) do |mg|
                mg.define 'png:color-type=6'

                mg.compose 'over'
                mg.geometry ch_geometry
              end

              # Update our segment positioning
              line_xpos += ch_img.width
              line_heights << ch_img.height
            end

            line_ypos += line_heights.max + (2 * RcPdfLayout::MM_TO_INCH * ppi) unless line_heights.empty?
          end
        end

        # Process queue on top of rendered text
        image_queue_process

        # Return rendered image
        @image
      end

      # Renders the given +segments+ (the output of a parsing function within
      # +RcPdfLayout::TextMarkup+) into an array containing arrays of
      # +RcPdfLayout::Object::TextSegment+ objects, performing line wrapping
      # where needed to fit the text within the given boundary (where the
      # boundary is defined as +width_mm+ wide).
      #
      # @param segments [Array<Hash>]
      # @param width_mm [Float] The width of the text boundary, in millimeters
      # @param opts [Hash] Text segment creation options
      # @return [Array<Array<RcPdfLayout::Object::TextSegment>>]
      #   An array of arrays of text segment objects, where each inner array
      #   represents a single line of text that fits within the boundary.
      def self.render_text(segments, width_mm, opts = {})
        ppi = opts.fetch(:force_ppi, 72)
        lines = []

        line_segs = []
        line_xpos = 0
        segments.each_with_index do |seg, _idx|
          rseg = ::RcPdfLayout::Object::TextSegment.from_markup_segment([line_xpos, 0], seg, opts)
          rimg = rseg.render_final(force_ppi: ppi)

          # Get width in millimeters of our rendered segment, use that to check
          # if we've run past the boundary, and to bump line_xpos if we haven't
          r_width_mm = (rimg.width.to_i / ppi) / RcPdfLayout::MM_TO_INCH
          if line_xpos + r_width_mm > width_mm
            # We need to decide here whether to just wholly bump this segment
            # to the next line, or to break it. Here's the logic.
            #
            # If we would need to split this segment near the start (which
            # we'll define as "less than one half of it's current width"),
            # just bump it entirely to the next line.
            #
            # Otherwise, split it as close to the boundary as we can, allowing
            # for the insertion of an ASCII hyphen character at the end of the
            # current line to signify continuation.

            if line_xpos + (r_width_mm / 2) > width_mm
              # Bump to next line
              lines << line_segs
              line_segs = []
              line_xpos = 0
            end

            # Duplicate of the original check: if we're longer than the line
            # will allow (even after a potential line bump), then split the
            # segment. Otherwise, append to the current line as usual
            if line_xpos + r_width_mm > width_mm
              # Do a rough guess as to where we need to split based on the
              # length of the segment's text (in characters) compared to the
              # segment's width (in millimeters). This assumes a monospace
              # font, but it gets us Close Enough™ to where we need to be, and
              # we can adjust from there

              r_text = seg[:word]
              line_avspace = width_mm - line_xpos
              r_char_width = (r_width_mm / r_text.length).to_f
              r_split_chars = (line_avspace / r_char_width).floor - 1

              until r_text.nil? || r_text&.empty?
                r_split_seg = seg.dup
                r_split_seg[:word] = r_text[0..r_split_chars]
                r_split_seg[:word] += '-' if r_split_seg[:word].length < r_text.length

                r_split_tseg = ::RcPdfLayout::Object::TextSegment.from_markup_segment([line_xpos, 0], r_split_seg, opts)
                r_split_timg = r_split_tseg.render_final(force_ppi: ppi)
                r_split_width_mm = (r_split_timg.width.to_i / ppi) / RcPdfLayout::MM_TO_INCH

                if line_xpos + r_split_width_mm > width_mm
                  # Try again :(
                  r_split_chars -= 1

                  if r_split_chars <= 1
                    # Can't do anything, bump to next line
                    lines << line_segs
                    line_segs = []
                    line_xpos = 0
                    r_split_chars = r_text.length
                  end

                  next

                else
                  # We're good! Append this text segment to the current line,
                  # cut +r_text+ at the length of the split, check if we need
                  # to create a new line (and do so), and maybe iterate again.
                  line_segs << r_split_tseg
                  r_text = r_text[(r_split_chars + 1)..]

                  # If +r_text+ is now empty, we're at the end of this segment,
                  # so we don't need to create a new line.
                  unless r_text.nil? || r_text&.empty?
                    lines << line_segs
                    line_segs = []
                    line_xpos = 0
                  end
                end
              end

            else
              line_xpos += r_width_mm
              line_segs << rseg
            end

          else
            # Append the segment to the current line and bump line_xpos
            line_xpos += r_width_mm
            line_segs << rseg
          end
        end

        # We got to the end! Throw the current segments in and return the list
        lines << line_segs
        lines
      end
    end
  end
end
