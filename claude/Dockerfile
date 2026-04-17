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

# download claude in a separate stage so we get slightly better cache as we add more packages to the final image
FROM base AS claude

# https://claude.ai/install.sh
# https://storage.googleapis.com/claude-code-dist-86c565f3-f756-42ad-8dfa-d59b1c096819/claude-code-releases/latest
# https://storage.googleapis.com/claude-code-dist-86c565f3-f756-42ad-8dfa-d59b1c096819/claude-code-releases/2.1.113/manifest.json
#   "platforms": {
#     ...
#     "linux-x64": {
#      "binary": "claude",
#      "checksum": "a81f7726b3b6b910e50c08a09f0090cb60714695d6d01bfe8698ff16cda9b87d",
#      "size": 236411520
#     },
#     ...
ENV CLAUDE_VERSION 2.1.113
ENV CLAUDE_SHA256 a81f7726b3b6b910e50c08a09f0090cb60714695d6d01bfe8698ff16cda9b87d
ENV CLAUDE_SIZE 236411520

RUN set -eux; \
	wget -O /claude "https://storage.googleapis.com/claude-code-dist-86c565f3-f756-42ad-8dfa-d59b1c096819/claude-code-releases/$CLAUDE_VERSION/linux-x64/claude" --progress=dot:giga; \
	echo "$CLAUDE_SHA256 */claude" | sha256sum --strict --check -; \
	chmod +x /claude

FROM base

RUN set -eux; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		curl \
		file \
		git \
		jq \
		xxd \
	; \
	rm -rf /var/lib/apt/lists/*

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
