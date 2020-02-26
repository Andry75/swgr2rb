# Swgr2rb

Swgr2rb (Swagger to Ruby) is a tool that generates Ruby classes for JSON schema validation
based on Swagger-generated documentation.
The tool was developed by [Polytech Software](https://polytech.software/).

## Installation

Swgr2rb can be installed with RubyGems:

```shell script
$ gem install swgr2rb
```

## Usage

Swgr2rb can be used in two ways: to generate a new testing framework, or to update an existing one.

In both cases, `swgr2rb` has one required argument and a number of options.
The required argument must be either a URL of Swagger (e.g. `localhost:8080/swagger`)
or a path to the JSON file returned by Swagger (e.g. `docs/swagger.json`).
To read more about the options, view help:

```shell script
$ swgr2rb --help
```

### Generating a new testing framework

Swgr2rb can generate a scaffold of a testing framework:

```shell script
$ swgr2rb <swagger_url|json_file_path> --from-scratch
```

A directory named `harness` will be created, and the scaffold will be generated inside.

The endpoint object models generated from Swagger will be located in the
`endpoint_object_models/object_model/%component_name%`
folder (component's name can be specified with the `-c/--component` option).

More about the generated testing framework's structure can be read in [its README file](./assets/README.md).

### Updating an existing testing framework

Swgr2rb can be used to update the endpoint object models of an existing testing framework:

```shell script
$ swgr2rb <swagger_url|json_file_path> -c <component_name>
```

The tool will update the endpoint object model schema modules (located in
`%target_dir%/%component_name%/object_model_schemas`) according to Swagger,
and create new object model classes and schemas if there are new (previously untested)
endpoints in the documentation.

The behavior can be modified with the following command line options
(check `swgr2rb --help` to read more):

| Option | Description | Default value |
| ---    | ---         | ---           |
| `-t/--target-dir TARGET_DIR` | The target directory for endpoint object models.        | `endpoint_object_models/object_model` |
| `-c/--component COMPONENT`   | The name of the component.                                                       | `component1` |
| `--[no-]update-only`         | Do not create new files (endpoint models and schemas), only update the existing ones. | `false` |
| `--[no-]rewrite-schemas`     | Rewrite schema modules if they already exist.                                         | `true`  |

## License

Swgr2rb is released under the [MIT license](./LICENSE).
