#FROM rust:1.83-alpine3.21 as build
FROM ekidd/rust-musl-builder as build

WORKDIR /web-screenshot-action

COPY ./Cargo.lock ./Cargo.lock
COPY ./Cargo.toml ./Cargo.toml
COPY ./src ./src

ENV RUSTFLAGS="-C target-feature=+crt-static -C link-self-contained=yes"
RUN rustup update # needed to have a somewhat recent version of tooling on rust-musl-builder
RUN cargo build --release --target x86_64-unknown-linux-musl --features static

FROM scratch

WORKDIR /
COPY --from=build /web-screenshot-action/target/x86_64-unknown-linux-musl/release/web-screenshot-action /web-screenshot-action

ENTRYPOINT ["/web-screenshot-action"]