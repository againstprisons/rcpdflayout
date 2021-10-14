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
    # The image containing this object's data, or +nil+ if the image hasn't
    # been created yet
    attr_accessor :image

    # Create a blank image object.
    #
    # The returned image is fully transparent, and is in the PNG format.
    #
    # @yield [MiniMagick::Tool::Magick]
    # @return [MiniMagick::Image] Created image object
    def self.create_image(opts = {}, &block)
      block = proc { |_| } unless block_given?

      MiniMagick::Image.create('.png', false) do |tf|
        out = MiniMagick::Tool::Magick.new do |mg|
          # Set some important things
          mg.define('png:color-type=6')
          mg.define('colorspace:auto-grayscale=false')
          mg.type('TrueColor')

          # Call our block
          block.call(mg)

          # Tell ImageMagick to render this from a transparent canvas
          mg.xc('none') unless opts[:no_xc]

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
    # @param opts [Hash] Options hash
    # @param opts :defer_image [true, false] (true)
    #   Whether to defer image creation, and all image operations, until the
    #   +render_final+ method is called
    def initialize(position_mm, size_mm, ppi, opts = {})
      @position_mm = position_mm
      @ppi = ppi
      @size_mm = size_mm

      @is_deferred = opts.fetch(:defer_image, true)

      @image_queue = []
      @image = create_base_image unless @is_deferred
    end

    # Returns whether image operations are deferred until render time
    #
    # @return [true, false]
    def deferred?
      @is_deferred
    end

    # Perform operations on the object's image in place, returning +self+.
    #
    # @yield [MiniMagick::Tool::Mogrify]
    # @return [RcPdfLayout::Object]
    def mogrify(&block)
      block = proc { |_| } unless block_given?

      if deferred?
        @image_queue << [:mogrify, block]
      else
        @image.combine_options(&block)
      end

      self
    end

    # Composite a second image onto the object's image, returning +self+.
    #
    # @param image [MiniMagick::Image] Image to composite
    # @yield [MiniMagick::Tool::Composite]
    # @return [RcPdfLayout::Object]
    def composite(image, &block)
      block = proc { |_| } unless block_given?

      if deferred?
        @image_queue << [:composite, image, block]
      else
        @image = @image.composite(image, &block)
      end

      self
    end

    # Return the final rendered version of this object as an image.
    #
    # The base Object class implements this method to just return the value of
    #   the +image+ property of the Object.
    #
    # @return [MiniMagick::Image] Rendered image
    def render_final(opts = {})
      if deferred?
        create_base_image(opts)
        image_queue_process

      else
        ppi = opts.fetch(:force_ppi, @ppi).to_f

        img_size = @size_mm.map { |mm| ((mm * RcPdfLayout::MM_TO_INCH) * ppi).to_i }
        img_size = opts[:force_size] if opts.key?(:force_size)
        img_size_px = img_size.join('x')

        @image.combine_options do |mg|
          mg.resize img_size_px
          mg.repage '0x0'
        end
      end

      @image
    end

    private

    # Create and store the base image for this object
    def create_base_image(opts = {})
      ppi = opts.fetch(:force_ppi, @ppi).to_f

      size_px = @size_mm.map { |mm| ((mm * RcPdfLayout::MM_TO_INCH) * ppi).to_i }
      size_px = opts[:force_size] if opts.key?(:force_size)

      @image = self.class.create_image { |mg| mg.size(size_px.join('x')) }
    end

    # Process and reset this object's image operation queue
    def image_queue_process
      queue = @image_queue
      @image_queue = []

      queue.each do |op, *args|
        case op
        when :mogrify
          @image.combine_options(&args.first)

        when :composite
          @image = @image.composite(args.first, &args.last)

        else
          raise "unknown image operation #{op.inspect}"
        end
      end
    end
  end
end
