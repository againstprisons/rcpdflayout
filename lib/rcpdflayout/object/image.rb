# frozen_string_literal: true

module RcPdfLayout
  # The base object class
  class Object
    # An image object
    class Image < RcPdfLayout::Object
      # The image to render in this object
      attr_accessor :object_image
      # How to position the image within this object's bounds.
      #
      # Can be +:stretch+ to stretch the image to fit the bounds,
      # or +:fit+ to fit one edge of the image to the bounds.
      # @return [Symbol]
      attr_accessor :object_image_fit

      # Create a new image object.
      # @param position_mm [Array<Float>] The position of the object on the page,
      #   as an array of +x, y+ positions, in millimeters, from the top left of
      #   the page
      # @param size_mm [Array<Float>] The size of the object, as an array of
      #   +width, height+, in millimeters
      # @param ppi [Integer] Number of pixels per inch for this object, used for
      #   creating the base image object, and final rendering
      def initialize(position_mm, size_mm, ppi, opts = {})
        super([0, 0], size_mm, ppi, opts)

        @object_image = nil
        @object_image_fit = :fit
      end

      # Return the final rendered version of this object as an image.
      #
      # @param opts [Hash] Render options
      # @return [MiniMagick::Image] Rendered image
      def render_final(opts = {})
        ppi = opts.fetch(:force_ppi, @ppi).to_f
        create_base_image(opts) if deferred?

        # Scale object image to our PPI
        object_image = @object_image.dup

        # Get some things
        object_image_size_px = object_image.dimensions.join('x')
        img_size_px = @image.dimensions.join('x')

        # Calculate resize / final geometry
        oi_geom, oi_gw, oi_gh = nil, 0, 0
        if @object_image_fit == :fit
          oi_rw = object_image.width.to_f / @image.width.to_f
          oi_rh = object_image.height.to_f / @image.height.to_f
          if oi_rw > oi_rh
            oi_gh = object_image.height.to_f / oi_rw
            oi_gw = @image.width.to_f
          else
            oi_gw = object_image.width.to_f / oi_rh
            oi_gh = @image.height.to_f
          end

          oi_geom = "+#{((@image.width.to_f / 2) - (oi_gw / 2)).to_i}+#{((@image.height.to_f / 2) - (oi_gh / 2)).to_i}"
        else
          oi_gw, oi_gh = @image.width.to_f, @image.height.to_f
          oi_geom = "+0+0"
        end

        # Do resize of object image
        object_image.combine_options do |mg|
          mg.resize [oi_gw, oi_gh].join('x')
          mg.repage '0x0'
        end

        # Compose onto final image
        @image = @image.composite(object_image) do |mg|
          mg.compose 'over'
          mg.geometry oi_geom
        end

        # Process queue if deferred        
        image_queue_process if deferred?

        @image
      end
    end
  end
end
