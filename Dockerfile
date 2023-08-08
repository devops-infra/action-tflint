# Use a clean tiny image to store artifacts in
FROM alpine:3.18.3

# Labels for http://label-schema.org/rc1/#build-time-labels
# And for https://github.com/opencontainers/image-spec/blob/master/annotations.md
# And for https://help.github.com/en/actions/building-actions/metadata-syntax-for-github-actions
ARG NAME="GitHub Action linting Terraform files"
ARG DESCRIPTION="GitHub Action that will run TFlint on Terraform files"
ARG REPO_URL="https://github.com/devops-infra/action-tflint"
ARG AUTHOR="Krzysztof Szyper / ChristophShyper / biotyk@mail.com"
ARG HOMEPAGE="https://christophshyper.github.io/"
ARG BUILD_DATE=2020-04-01T00:00:00Z
ARG VCS_REF=abcdef1
ARG VERSION=v0.0
LABEL \
  com.github.actions.name="${NAME}" \
  com.github.actions.author="${AUTHOR}" \
  com.github.actions.description="${DESCRIPTION}" \
  com.github.actions.color="purple" \
  com.github.actions.icon="upload-cloud" \
  org.label-schema.build-date="${BUILD_DATE}" \
  org.label-schema.name="${NAME}" \
  org.label-schema.description="${DESCRIPTION}" \
  org.label-schema.usage="README.md" \
  org.label-schema.url="${HOMEPAGE}" \
  org.label-schema.vcs-url="${REPO_URL}" \
  org.label-schema.vcs-ref="${VCS_REF}" \
  org.label-schema.vendor="${AUTHOR}" \
  org.label-schema.version="${VERSION}" \
  org.label-schema.schema-version="1.0"	\
  org.opencontainers.image.created="${BUILD_DATE}" \
  org.opencontainers.image.authors="${AUTHOR}" \
  org.opencontainers.image.url="${HOMEPAGE}" \
  org.opencontainers.image.documentation="${REPO_URL}/blob/master/README.md" \
  org.opencontainers.image.source="${REPO_URL}" \
  org.opencontainers.image.version="${VERSION}" \
  org.opencontainers.image.revision="${VCS_REF}" \
  org.opencontainers.image.vendor="${AUTHOR}" \
  org.opencontainers.image.licenses="MIT" \
  org.opencontainers.image.title="${NAME}" \
  org.opencontainers.image.description="${DESCRIPTION}" \
  maintainer="${AUTHOR}" \
  repository="${REPO_URL}"

# Copy all needed files
COPY entrypoint.sh /

# Install needed packages
RUN set -eux ;\
  chmod +x /entrypoint.sh ;\
  apk update --no-cache ;\
  apk add --no-cache \
    bash~=5.2.15 \
    curl~=8.2.1 \
    git~=2.40.1 ;\
  rm -rf /var/cache/* ;\
  rm -rf /root/.cache/*

# Get Terraform by a specific version or search for the latest one
SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]
# hadolint ignore=SC2015
RUN VERSION="$( curl -LsS https://releases.hashicorp.com/terraform/ | grep -Eo '/[.0-9]+/' | grep -Eo '[.0-9]+' | sort -V | tail -1 )" ;\
  for i in {1..5}; do curl -LsS \
    https://releases.hashicorp.com/terraform/${VERSION}/terraform_${VERSION}_linux_amd64.zip -o ./terraform.zip \
    && break || sleep 15; done ;\
  unzip ./terraform.zip ;\
  rm -f ./terraform.zip ;\
  chmod +x ./terraform ;\
  mv ./terraform /usr/bin/terraform

# Get latest TFLint
SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]
# hadolint ignore=SC2015
RUN DOWNLOAD_URL="$( curl -LsS https://api.github.com/repos/terraform-linters/tflint/releases/latest | grep -o -E "https://.+?_linux_amd64.zip" )" ;\
  for i in {1..5}; do curl -LsS "${DOWNLOAD_URL}" -o ./tflint.zip && break || sleep 15; done ;\
  unzip ./tflint.zip ;\
  rm -f ./tflint.zip ;\
  chmod +x ./tflint ;\
  mv ./tflint /usr/bin/tflint

# Finish up
CMD ["tflint -v"]
WORKDIR /github/workspace
ENTRYPOINT ["/entrypoint.sh"]
