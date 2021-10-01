# frozen_string_literal: true

module RcPdfLayout
  # The base object class
  class Object
    # The position of the object on the page, as an array of +x, y+ positions,
    # in millimeters, from the top left of the page
    attr_accessor :position_mm
    # The size of the object, as an array of +width, height+, in millimeters
    attr_accessor :size_mm
    # Number of pixels per inch for this object
    attr_accessor :ppi
    # The image containing this object's data
    attr_accessor :image

    # Create a blank image object.
    #
    # The returned image is fully transparent, and is in the PNG format.
    #
    # @yield [MiniMagick::Tool::Magick]
    # @return [MiniMagick::Image] Created image object
    def self.create_image(&block)
      block = Proc.new { |_| nil } unless block_given?

      MiniMagick::Image.create('.png', false) do |tf|
        out = MiniMagick::Tool::Magick.new do |mg|
          block.call(mg)

          # Tell ImageMagick to render this from a transparent canvas
          mg << 'xc:none'

          # Output to stdout as a 32bit PNG
          mg << 'PNG32:-'
        end

        tf.write out
        tf.rewind
      end
    end

    # @param position_mm [Array<Float>] The position of the object on the page,
    #   as an array of +x, y+ positions, in millimeters, from the top left of
    #   the page
    # @param size_mm [Array<Float>] The size of the object, as an array of
    #   +width, height+, in millimeters
    # @param ppi [Integer] Number of pixels per inch for this object, used for
    #   creating the base image object, and final rendering
    def initialize(position_mm, size_mm, ppi)
      @position_mm = position_mm
      @ppi = ppi
      @size_mm = size_mm

      size_px = @size_mm.map { |mm| ((mm * RcPdfLayout::MM_TO_INCH) * @ppi).to_i }
      @image = self.class.create_image { |mg| mg.size(size_px.join('x')) }
    end

    # Perform operations on the object's image in place, returning +self+.
    #
    # @yield [MiniMagick::Tool::Mogrify]
    # @return [RcPdfLayout::Object]
    def mogrify(&block)
      @image.combine_options(&block) if block_given?

      self
    end

    # Composite a second image onto the object's image, returning +self+.
    #
    # @param image [MiniMagick::Image] Image to composite
    # @yield [MiniMagick::Tool::Composite]
    # @return [RcPdfLayout::Object]
    def composite(image, &block)
      @image = @image.composite(image, &block)

      self
    end

    # Return the final rendered version of this object as an image.
    #
    # The base Object class implements this method to just return the value of
    #   the +image+ property of the Object.
    #
    # @return [MiniMagick::Image] Rendered image
    def render_final(_opts = {})
      @image
    end
  end
end
