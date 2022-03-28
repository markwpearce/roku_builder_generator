require 'erb'
require_relative "./utils"

module RokuBuilderGenerator

  class BrsComponent
    include ERB::Util

    attr_accessor :name, :extends, :template_type


    def initialize(name, extends, template_type, logger = nil, local_file_dir = nil)
      @name = name
      @extends = extends
      @template_type = template_type
      @logger = logger
      @local_file_dir = local_file_dir || RokuBuilderGenerator::NAME
    end

    def render(file_type)
      file_name = get_template_name(@template_type, file_type)

      unless file_name.nil?
        template = File.read(file_name)
        return render_template(template)
      end
      return nil
    end

    def renderTest(file_type)
      file_name = get_template_name("test", file_type)

      unless file_name.nil?
        template = File.read(file_name)
        return render_template(template)
      end
      return nil
    end

    def renderTestSetup()
      file_name = get_template_name("test.setup", "brs")

      unless file_name.nil?
        template = File.read(file_name)
        return render_template(template)
      end
      return nil
    end

    def log(message)
      unless @logger.nil?
        @logger.info message
      else
        puts message
      end
    end

    def get_template_name(template_type, file_type)
      file_name =  "#{template_type}.#{file_type}.erb"
      local_file = "./#{@local_file_dir}/#{file_name}"
      gem_file = RokuBuilderGenerator::Utils.gem_libdir+"/templates/#{file_name}"
      if File.exist?(local_file)
        log "#{file_type}: Using local version of template - #{local_file}"
        return local_file
      elsif  File.exist?(gem_file)
        log "#{file_type}: Using gem version of template - #{gem_file}"
        return gem_file
      end
      if template_type === "default"
        return nil
      end
      return get_template_name("default", file_type)
    end

    def render_template(template)
      return ERB.new(template).result(binding)
    end


  end

end