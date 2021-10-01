# frozen_string_literal: true

module RcPdfLayout
  # The base object class
  class Object
    # A segment of text
    class TextSegment < RcPdfLayout::Object
      # The font to render this text segment with
      # @return [String]
      attr_accessor :font_name
      # The font size to render this text segment with
      # @return [Integer]
      attr_accessor :font_size
      # The color to render this text segment in
      # @return [String]
      attr_accessor :color
      # The text content of this segment
      # @return [String]
      attr_accessor :text

      # Create a new text segment
      def initialize(position_mm, text, opts = {})
        super(position_mm, [0, 0], 0, opts.merge({ defer_image: true }))

        @font_name = opts.fetch(:font, 'DeJaVu-Sans')
        @font_size = opts.fetch(:font_size, 12)
        @color = opts.fetch(:color, 'black')
        @text = text
      end

      # Return the rendered text segment
      #
      # @param opts [Hash] Render options
      # @return [MiniMagick::Image] Rendered image
      def render_final(opts = {})
        # Get our PPI
        ppi = opts.fetch(:force_ppi, opts[:parent].ppi).to_f

        # Create an image with our text in it
        @image = self.class.create_image do |mg|
          mg.density(ppi)

          mg.background('transparent')
          mg.fill(@color)
          mg.font(@font_name)
          mg.pointsize(@font_size)

          mg << "label:#{@text}"
          mg.repage('0x0')
        end

        # Convert pixel size into millimebers
        @size_mm = [@image.width, @image.height]
                   .map { |px| (px.to_i / ppi) / RcPdfLayout::MM_TO_INCH }

        # Process queue on top of rendered text
        image_queue_process

        # Return rendered image
        @image
      end
    end
  end
end
