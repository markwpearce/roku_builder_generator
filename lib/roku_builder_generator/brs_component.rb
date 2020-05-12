require 'erb'
require_relative "./utils"

module RokuBuilderGenerator

  class BrsComponent
    include ERB::Util

    attr_accessor :name, :extends, :template_type


    def initialize(name, extends, template_type)
      @name = name
      @extends = extends
      @template_type = template_type
    end

    def render(file_type)
      file_name = get_template_name(@template_type, file_type)

      unless file_name.nil?
        template = File.open(file_name, "+r")
        return render_template(template)
      end
      return nil
    end

    private

    def get_template_name(template_type, file_type)
      file_name =  "#{template_type}.#{file_type}.erb"
      local_file = "./roku-generator/"+file_name
      gem_file = RokuBuilderGenerator::Utils.gem_libdir+"/templates/#{file_name}"
      if File.exist?(local_file)
        puts "#{file_type}: Using local version of template - #{local_file}"
        return local_file
      elsif  File.exist?(gem_file)
        puts "#{file_type}: Using local version of template - #{gem_file}"
        return gem_file
      end
      return nil
    end

    def render_template(template)
       return ERB.new(template).result(binding)
    end


  end

end