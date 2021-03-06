# frozen_string_literal: true

module RcPdfLayout
  # The base object class
  class Object
    # A page object, used for constructing documents
    class Page < RcPdfLayout::Object
      # The child objects contained within this page
      # @return [Array<RcPdfLayout::Object>]
      attr_accessor :children

      # Create a new page object.
      #
      # @param size_mm [Array<Float>] The size of the page, as an array of
      #   +width, height+, in millimeters. You can use one of the +PAGE_SIZE_*+
      #   constants (such as +RcPdfLayout::PAGE_SIZE_A4+) here.
      # @param ppi [Integer] Number of pixels per inch for this object, used for
      #   creating the base image object, and final rendering.
      def initialize(size_mm, ppi, opts = {})
        opts.merge!({ defer_image: true })
        super([0, 0], size_mm, ppi, opts)

        @children = []
      end

      # Return the final rendered version of this page as an image.
      #
      # @param opts [Hash] Render options
      # @return [MiniMagick::Image] Rendered image
      def render_final(opts = {})
        # We're always deferred, create base and process queue
        create_base_image(opts)
        image_queue_process

        # Form the options for child objects
        opts.merge!({ parent: self })
        ppi = opts.fetch(:force_ppi, @ppi).to_f

        # Array of [[pos_x, pos_y], image] of this page's children
        final_children = @children.map do |child|
          ch_pos_px = child.position_mm.map { |mm| ((mm * RcPdfLayout::MM_TO_INCH) * ppi).to_i }

          ch_opts = {}
          ch_opts[:force_size] = calculate_child_size(child, ppi) unless child.size_mm.map(&:zero?).any?

          ch_img = child.render_final(opts.merge(ch_opts))
          [ch_pos_px, ch_img]
        end

        # If opts[:draw_object_borders] is not +nil+, iterate over our child images
        # and draw a 0.5mm border around the edge of the object, treating the value
        # as a color (or using a semi-transparent red if the value is not a String)
        if opts[:draw_object_borders]
          size_px = (RcPdfLayout::MM_TO_INCH * ppi * 0.5).to_i
          color = opts[:draw_object_borders]
          color = '#ff000077' unless color.is_a?(String)

          final_children.each do |_, ch_img|
            ch_img.combine_options do |mg|
              mg.shave "#{size_px}x#{size_px}"
              mg.bordercolor(color).border("#{size_px}x#{size_px}")
            end
          end
        end

        # Blit the child images onto our base image object, at the right positions
        final_children.each do |ch_pos_px, ch_img|
          ch_geometry = "+#{ch_pos_px.first}+#{ch_pos_px.last}"
          @image = @image.composite(ch_img) do |mg|
            mg.compose 'over'
            mg.geometry ch_geometry
          end
        end

        # And return our composed image
        @image
      end
    end

    def calculate_child_size(child, ppi = nil)
      ppi = @ppi if ppi.nil?
      ch_width_mm, ch_height_mm = *child.size_mm

      ch_width_mm = @size_mm.first + ch_width_mm if ch_width_mm.negative?
      ch_height_mm = @size_mm.last + ch_height_mm if ch_height_mm.negative?

      [ch_width_mm, ch_height_mm].map { |mm| ((mm * RcPdfLayout::MM_TO_INCH) * ppi).to_i }
    end
  end
end
