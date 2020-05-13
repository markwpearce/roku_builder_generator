# RokuBuilderGenerator

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'roku_builder_generator'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install roku_builder_generator

## Usage

The generator plugin has the following commands:

```
Options for RokuBuilder::Generator:
Commands:
        --generate COMPONENT_TYPE    Generate a component: manager, module, task, screen
        --name COMPONENT_NAME        Name of the component
        --extends COMPONENT_NAME     A component to extend
        --base-dir                   Base directory for generated code (eg.: 'brands/core/components/<type>s')
        --with-config                Add empty config JSON
        --config-dir                 Use custom directory for config json (eg.: 'brands/core/region/US/configs/<type>s')
```

### Examples

Generate a manager called "FooManager", with an empty configuration JSON file:

`roku --generate manager --name foo --with-config`

Generate a task ("Bar"), but just display the output on screen:

`roku --generate task --name bar --dry-run -V`

### Config

You can supplement the default configuration using a local file `.roku_builder_generator.json`

Format of config file:

```js
{
  "component_dir": "base/directory/for/components", // default: "./brands/core/components"
  "config_dir": "base/directory/for/config/json/files", // default: "./brands/core/region/US/configs"
  "template_dir": "directory/for/templates" // default: "./roku_builder_generator"
}
```

### Custom Templates

You can add custom templates for different component types by adding [ERB](https://www.stuartellis.name/articles/erb/) files to the template directory (either `./roku_builder_generator` or whatever was defined in the config).

The template file name must be of the form `<component_name>.<file_extension>.erb`

For example, to add a custom template for module SceneGraph XML files, create the file:

`./roku_builder_generator/module.xml.erb`
