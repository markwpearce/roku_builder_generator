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
Options:
        --extends COMPONENT_NAME     A component to extend
        --for-brand BRAND            Brand to put component in (default:' core')
        --base-dir                   Base directory for generated brs/xml code (eg.: 'brands/core/components/<type>s')
        --with-config                Add empty config JSON
        --config-dir                 Use custom directory for config json (eg.: 'brands/core/region/US/configs/<type>s')
        --with-tests                 Add unit tests
        --only-tests                 Only unit tests
        --tests-dir                  Use custom directory for unit tests

```

### Examples

Generate a manager called "FooManager", with an empty configuration JSON file:

`roku --generate manager --name foo --with-config`

Generate a task ("Bar"), but just display the output on screen:

`roku --generate task --name bar --dry-run -V`

Generate a module ("Buz"), and also generate config and unit tests

`roku --generate module --name buz --with-config --with-tests`

### Config

You can supplement the default configuration using a local file `.roku_builder_generator.json`

Format of config file:

```js
{
  "component_dir": "base/directory/for/components", // default: "./brands/%brand%/components"
  "config_dir": "base/directory/for/config/json/files", // default: "./brands/%brand%/region/US/configs"
  "template_dir": "directory/for/templates" // default: "./roku_builder_generator"
}
```

### Directories and Brands

Unless you specify a custom directory, generated files will be placed in the default directory. For example,
`roku --generate manager --name foo --with-config`
will generate the following files:

- ./brands/core/components/Managers/FooManager/FooManager.xml
- ./brands/core/components/Managers/FooManager/FooManager.brs
- ./brands/core/region/US/configs/Managers/Foo.json

without specifying custom directories, files can be generated for other brands. For example,

`roku --generate manager --name foo --for-brand comedy --with-config`

will generate:

- ./brands/comedy/components/Managers/FooManager/FooManager.xml
- ./brands/comedy/components/Managers/FooManager/FooManager.brs
- ./brands/comedy/region/US/configs/Managers/Foo.json

To enable changing brands for directories specified in `.roku_builder_generator.json`, use `%brand%` in the position where the brand should be replaced.

For example, if you specify `"component_dir": "some/directory/%brand%/components"` and you ran the command

`roku --generate manager --name foo --for-brand my-brand`

it would generate files

- ./some/directory/my-brand/components/Managers/FooManager/FooManager.xml
- ./some/directory/my-brand/components/Managers/FooManager/FooManager.brs

Note: If nothing is specified by the `--for-brand` option, it will use "core".

### Custom Templates

You can add custom templates for different component types by adding [ERB](https://www.stuartellis.name/articles/erb/) files to the template directory (either `./roku_builder_generator` or whatever was defined in the config).

The template file name must be of the form `<component_name>.<file_extension>.erb`

For example, to add a custom template for module SceneGraph XML files, create the file:

`./roku_builder_generator/module.xml.erb`
