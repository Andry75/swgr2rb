# Harness service
## Overview
The harness service includes tests and endpoint object models. The service's prime use is to perform testing.

## Project directories overview
```
.
├── configs
├── endpoint_object_models
│   ├── config_loaders
│   ├── json_validator
│   ├── object_models
│   └── prototypes
├── features
│   ├── component
│   ├── step_definitions
│   └── support
└── request_sender
    └── conductor_sender
```

The `configs` folder contains service's configuration files.

The `endpoint_object_models` folder contains all things related to the endpoint models such as the `JSON validator`
component, the `Config loader` component, and prototypes like `JSON schema data types` and `Request object`.

The `features` folder contains the Cucumber tests which are readable.
All tests are located in the subfolder `component`.

The `request_sender` folder includes the `conductor_sender`, which is used for sending requests to the application.

## Service configuration

The service is configurable. The configuration file is in the `configs` directory.
The configuration file includes info about the location of the application.
In other words, it includes info on how to have access to the application.

```yaml
connection:
  protocol: 'https://'
  host: '<HOST>'
  port: '<PORT>'
```

## Setting up a local environment and run tests locally

The Harness service was written on Ruby and that is why it is required to install RVM (Ruby Version Master)
and ruby 2.6.5 as well.

To install RVM complete the following steps:

* Add the GPG key to your system by performing the following command:

```bash
gpg2 --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
``` 

* Download and install RVM by performing the following command:

```bash
curl -sSL https://get.rvm.io | bash -s stable
``` 

* To install ruby perform the following command:

```bash
rvm install ruby-2.6.5
rvm --default use ruby-2.6.5
```

The Harness service uses different libs, that's why to perform tests locally it is required to install them as well. 
To do this perform the following command in the project folder:

```bash
bundle install
``` 

To execute tests perform one of the following commands:

```bash
cucumber
```

To execute a specific test perform the following command:

```bash
cucumber --tags '<testcase_tag>' --tags '<component_tag>'
```
