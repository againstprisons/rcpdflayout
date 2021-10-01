# frozen_string_literal: true

module RcPdfLayout
  # Miscellaneous utility functions
  module Utils
    module_function

    # Write a potentially-optimized version of a +MiniMagick::Image+ to the given
    # output file.
    #
    # This attempts to call +pngcrush+ with the image's temporary file as input,
    # writing to the given output file. If running +pngcrush+ fails, the image is
    # written to the output file normally.
    #
    # @param image [MiniMagick::Image] Image to write
    # @param filename [String] Output file
    # @param opts [Hash] Options
    # @param opts :pngcrush_output [true, false] (false)
    #   How to handle the standard error output of +pngcrush+.
    #   If set to +false+ (the default), all output is discarded.
    #   If set to +true+, output will be printed if +pngcrush+ returns a non-zero
    #   exit code.
    def image_write(image, filename, opts = {})
      command = ['pngcrush', '-warn', image.tempfile.path, filename]
      shell = MiniMagick::Shell.new
      _stdout, stderr, status = shell.run(command, whiny: false)

      # Did pngcrush work?
      unless status.zero?
        if opts.fetch(:pngcrush_output, false)
          warn "#{command.join(' ')} failed: exitstatus #{status.inspect}\n#{stderr}"
        end

        # Write image normally
        image.write(filename)
      end

      filename
    end
  end
end
