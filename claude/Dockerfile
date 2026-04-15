FROM debian:trixie-slim

RUN set -eux; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		ca-certificates \
		curl \
		jq \
		wget \
	; \
	rm -rf /var/lib/apt/lists/*

ENV DISABLE_AUTOUPDATER 1

# https://claude.ai/install.sh
# https://storage.googleapis.com/claude-code-dist-86c565f3-f756-42ad-8dfa-d59b1c096819/claude-code-releases/latest
# https://storage.googleapis.com/claude-code-dist-86c565f3-f756-42ad-8dfa-d59b1c096819/claude-code-releases/2.1.109/manifest.json
#     "linux-x64": {
#      "binary": "claude",
#      "checksum": "d40d4c9eff224be6ba3586fd1b05acc3c8b3266998d67488a259ddcb82a6be5f",
#      "size": 233785984
#    },
ENV CLAUDE_VERSION 2.1.109
ENV CLAUDE_SHA256 d40d4c9eff224be6ba3586fd1b05acc3c8b3266998d67488a259ddcb82a6be5f
ENV CLAUDE_SIZE 233785984

RUN set -eux; \
	wget -O '/usr/local/bin/claude' "https://storage.googleapis.com/claude-code-dist-86c565f3-f756-42ad-8dfa-d59b1c096819/claude-code-releases/$CLAUDE_VERSION/linux-x64/claude" --progress=dot:giga; \
	echo "$CLAUDE_SHA256 */usr/local/bin/claude" | sha256sum --strict --check -; \
	chmod +x '/usr/local/bin/claude'; \
# smoke test
	setpriv --clear-groups --no-new-privs --reuid 1024 --regid=1024 claude --version

ENV GOTOOLCHAIN local
ENV PATH /usr/local/go/bin:$PATH
COPY --from=golang /usr/local/go /usr/local/go
RUN go version

RUN install --directory --mode=1777 /run/containerd /var/lib/containerd

COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["claude"]
