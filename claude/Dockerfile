FROM node

RUN set -eux; \
	apt-get update; \
	apt-get install -y jq; \
	rm -rf /var/lib/apt/lists/*

ENV DISABLE_AUTOUPDATER 1

# https://www.npmjs.com/package/@anthropic-ai/claude-code
ENV CLAUDE_VERSION 2.1.101
RUN npm install -g "@anthropic-ai/claude-code@$CLAUDE_VERSION"
RUN claude --version

ENV GOTOOLCHAIN local
ENV PATH /usr/local/go/bin:$PATH
COPY --from=golang /usr/local/go /usr/local/go
RUN go version

RUN install --directory --mode=1777 /run/containerd /var/lib/containerd

CMD ["claude"]
