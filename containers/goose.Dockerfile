# See also: https://goose-docs.ai/docs/tutorials/goose-in-docker
FROM debian:trixie-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
      ca-certificates \
      curl \
      git \
      jq \
      python3 \
      python3-pip \
      procps \
      bzip2 \
    && rm -rf /var/lib/apt/lists/*

RUN curl --fail --silent --show-error --location \
  https://github.com/aaif-goose/goose/releases/download/stable/download_cli.sh \
  | CONFIGURE=false bash

ENV PATH="/root/.local/bin:${PATH}"

WORKDIR /workspace

ENTRYPOINT ["goose"]
CMD ["session"]
