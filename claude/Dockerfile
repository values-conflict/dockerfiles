#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

# a separate "base" stage so we can update Debian easily across all our stages in one place
FROM debian:trixie-slim AS base

# common deps we need regardless
RUN set -eux; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		ca-certificates \
		wget \
	; \
	if grep -q bookworm /etc/os-release; then \
		rm -rf /var/lib/apt/lists/*; \
	else \
		apt-get dist-clean; \
	fi

# download claude in a separate stage so we get slightly better cache as we add more packages to the final image
FROM base AS claude

# https://claude.ai/install.sh
# https://storage.googleapis.com/claude-code-dist-86c565f3-f756-42ad-8dfa-d59b1c096819/claude-code-releases/latest
# https://storage.googleapis.com/claude-code-dist-86c565f3-f756-42ad-8dfa-d59b1c096819/claude-code-releases/2.1.217/manifest.json
ENV CLAUDE_VERSION 2.1.217
ENV CLAUDE_SHA256 2630fc5dc6db61bc03f86b95daf47766e5ed5b61873f7bb7cfea764c5ac5a9ba
ENV CLAUDE_SIZE 268573680

RUN set -eux; \
	wget -O /claude "https://storage.googleapis.com/claude-code-dist-86c565f3-f756-42ad-8dfa-d59b1c096819/claude-code-releases/$CLAUDE_VERSION/linux-x64/claude" --progress=dot:giga; \
	size="$(stat --format '%s' /claude)"; \
	[ "$size" = "$CLAUDE_SIZE" ]; \
	echo "$CLAUDE_SHA256 */claude" | sha256sum --strict --check -; \
	chmod +x /claude

FROM base

RUN set -eux; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		bzip2 \
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
		pkg-config \
		\
		libseccomp-dev \
	; \
	if grep -q bookworm /etc/os-release; then \
		rm -rf /var/lib/apt/lists/*; \
	else \
		apt-get dist-clean; \
	fi

ENV GOTOOLCHAIN local
ENV PATH /usr/local/go/bin:$PATH
COPY --from=golang /usr/local/go /usr/local/go
RUN go version

# a Tianon-specific need - running containerd unprivileged inside Claude containers
RUN install --directory --mode=1777 /run/containerd /var/lib/containerd
# (we don't embed the necessary config for this to actually work here because it has to embed specific explicit uid/gid 😔)

# disable the auto-updater
# https://www.schemastore.org/claude-code-settings.json#:~:text=DISABLE_AUTOUPDATER
ENV DISABLE_AUTOUPDATER 1
# disable the installation checker (which will complain about our system-installed claude 🙃)
ENV DISABLE_INSTALLATION_CHECKS 1
# https://github.com/anthropics/claude-code/issues/17289#issuecomment-3906140556

COPY --from=claude /claude /usr/local/bin/
# smoke test
RUN setpriv --clear-groups --no-new-privs --reuid 1024 --regid=1024 claude --version

COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["claude"]
