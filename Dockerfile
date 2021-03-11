FROM ubuntu:xenial

ENV LANG=C.UTF-8
ENV ARTIFACTS_DIR=/tmp/artifacts
ENV DEBIAN_FRONTEND=noninteractive
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true

# Install software-properties-common to provide `add-apt-repository`.
RUN apt-get update -q && apt-get install -yq --no-install-recommends software-properties-common
RUN add-apt-repository ppa:ondrej/php \
    && apt-get update -q \
    && apt-get install -yq --no-install-recommends \
        bzip2 \
        curl \
        gcc \
        g++ \
        git \
        make \
        php7.4-cli \
        unzip \
        zip \
    && apt-get clean \
    && rm -r /var/lib/apt/lists/*

# Install Composer
## Requires PHP to be installed.
## Requires run by root to install into global bin.
RUN curl -s https://raw.githubusercontent.com/composer/getcomposer.org/76a7060ccb93902cd7576b67264ad91c8a2700e2/web/installer \
    | php -- --install-dir=/usr/local/bin --filename=composer

# Create worker user (+home) and artifacts directories.
RUN useradd -m worker \
    && mkdir -p /app ${ARTIFACTS_DIR} \
    && chown worker:worker /app ${ARTIFACTS_DIR}

# Add build script.
COPY --chown=worker build.sh /build.sh
RUN chmod +x /build.sh

USER worker

# Install nvm as worker user.
## Node binaries and modules will be installed in user-owned directories.
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.37.2/install.sh | bash

WORKDIR /app

CMD [ "/build.sh" ]