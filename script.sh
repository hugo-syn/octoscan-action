REVIEWDOG_VERSION=v0.20.2

# hadolint ignore=DL3006
apt install git curl jq

SHELLCHEK_VERSION=v0.10.0

set -x; \
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

wget -O - -q https://raw.githubusercontent.com/reviewdog/reviewdog/master/install.sh| sh -s -- -b /usr/local/bin/ ${REVIEWDOG_VERSION}



RUN sh /install-octoscan.sh && rm /install-octoscan.sh

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
