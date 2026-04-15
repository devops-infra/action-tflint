# 🚀 GitHub Action linting Terraform files
**GitHub Action that will run TFlint on Terraform files.**


## 📦 Available on
- **Docker Hub:** [devopsinfra/action-tflint:latest](https://hub.docker.com/repository/docker/devopsinfra/action-tflint)
- **GitHub Packages:** [ghcr.io/devops-infra/action-tflint:latest](https://github.com/orgs/devops-infra/packages/container/package/action-tflint)


## ✨ Features
- Main use will be everywhere where [Terraform](https://github.com/hashicorp/terraform) is used and is great for statically or actively checking modules' sources.
- Using [wata727](https://github.com/wata727)'s [TFLint](https://github.com/terraform-linters/tflint).


## 📊 Badges
[
![GitHub repo](https://img.shields.io/badge/GitHub-devops--infra%2Faction--tflint-blueviolet.svg?style=plastic&logo=github)
![GitHub last commit](https://img.shields.io/github/last-commit/devops-infra/action-tflint?color=blueviolet&logo=github&style=plastic&label=Last%20commit)
![GitHub code size in bytes](https://img.shields.io/github/languages/code-size/devops-infra/action-tflint?color=blueviolet&label=Code%20size&style=plastic&logo=github)
![GitHub license](https://img.shields.io/github/license/devops-infra/action-tflint?color=blueviolet&logo=github&style=plastic&label=License)
](https://github.com/devops-infra/action-tflint "shields.io")
<br>
[
![DockerHub](https://img.shields.io/badge/DockerHub-devopsinfra%2Faction--tflint-blue.svg?style=plastic&logo=docker)
![Docker version](https://img.shields.io/docker/v/devopsinfra/action-tflint?color=blue&label=Version&logo=docker&style=plastic&sort=semver)
![Image size](https://img.shields.io/docker/image-size/devopsinfra/action-tflint/latest?label=Image%20size&style=plastic&logo=docker)
![Docker Pulls](https://img.shields.io/docker/pulls/devopsinfra/action-tflint?color=blue&label=Pulls&logo=docker&style=plastic)
](https://hub.docker.com/r/devopsinfra/action-tflint "shields.io")


## 🏷️ Version Tags: vX, vX.Y, vX.Y.Z
This action supports three tag levels for flexible versioning:
- `vX`: latest patch of the major version (e.g., `v1`).
- `vX.Y`: latest patch of the minor version (e.g., `v1.2`).
- `vX.Y.Z`: fixed to a specific release (e.g., `v1.2.3`).




## 📖 API Reference
```yaml
    - name: Run the Action
      uses: devops-infra/action-tflint@v1.0.0
      with:
        dir_filter: modules
```


### 🔧 Input Parameters
| Input Variable    | Required | Default       | Description                                                                                                |
|-------------------|----------|---------------|------------------------------------------------------------------------------------------------------------|
| `dir_filter`      | No       | `*`           | Prefixes or sub-directories to search for Terraform modules. Use comma as separator.                       |
| `fail_on_changes` | No       | `true`        | Whether TFLint should fail whole action.                                                                   |
| `tflint_config`   | No       | `.tflint.hcl` | Location from repository root to TFLint config file. Disables `tflint_params`.                             |
| `tflint_params`   | No       | ``            | Parameters passed to TFLint binary. See [TFLint](https://github.com/terraform-linters/tflint) for details. |
| `run_init`        | No       | `true`        | Whether the action should run `terraform init`. Defaults to true.                                          |


## 💻 Usage Examples

### 📝 Basic Example
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
      uses: actions/checkout@v5

    - name: Check linting of Terraform files
      uses: devops-infra/action-tflint@v1.0.0
```

### 🔀 Advanced Example
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
      uses: actions/checkout@v5

    - name: Check linting of Terraform modules
      uses: devops-infra/action-tflint@v1.0.0
      with:
        tflint_config: modules/.tflint.hcl
        dir_filter: modules/aws,modules/gcp
```

### 🔀 Advanced Example
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
      uses: actions/checkout@v5

    - name: Check linting of Terraform modules
      uses: devops-infra/action-tflint@v1.0.0
      with:
        tflint_params: "--module --deep"
        dir_filter: modules
```


## 🤝 Contributing
Contributions are welcome! See [CONTRIBUTING](https://github.com/devops-infra/.github/blob/master/CONTRIBUTING.md).
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.


## 📄 License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.


## 💬 Support
If you have any questions or need help, please:
- 📝 Create an [issue](https://github.com/devops-infra/action-tflint/issues)
- 🌟 Star this repository if you find it useful!

## Forking
To publish images from a fork, set these variables so Task uses your registry identities:
`DOCKER_USERNAME`, `DOCKER_ORG_NAME`, `GITHUB_USERNAME`, `GITHUB_ORG_NAME`.

Two supported options (environment variables take precedence over `.env`):
```bash
# .env (local only, not committed)
DOCKER_USERNAME=your-dockerhub-user
DOCKER_ORG_NAME=your-dockerhub-org
GITHUB_USERNAME=your-github-user
GITHUB_ORG_NAME=your-github-org
```

```bash
# Shell override
DOCKER_USERNAME=your-dockerhub-user \
DOCKER_ORG_NAME=your-dockerhub-org \
GITHUB_USERNAME=your-github-user \
GITHUB_ORG_NAME=your-github-org \
task docker:build
```

Recommended setup:
- Local development: use a `.env` file.
- GitHub Actions: set repo variables for the four values above, and secrets for `DOCKER_TOKEN` and `GITHUB_TOKEN`.

Publish images without a release:
- Run the `(Manual) Release Create` workflow with `build_only: true` to build and push images without tagging a release.
