FROM nixos/nix:latest AS builder

COPY . /tmp/build
WORKDIR /tmp/build

# build our Nix environment
RUN nix-shell ./nix/build-shell.nix --run "make build"

# copy the Nix store closure into a directory. The Nix store closure is the
# entire set of Nix store values that we need for our build.
RUN mkdir /tmp/nix-store-closure
RUN cp -R $(nix-store -qR result/) /tmp/nix-store-closure

# Final image is based on scratch. We copy a bunch of Nix dependencies
# but they're fully self-contained so we don't need Nix anymore.
FROM scratch

WORKDIR /app

# Copy /nix/store
COPY --from=builder /tmp/nix-store-closure /nix/store
COPY --from=builder /tmp/build/result /app
CMD ["/app/bin/otmui"]