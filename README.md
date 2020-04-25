# Lint Terraform files

GitHub Action automatically linting Terraform modules.

Dockerized as [christophshyper/action-tflint](https://hub.docker.com/repository/docker/christophshyper/action-tflint).

Container is a stripped down image of my other creation - [ChristophShyper/docker-terragrunt](https://github.com/ChristophShyper/docker-terragrunt) - framework for managing Infrastructure-as-a-Code.

So it's main use will be everywhere where [Terraform](https://github.com/hashicorp/terraform) is used and is great for statically or actively checking modules' sources.

Main action is using [wata727](https://github.com/wata727)'s [TFLint](https://github.com/terraform-linters/tflint).


## Badge swag
[
![GitHub](https://img.shields.io/badge/github-devops--infra%2Faction--tflint-brightgreen.svg?style=flat-square&logo=github)
![GitHub code size in bytes](https://img.shields.io/github/languages/code-size/devops-infra/action-tflint?color=brightgreen&label=Code%20size&style=flat-square&logo=github)
![GitHub last commit](https://img.shields.io/github/last-commit/devops-infra/action-tflint?color=brightgreen&label=Last%20commit&style=flat-square&logo=github)
](https://github.com/devops-infra/action-tflint "shields.io")
[![Push to master](https://github.com/devops-infra/action-tflint/workflows/Push%20to%20master/badge.svg)](https://github.com/devops-infra/action-tflint/actions?query=workflow%3A%22Push+to+master%22)
[![Push to other](https://github.com/devops-infra/action-tflint/workflows/Push%20to%20other/badge.svg)](https://github.com/devops-infra/action-tflint/actions?query=workflow%3A%22Push+to+other%22)
<br>
[
![DockerHub](https://img.shields.io/badge/docker-christophshyper%2Faction--tflint-blue.svg?style=flat-square&logo=docker)
![Dockerfile size](https://img.shields.io/github/size/devops-infra/action-tflint/Dockerfile?label=Dockerfile%20size&style=flat-square&logo=docker)
![Image size](https://img.shields.io/docker/image-size/christophshyper/action-tflint/latest?label=Image%20size&style=flat-square&logo=docker)
![Docker Pulls](https://img.shields.io/docker/pulls/christophshyper/action-tflint?color=blue&label=Pulls&logo=docker&style=flat-square)
![Docker version](https://img.shields.io/docker/v/christophshyper/action-tflint?color=blue&label=Version&logo=docker&style=flat-square)
](https://hub.docker.com/r/christophshyper/action-tflint "shields.io")


## Reference

```yaml
    - name: Run the Action
      uses: devops-infra/action-tflint@master
      with:
        dir_filter: modules
```

Input Variable | Required | Default |Description
:--- | :---: | :---: | :---
dir_filter | No | `*` | Prefixes or sub-directories to search for Terraform modules. Use comma as separator.
fail_on_changes | No | `true` | Whether TFLint should fail whole action.
tflint_config | No | `.tflint.hcl` | Location from repository root to TFLint config file. Disables `tflint_params`.
tflint_params | No | `` | Parameters passed to TFLint binary. See [TFLint](https://github.com/terraform-linters/tflint) for details.


## Examples

By default fail if lint errors found in any subdirectory. Run the Action via GitHub.
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
      uses: devops-infra/action-tflint@master
```

Use different location for TFLint config file and parse only `aws*` and `gcp*` modules in `modules/` directory. Run the Action via GitHub.
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
      uses: devops-infra/action-tflint@master
      with:
        tflint_config: modules/.tflint.hcl
        dir_filter: modules/aws,modules/gcp
```

Use deep check (need cloud credentials) and treat all directories under `modules` as Terraform modules. Run the Action via DockerHub.
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
      uses: devops-infra/action-tflint@master
      with:
        tflint_params: "--module --deep"
        dir_filter: modules
```
