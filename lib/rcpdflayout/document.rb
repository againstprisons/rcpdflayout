# frozen_string_literal: true

require 'tmpdir'
require 'fileutils'

module RcPdfLayout
  # Representation of a PDF document consisting of one or more pages
  class Document
    # Array of page objects contained within this document
    # @return [Array<RcPdfLayout::Object>]
    attr_accessor :pages

    # Create a new empty document.
    def initialize
      @pages = []
    end

    # Write this document to a named PDF file.
    #
    # @param opts [Hash] Render options
    # @param opts :page_opts [Hash] Options passed to each page's renderer
    # @param opts :image_write_opts [Hash] Options passed to the image writer
    def write(filename, opts = {})
      # Make a temporary directory for our rendered page images
      tempdir = Dir.mktmpdir('rcpdflayout')
      page_files = []

      # Get options to pass to individual methods
      imgwrite_opts = opts.fetch(:image_write_opts, {})
      page_opts = opts.fetch(:page_opts, {})

      # Render each page, write it's image to our temp dir
      @pages.each_with_index do |page, idx|
        page_image = page.render_final(page_opts)
        page_path = File.join(tempdir, "page-#{idx}.png")
        RcPdfLayout::Utils.image_write(page_image, page_path, imgwrite_opts)

        page_files << page_path
      end

      # Get the maximum page PPI
      max_ppi = @pages.map(&:ppi).max.to_s

      # Compose a PDF from the page images
      MiniMagick::Tool::Magick.new(whiny: true) do |mg|
        # Add each page PNG, in order
        page_files.each do |fn|
          mg << fn
        end

        # Set our PPI
        mg.units('PixelsPerInch').density(max_ppi)

        # And write to our output file
        mg << filename
      end

      # Delete our temporary directory
      FileUtils.rm_r(tempdir)
    end
  end
end
