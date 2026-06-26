# a separate "base" stage so we can update Debian easily across all our stages in one place
FROM debian:trixie-slim AS base

# common deps we need regardless
RUN set -eux; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		ca-certificates \
		wget \
	; \
	apt-get dist-clean

# download opencode in a separate stage so we get slightly better cache as we add more packages to the final image
FROM base AS opencode

# https://github.com/anomalyco/opencode/releases
# (ignore "latest.json", "latest.yml", "latest-linux.yml", etc - they're all about the .deb files which are insane)
ENV OPENCODE_VERSION 1.14.30
# opencode-linux-x64.tar.gz
ENV OPENCODE_SHA256 13b2dd32c5549f7b031e8bb67fb8d6e8d87aa9e07bd6f0017620836f1fb7cdce

RUN set -eux; \
	wget -O opencode.tgz "https://github.com/anomalyco/opencode/releases/download/v${OPENCODE_VERSION}/opencode-linux-x64.tar.gz" --progress=dot:giga; \
	echo "$OPENCODE_SHA256 *opencode.tgz" | sha256sum --strict --check -; \
	tar --extract --verbose --file opencode.tgz opencode; \
	rm opencode.tgz; \
	test -x /opencode

FROM base

RUN set -eux; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		curl \
		file \
		git \
		jq \
		xxd \
		\
# C deps
		autoconf automake libtool \
		g++ \
		gcc \
		libc6-dev \
		make \
	; \
	apt-get dist-clean

ENV GOTOOLCHAIN local
ENV PATH /usr/local/go/bin:$PATH
COPY --from=golang /usr/local/go /usr/local/go
RUN go version

# a Tianon-specific need - running containerd unprivileged inside opencode containers
RUN install --directory --mode=1777 /run/containerd /var/lib/containerd
# (we don't embed the necessary config for this to actually work here because it has to embed specific explicit uid/gid 😔)

COPY --from=opencode /opencode /usr/local/bin/
# smoke test
RUN set -eux; \
	uid='1234'; \
	gid='5678'; \
	home='/tmp/opencode-smoke-test-home'; \
	install \
		--directory \
		--owner "$uid" \
		--group "$gid" \
		"$home" \
	; \
	setpriv \
		--clear-groups \
		--no-new-privs \
		--reuid "$uid" \
		--regid "$gid" \
		env -i PATH="$PATH" HOME="$home" \
		opencode --version \
	; \
	find "$home" -ls; \
	rm -rf "$home"

COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["opencode"]
