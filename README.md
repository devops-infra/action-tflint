# GitHub Action linting Terraform files

**GitHub Action that will run TFlint on Terraform files.**

Dockerized as [devopsinfra/action-tflint](https://hub.docker.com/repository/docker/devopsinfra/action-tflint).

Container is a stripped down image of my other creation - [devops-infra/docker-terragrunt](https://github.com/devops-infra/docker-terragrunt) - framework for managing Infrastructure-as-a-Code.

So it's main use will be everywhere where [Terraform](https://github.com/hashicorp/terraform) is used and is great for statically or actively checking modules' sources.

Main action is using [wata727](https://github.com/wata727)'s [TFLint](https://github.com/terraform-linters/tflint).


## Badge swag
[![Master branch](https://github.com/devops-infra/action-tflint/workflows/Master%20branch/badge.svg)](https://github.com/devops-infra/action-tflint/actions?query=workflow%3A%22Master+branch%22)
[![Other branches](https://github.com/devops-infra/action-tflint/workflows/Other%20branches/badge.svg)](https://github.com/devops-infra/action-tflint/actions?query=workflow%3A%22Other+branches%22)
<br>
[
![GitHub repo](https://img.shields.io/badge/GitHub-devops--infra%2Faction--tflint-blueviolet.svg?style=plastic&logo=github)
![GitHub code size in bytes](https://img.shields.io/github/languages/code-size/devops-infra/action-tflint?color=blueviolet&label=Code%20size&style=plastic&logo=github)
![GitHub last commit](https://img.shields.io/github/last-commit/devops-infra/action-tflint?color=blueviolet&logo=github&style=plastic&label=Last%20commit)
![GitHub license](https://img.shields.io/github/license/devops-infra/action-tflint?color=blueviolet&logo=github&style=plastic&label=License)
](https://github.com/devops-infra/action-tflint "shields.io")
<br>
[
![DockerHub](https://img.shields.io/badge/DockerHub-devopsinfra%2Faction--tflint-blue.svg?style=plastic&logo=docker)
![Docker version](https://img.shields.io/docker/v/devopsinfra/action-tflint?color=blue&label=Version&logo=docker&style=plastic)
![Image size](https://img.shields.io/docker/image-size/devopsinfra/action-tflint/latest?label=Image%20size&style=plastic&logo=docker)
![Docker Pulls](https://img.shields.io/docker/pulls/devopsinfra/action-tflint?color=blue&label=Pulls&logo=docker&style=plastic)
](https://hub.docker.com/r/devopsinfra/action-tflint "shields.io")


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
