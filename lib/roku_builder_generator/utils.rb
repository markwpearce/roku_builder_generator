module RokuBuilderGenerator
  module Utils

    # Return a directory with the project libraries.
    def self.gem_libdir

      t = ["#{File.dirname(__FILE__)}",
           "#{File.dirname(File.expand_path($0))}/../lib/#{RokuBuilderGenerator::NAME}",
           "#{Gem.dir}/gems/#{RokuBuilderGenerator::NAME}-#{RokuBuilderGenerator::VERSION}/lib/#{RokuBuilderGenerator::NAME}"]
      t.each {|i| return i if File.readable?(i) }
      raise "All paths are invalid: #{t}"
    end

    # [...]
  end
end