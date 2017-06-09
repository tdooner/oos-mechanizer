require 'mechanize'

module OosMechanizer
  class Error < StandardError; end

  autoload :ResultProcessor, 'oos_mechanizer/result_processor'
  autoload :Searcher, 'oos_mechanizer/searcher'
end
