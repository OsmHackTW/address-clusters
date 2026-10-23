# Build SDF glyphs for Traditional Chinese labels,
# the fonts bundled with Tileserver GL have no CJK glyphs.
FROM rust:1.99-slim-trixie AS glyphs
RUN apt-get update && \
    apt-get install -y pkg-config libfreetype-dev && \
    rm -rf /var/lib/apt/lists
RUN cargo install build_pbf_glyphs@1.5.1 --locked
ADD --checksum=sha256:dce08bd4fd91aa8aa76ed8fea4b694c2dfb8550f67871e326843212ddbeb88b4 \
    https://github.com/notofonts/noto-cjk/raw/Sans2.004/Sans/OTF/TraditionalChinese/NotoSansCJKtc-Regular.otf /src/
RUN build_pbf_glyphs /src /fonts

FROM maptiler/tileserver-gl:v5.6.0
COPY --from=glyphs /fonts /tileserver/fonts
COPY config.json /tileserver/
COPY styles /tileserver/styles
CMD ["--config", "/tileserver/config.json"]
