require 'erb'
require 'fileutils'
require_relative '../../roku_builder_generator'


def default_config()
  return {
    :component_dir => "brands/%brand%/components",
    :config_dir => "brands/%brand%/region/US/configs",
    :template_dir => "roku_builder_generator"
  }
end

def default_output_dir(component_type, brand = 'core', base_dir = nil)
  base_dir = base_dir || default_config[:component_dir]
  base_dir = replace_brand(base_dir, brand)
  return "#{base_dir}/#{component_type.capitalize()}s"
end

def default_config_dir(component_type, brand = 'core', base_dir = nil)
  base_dir = base_dir || default_config[:config_dir]
  base_dir = replace_brand(base_dir, brand)
  return "#{base_dir}/#{component_type.capitalize()}s"
end


def replace_brand(directory, newBrand = 'core')
  directory["%brand%"]=newBrand
  return directory
end

module RokuBuilder

  class Generator < Util
    extend Plugin



    # Hash of commands
    # Each command defines a hash with three optional values
    # Setting device to true will require that there is an avaiable device
    # Setting source to true will require that the user passes a source option
    #   with the command
    # Setting stage to true will require that the user passes a stage option
    #   with the command
    def self.commands
      {
        generate: {}
      }
    end


    def get_output_dir( component_type, component_name, brand, parent_dir = nil, custom_dir = nil, base_component_dir = nil )
      output_dir = get_directory_name(component_type, component_name)
      unless parent_dir.nil? || "" === parent_dir
        output_dir = parent_dir+"/"+output_dir
      end
      base_dir = !custom_dir.nil? ? replace_brand(custom_dir, brand) : default_output_dir(component_type, brand, base_component_dir)
      return "./#{base_dir}/#{output_dir}"

    end

    def get_config_output_dir( component_type, brand, custom_dir = nil )
      base_dir = !custom_dir.nil? ? replace_brand(custom_dir, brand) : default_config_dir(component_type, brand)
      return "./#{base_dir}"
    end

    # Hook to add options to the parser
    # The keys set in options for commands must match the keys in the commands
    #   hash
    def self.parse_options(parser:,  options:)
      parser.separator "Commands:"
      options[:brand] = 'core'
      parser.on("--generate COMPONENT_TYPE", "Generate a component: manager, module, task, screen") do |component_type|
        options[:generate] = component_type
      end
      parser.on("--name COMPONENT_NAME", "Name of the component") do |component_name|
        options[:name] = component_name
      end
      parser.separator "Options:"
      parser.on("--extends COMPONENT_NAME", "A component to extend") do |component_name|
       options[:extends] = component_name
      end
      parser.on("--for-brand BRAND", "Brand to put component in (default:' core')") do |brand|
        options[:brand] = brand
      end
      parser.on("--base-dir", "Base directory for generated brs/xml code (eg.: '#{default_output_dir('<type>')}')") do |base_dir|
        options[:custom_dir] = base_dir
      end
      parser.on("--with-config", "Add empty config JSON") do |d|
        options[:with_config] = true
      end
      parser.on("--config-dir", "Use custom directory for config json (eg.: '#{default_config_dir('<type>')}')") do |d|
        options[:config_dir] = d
      end
      parser.on("--dry-run", "Do not write files, just output") do |d|
        options[:dry_run] = true
      end
    end

    # Array of plugins the this plugin depends on
    def self.dependencies
      []
    end

    def init
      #Setup
    end

    def capitalizeFirst(name)
      name.slice(0,1).capitalize + name.slice(1..-1)
    end

    def get_file_name(component_type, name)
      if(component_type == 'screen' && !name.end_with?("Screen"))
        return name+ "Screen"
      end
      if(component_type === 'manager'&& !name.end_with?("Manager"))
        return name+'Manager'
      end
      return name
    end

    def get_directory_name(component_type, name)
      if(component_type === 'manager'&& !name.end_with?("Manager"))
        return name+'Manager'
      end
      return name
    end

    def component_has_config_json(component_type)
      ['module', 'screen', 'manager'].include? component_type

    end

    def generate(options:)
      if(!options[:name])
        raise InvalidOptions, "Missing component name"
      end
      if(!options[:generate])
        raise InvalidOptions, "Missing component type"
      end
      config = read_config()
      component_type = options[:generate].downcase
      component_name_parts = options[:name].split('/')
      component_proper_name = capitalizeFirst(component_name_parts.last)
      component_parent_dir = component_name_parts.first(component_name_parts.size-1).join('/')
      brand =  options[:brand].downcase

      component_name = get_file_name(component_type, component_proper_name)
      component = RokuBuilderGenerator::BrsComponent.new(component_name, options[:extends], component_type, @logger)
      xml_text = component.render("xml")
      brs_text = component.render("brs")
      json_text = options[:with_config] && component_has_config_json(component_type) ? component.render("json") : nil

      output_dir = get_output_dir(component_type, component_name, brand, component_parent_dir, options[:custom_dir], config[:component_dir])
      output_config_dir = get_config_output_dir(component_type,  brand, options[:config_dir])
      output_file_name = File.join(output_dir, component_name)
      output_config_file_name = File.join(output_config_dir, component_proper_name)

      if(options[:dry_run])
        @logger.unknown "Dry Run, not writing files"
        show_line()
        display_file(output_file_name+".xml", xml_text)
        display_file(output_file_name+".brs", brs_text)
        display_file(output_config_file_name+".json", json_text)
      else
        @logger.unknown "Writing files"
        show_line()
        FileUtils.mkdir_p output_dir
        unless json_text.nil?
          FileUtils.mkdir_p output_config_dir
        end
        write_file(output_file_name+".xml", xml_text)
        write_file(output_file_name+".brs", brs_text)
        write_file(output_config_file_name+".json", json_text)
      end
    end


    def display_file(output_file_name, contents)
      unless contents.nil?
        @logger.unknown output_file_name
        @logger.info "\n"+ contents
        show_line
      end
    end

    def write_file(output_file_name, contents)
      unless contents.nil?
        @logger.unknown output_file_name
        if File.exist?(output_file_name)
          @logger.warn "#{output_file_name} already exists, skipping"
        else
          File.open(output_file_name, "w") { |f| f.write contents }
        end
      end
    end

    def show_line
      @logger.info  "------"
    end

    def config_path()
      config_json_file =  "./.roku_builder_generator.json"
      unless File.exist?(config_json_file)
        @logger.warn "Missing Generator Config File (#{config_json_file}) - using default values"
        return nil
      end
      return config_json_file
    end

    def read_config()
      config = default_config
      unless config_path.nil?
        File.open(config_path) do |io|
          config.merge!(JSON.parse(io.read, {symbolize_names: true}))
        end
      end
      config
    end

  end


# Register your plugin
  RokuBuilder.register_plugin(Generator)
end