FROM debian:trixie-slim AS base

RUN set -eux; \
	apt-get install -y --update --no-install-recommends \
		ca-certificates \
		curl \
		git \
		wget \
	; \
	apt-get dist-clean

FROM base AS fetch

# https://github.com/ggml-org/llama.cpp/releases
ENV LLAMA_VERSION b9542

RUN set -eux; \
	wget -O llama.tar.gz "https://github.com/ggml-org/llama.cpp/archive/${LLAMA_VERSION}.tar.gz"; \
	mkdir /llama; \
	tar --extract --verbose --file llama.tar.gz --directory /llama --strip-components 1; \
	rm llama.tar.gz

FROM base AS build

RUN set -eux; \
	apt-get install -y --update --no-install-recommends \
		cmake \
		g++ \
		gcc \
		glslang-tools \
		glslc \
		libssl-dev \
		libvulkan-dev \
		make \
		spirv-headers \
	; \
	apt-get dist-clean

# https://github.com/ggml-org/llama.cpp/blob/master/docs/build.md
RUN --mount=type=bind,from=fetch,src=/llama,dst=/llama,ro \
	set -eux; \
	cd /llama; \
	cmake -B /build \
		-DBUILD_SHARED_LIBS=OFF \
		-DCMAKE_BUILD_TYPE='Release' \
# TODO -v4 would be better for my Peladn HO5
		-DCMAKE_CXX_FLAGS='-march=x86-64-v3' \
		-DCMAKE_C_FLAGS='-march=x86-64-v3' \
		-DCMAKE_INSTALL_PREFIX='/install' \
		-DGGML_NATIVE=OFF \
		-DGGML_VULKAN=ON \
		-DLLAMA_BUILD_EXAMPLES=OFF \
		-DLLAMA_BUILD_TESTS=OFF \
		-DLLAMA_TESTS_INSTALL=OFF \
		-DLLAMA_TOOLS_INSTALL=ON \
	; \
	nproc="$(nproc)"; \
	cmake --build /build -j "$nproc"; \
	cmake --build /build --target install

RUN set -eux; \
	ldd /install/bin/llama \
		| awk '/=>/ { so = $(NF-1); if (index(so, "/usr/local/") == 1) { next }; gsub("^/(usr/)?", "", so); printf "*%s\n", so }' \
		| sort -u \
		| xargs -r dpkg-query --search \
		| cut -d: -f1 \
		| sort -u \
		| tee /apt-deps.txt \
	; \
	echo 'mesa-vulkan-drivers' >> /apt-deps.txt

FROM base

RUN --mount=type=bind,from=build,src=/apt-deps.txt,dst=/apt-deps.txt,ro \
	set -eux; \
	xargs -rt apt-get install -y --update --no-install-recommends < /apt-deps.txt; \
	apt-get dist-clean

COPY --from=build /install/bin/llama /usr/local/bin/
RUN llama version
