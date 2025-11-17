FROM hashicorp/terraform:1.13 AS terraform
FROM ghcr.io/terraform-linters/tflint:v0.60.0 AS tflint

# Build
FROM ubuntu:questing-20251007

# Copy all needed files
COPY entrypoint.sh /
COPY --from=terraform /bin/terraform /usr/bin/terraform
COPY --from=tflint /usr/local/bin/tflint /usr/bin/tflint

# Install needed packages
SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]
RUN chmod +x /entrypoint.sh /usr/bin/terraform /usr/bin/tflint

# Finish up
CMD ["tflint -v"]
WORKDIR /github/workspace
ENTRYPOINT ["/entrypoint.sh"]
