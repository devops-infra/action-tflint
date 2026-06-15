FROM hashicorp/terraform:1.15 AS terraform
FROM ghcr.io/terraform-linters/tflint:v0.63.1 AS tflint

# Build
FROM alpine:3.24.0

# Copy all needed files
COPY entrypoint.sh /
COPY --from=terraform /bin/terraform /usr/bin/terraform
COPY --from=tflint /usr/local/bin/tflint /usr/bin/tflint
COPY alpine-packages.txt /tmp/alpine-packages.txt

# Install needed packages
SHELL ["/bin/ash", "-euxo", "pipefail", "-c"]
# hadolint ignore=DL3018
RUN set -eux; \
  xargs -r apk add --no-cache < /tmp/alpine-packages.txt; \
  chmod +x /entrypoint.sh /usr/bin/terraform /usr/bin/tflint; \
  terraform version; \
  tflint --version; \
  rm -rf /var/cache/*; \
  rm -rf /root/.cache/*; \
  rm -rf /tmp/*

# Finish up
CMD ["tflint", "--version"]
WORKDIR /github/workspace
ENTRYPOINT ["/entrypoint.sh"]
