FROM alpine:3.20

ENV REVIEWDOG_VERSION=v0.20.2

RUN apk add git curl jq gcompat

ENV SHELLCHEK_VERSION=v0.10.0

RUN set -x; \
  arch="$(uname -m)"; \
  echo "arch is $arch"; \
  if [ "${arch}" = 'armv7l' ]; then \
  arch='armv6hf'; \
  fi; \
  url_base='https://github.com/koalaman/shellcheck/releases/download/'; \
  tar_file="${SHELLCHEK_VERSION}/shellcheck-${SHELLCHEK_VERSION}.linux.${arch}.tar.xz"; \
  wget "${url_base}${tar_file}" -O - | tar xJf -; \
  mv "shellcheck-${SHELLCHEK_VERSION}/shellcheck" /bin/; \
  rm -rf "shellcheck-${SHELLCHEK_VERSION}"; \
  ls -laF /bin/shellcheck

COPY install-octoscan.sh /install-octoscan.sh

RUN sh /install-octoscan.sh && rm /install-octoscan.sh

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
