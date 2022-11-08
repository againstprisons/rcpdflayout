# frozen_string_literal: true

module RcPdfLayout
  # RcPdfLayout version number
  VERSION = '0.1.0.pre.2'

  # :section: Page size constants

  # Size of an A4 page, in millimeters
  PAGE_SIZE_A4 = [210.0, 297.0].freeze

  # Size of a US Letter page, in millimeters
  PAGE_SIZE_LETTER = [215.9, 279.4].freeze

  # :section: Unit conversion constants

  # 1 millimeter, as a fraction of an inch
  MM_TO_INCH = 0.039370087
end
