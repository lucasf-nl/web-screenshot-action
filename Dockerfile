# FROM rust:1.83-alpine3.21 as build

# project requires edition 2024 which is not available
# in the official rust docker containers at the moment
# use nightly on alpine instead:
FROM alpine:3.21 as build
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --default-toolchain none -y
RUN rustup toolchain install nightly --allow-downgrade --profile minimal --component clippy

WORKDIR /web-screenshot-action

COPY ./Cargo.lock ./Cargo.lock
COPY ./Cargo.toml ./Cargo.toml
COPY ./src ./src

ENV RUSTFLAGS="-C target-feature=+crt-static -C link-self-contained=yes"
RUN cargo build --release --target x86_64-unknown-linux-musl --features static

FROM scratch

WORKDIR /
COPY --from=build /web-screenshot-action/target/release/web-screenshot-action /web-screenshot-action

ENTRYPOINT ["/web-screenshot-action"]