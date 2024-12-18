#FROM rust:1.83-alpine3.21 as build
#FROM ekidd/rust-musl-builder as build
FROM rust:1.83 as build

WORKDIR /web-screenshot-action

COPY ./Cargo.lock ./Cargo.lock
COPY ./Cargo.toml ./Cargo.toml
COPY ./src ./src

ENV RUSTFLAGS="-C target-feature=+crt-static -C link-self-contained=yes"
RUN rustup target add x86_64-unknown-linux-musl # needed to have a somewhat recent version of tooling on rust-musl-builder
RUN cargo build --release --target x86_64-unknown-linux-musl --features static

FROM alpine:3.21

# Install Chromium
RUN apk upgrade --no-cache --available \
    && apk add --no-cache \
        chromium-swiftshader \
        ttf-freefont \
        font-noto-emoji

ENV CHROME_BIN=/usr/bin/chromium-browser
ENV CHROME_PATH=/user/lib/chromium

WORKDIR /
COPY --from=build /web-screenshot-action/target/x86_64-unknown-linux-musl/release/web-screenshot-action /web-screenshot-action

RUN mkdir -p /home/wsa \
    && adduser -D wsa \
    && chown -R wsa:wsa /home/wsa
USER wsa
WORKDIR /home/wsa

ENTRYPOINT ["/web-screenshot-action"]