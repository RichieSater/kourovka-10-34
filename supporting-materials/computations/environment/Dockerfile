FROM debian@sha256:7b140f374b289a7c2befc338f42ebe6441b7ea838a042bbd5acbfca6ec875818

ARG GAP_TAR_SHA=aaa296b32a5d7bf25fd80f241d23ec1f58b74e991ae730fafe40e54eb3af6e7e
ARG GAP_FIX_SHA=3e7a00ef8730f6c058213db2f13c076565603ea2467e04aeea756e4afcb76b9f
ARG CTBLLIB_SHA=f201e9da571c681a7bbfb1e4683bdb2c80a23b005099ed0453521f59cb443434
ARG ATLASREP_SHA=1ccb65af694d53f60ba41f85b2293e505c42a2fecf90b36747c1d841a5ce0b47
ARG ELAN_VERSION=4.2.3
ARG ELAN_AMD64_SHA=df0b2b3a439961ffcbb3985214365ffe40f49bc871df04dff268c7d8e21ca8b2
ARG ELAN_ARM64_SHA=cb69af0803b04157bc30201c29c12fca882bb3ad8b43476b8d2d3064810bc3ac
ARG OCAML_VERSION=4.14.2
ARG ROCQ_VERSION=9.2.0
ARG MATHCOMP_VERSION=2.6.0
ENV DEBIAN_FRONTEND=noninteractive PATH=/root/.opam/rocq/bin:/root/.elan/bin:/opt/gap-4.16.0/bin:$PATH GAP_BIN=/opt/gap-4.16.0/gap LC_ALL=C.UTF-8 LANG=C.UTF-8
RUN apt-get update && apt-get install -y --no-install-recommends \
      build-essential ca-certificates curl git libgmp-dev libreadline-dev m4 opam pkg-config python3 xz-utils zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*
RUN curl -LfsS https://github.com/gap-system/gap/releases/download/v4.16.0/gap-4.16.0.tar.gz -o /tmp/gap.tar.gz \
    && echo "$GAP_TAR_SHA  /tmp/gap.tar.gz" | sha256sum -c - \
    && tar -xzf /tmp/gap.tar.gz -C /opt \
    && cd /opt/gap-4.16.0 && ./configure && make -j2 \
    && curl -LfsS https://raw.githubusercontent.com/gap-system/gap/b12f8342d641075d58fcbe62cc00dd433d7b8e18/lib/csetgrp.gi -o /tmp/csetgrp.gi \
    && echo "$GAP_FIX_SHA  /tmp/csetgrp.gi" | sha256sum -c - \
    && cp lib/csetgrp.gi lib/csetgrp.gi.v4.16.0 && mv /tmp/csetgrp.gi lib/csetgrp.gi \
    && curl -LfsS https://www.math.rwth-aachen.de/~Thomas.Breuer/ctbllib/ctbllib-1.3.11.tar.gz -o /tmp/ctbllib.tar.gz \
    && echo "$CTBLLIB_SHA  /tmp/ctbllib.tar.gz" | sha256sum -c - \
    && curl -LfsS https://www.math.rwth-aachen.de/~Thomas.Breuer/atlasrep/atlasrep-2.1.11.tar.gz -o /tmp/atlasrep.tar.gz \
    && echo "$ATLASREP_SHA  /tmp/atlasrep.tar.gz" | sha256sum -c - \
    && rm -rf pkg/ctbllib pkg/ctbllib-* pkg/atlasrep pkg/atlasrep-* \
    && tar -xzf /tmp/ctbllib.tar.gz -C pkg \
    && tar -xzf /tmp/atlasrep.tar.gz -C pkg \
    && rm /tmp/gap.tar.gz /tmp/ctbllib.tar.gz /tmp/atlasrep.tar.gz
RUN opam init --bare --disable-sandboxing -y \
    && opam switch create rocq "ocaml-base-compiler.${OCAML_VERSION}" --jobs=2 -y \
    && opam repository add --switch=rocq rocq-released https://rocq-prover.org/opam/released \
    && opam install --switch=rocq --jobs=2 -y \
         "rocq-core.${ROCQ_VERSION}" "rocq-mathcomp-solvable.${MATHCOMP_VERSION}"
RUN printf '%s\n' '#!/bin/sh' 'exec rocq compile "$@"' > /usr/local/bin/coqc \
    && chmod 0755 /usr/local/bin/coqc \
    && coqc --print-version | grep -E '^9[.]2([[:space:]]|$)' \
    && test -f "$(coqc -where)/user-contrib/mathcomp/solvable/maximal.v"
RUN arch=$(dpkg --print-architecture) \
    && case "$arch" in \
         amd64) elan_arch=x86_64; elan_sha="$ELAN_AMD64_SHA" ;; \
         arm64) elan_arch=aarch64; elan_sha="$ELAN_ARM64_SHA" ;; \
         *) echo "unsupported architecture: $arch" >&2; exit 1 ;; \
       esac \
    && curl -LfsS "https://github.com/leanprover/elan/releases/download/v${ELAN_VERSION}/elan-${elan_arch}-unknown-linux-gnu.tar.gz" -o /tmp/elan.tar.gz \
    && echo "$elan_sha  /tmp/elan.tar.gz" | sha256sum -c - \
    && tar -xzf /tmp/elan.tar.gz -C /tmp \
    && /tmp/elan-init -y --default-toolchain leanprover/lean4:v4.32.2 \
    && rm /tmp/elan.tar.gz /tmp/elan-init
WORKDIR /work/supporting-materials
# The build itself is the check. Do not retain roughly 19 GB of disposable
# mathlib build/cache products in the distributable runtime image. Copy the
# formal inputs first so prose or certificate-only changes do not invalidate
# this expensive kernel-check layer.
COPY supporting-materials/formal /work/supporting-materials/formal
COPY supporting-materials/formal-rocq /work/supporting-materials/formal-rocq
RUN cd formal \
    && lake exe cache get \
    && python3 check_formal.py \
    && rm -rf .lake /root/.cache
COPY supporting-materials /work/supporting-materials
COPY .gitignore .dockerignore /work/
CMD ["sh", "verify-full.sh"]
