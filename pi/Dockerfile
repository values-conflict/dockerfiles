FROM node:26-trixie-slim

RUN set -eux; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		bzip2 \
		ca-certificates \
		curl \
		file \
		git \
		jq \
		wget \
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

# a Tianon-specific need - running containerd unprivileged inside opencode containers
RUN install --directory --mode=1777 /run/containerd /var/lib/containerd
# (we don't embed the necessary config for this to actually work here because it has to embed specific explicit uid/gid 😔)

# shut *up* about updates, npm
RUN npm config set update-notifier false

# TODO if pi doesn't find fd and rg at startup, it'll download them, so we should pre-download them

# https://github.com/earendil-works/pi/releases
# https://www.npmjs.com/package/@earendil-works/pi-coding-agent?activeTab=versions
ENV PI_VERSION 0.81.1
# TODO swap to downloading/installing the Bun standalone version?

RUN set -eux; \
	npm install -g --ignore-scripts "@earendil-works/pi-coding-agent@$PI_VERSION"; \
	npm cache clean --force; \
	pi --version

COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["pi"]
