# STAGE 1: base
# This stage prepares the minimal dependencies for our final image.
FROM --platform=$BUILDPLATFORM alpine:latest AS base
RUN apk --no-cache add ca-certificates tzdata

# STAGE 2: builder
# This stage builds the Go binary.
FROM --platform=$BUILDPLATFORM golang:1.25.0-alpine AS builder

# Set the working directory inside the container.
WORKDIR /src

# Copy the Go module files and download dependencies.
COPY go.mod go.sum ./
RUN go mod download

# Copy the rest of your source code.
COPY . .

# Build the Go binary.
# TARGETOS and TARGETARCH are provided by Docker buildx and are crucial for cross-compilation.
ARG TARGETOS TARGETARCH
RUN CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build \
    -ldflags="-s -w" \
    -o /build/emojify \
    ./cmd/emojify

# STAGE 3: Final Image
# This stage creates the final, minimal production image.
FROM scratch

# Copy the certificates and timezone data from our 'base' stage.
COPY --from=base /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=base /usr/share/zoneinfo /usr/share/zoneinfo

# Copy the compiled binary from the 'builder' stage.
COPY --from=builder /build/emojify /emojify

# Set the binary as the entrypoint for the container.
ENTRYPOINT ["/emojify"]
