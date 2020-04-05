# Lint Terraform files

Dockerized ([christophshyper/action-tflint](https://hub.docker.com/repository/docker/christophshyper/action-tflint)) GitHub Action automatically linting Terraform modules.

Container is a stripped down image of my other creation - [ChristophShyper/docker-terragrunt](https://github.com/ChristophShyper/docker-terragrunt) - framework for managing Infrastructure-as-a-Code.

So it's main use will be everywhere where [Terraform](https://github.com/hashicorp/terraform) is used and is great for statically checking modules' sources.

Main action is using [wata727](https://github.com/wata727)'s [TFLint](https://github.com/terraform-linters/tflint).


## Badge swag
[
![GitHub](https://img.shields.io/badge/github-ChristophShyper%2Faction--ftflint-brightgreen.svg?style=flat-square&logo=github)
![GitHub code size in bytes](https://img.shields.io/github/languages/code-size/christophshyper/action-tflint?color=brightgreen&label=Code%20size&style=flat-square&logo=github)
![GitHub last commit](https://img.shields.io/github/last-commit/christophshyper/action-tflint?color=brightgreen&label=Last%20commit&style=flat-square&logo=github)
![On each commit push](https://img.shields.io/github/workflow/status/christophshyper/action-tflint/On%20each%20commit%20push?color=brightgreen&label=Actions&logo=github&style=flat-square)
](https://github.com/christophshyper/action-tflint "shields.io")

[
![DockerHub](https://img.shields.io/badge/docker-christophshyper%2Faction--tflint-blue.svg?style=flat-square&logo=docker)
![Dockerfile size](https://img.shields.io/github/size/christophshyper/action-tflint/Dockerfile?label=Dockerfile&style=flat-square&logo=docker)
![Docker Pulls](https://img.shields.io/docker/pulls/christophshyper/action-tflint?color=blue&label=Pulls&logo=docker&style=flat-square)
![Docker version](https://img.shields.io/docker/v/christophshyper/action-tflint?color=blue&label=Version&logo=docker&style=flat-square)
](https://hub.docker.com/r/christophshyper/action-tflint "shields.io")


## Usage

Input Variable | Required | Default |Description
:--- | :---: | :---: | :---
dir_filter | No | `*` | Prefixes or sub-directories to search for Terraform modules. Use comma as separator.
fail_on_changes | No | `true` | Whether TFLint should fail whole action.
tflint_config | No | `.tflint.hcl` | Location from repository root to TFLint config file. Disables `tflint_params`.
tflint_params | No | `` | Parameters passed to TFLint binary. See [TFLint](https://github.com/terraform-linters/tflint) for details.


## Examples

By default fail if lint errors found in any subdirectory.
```yaml
name: Check TFLint
on:
  push:
    branches:
      - "**"
jobs:
  format-hcl:
    runs-on: ubuntu-latest
    steps:
    - name: Checkout
      uses: actions/checkout@v2
    - name: Check linting of Terraform files
      uses: docker://christophshyper/action-tflint:latest
```

Use different location for TFLint config file and parse only `aws*` and `gcp*` modules in `modules/` directory.
```yaml
name: Check TFLint with custom config
on:
  push:
    branches:
      - "**"
jobs:
  format-hcl:
    runs-on: ubuntu-latest
    steps:
    - name: Checkout
      uses: actions/checkout@v2
    - name: Check linting of Terraform modules
      uses: docker://christophshyper/action-tflint:latest
      with:
        tflint_config: modules/.tflint.hcl
        dir_filter: modules/aws,modules/gcp
```

Use deep check (need cloud credentials) and treat all directories under `modules` as Terraform modules.
```yaml
name: Check TFLint with custom config
on:
  push:
    branches:
      - "**"
jobs:
  format-hcl:
    runs-on: ubuntu-latest
    steps:
    - name: Checkout
      uses: actions/checkout@v2
    - name: Check linting of Terraform modules
      uses: docker://christophshyper/action-tflint:latest
      with:
        tflint_params: "--module --deep"
        dir_filter: modules
```
