# Dockerfile for building from source
# Use this for: docker build -t emojify-go .

# Build stage
FROM golang:1.25.0-alpine AS builder

# Install build dependencies
RUN apk add --no-cache git ca-certificates tzdata

# Set working directory
WORKDIR /app

# Copy go mod files first for better caching
COPY go.mod go.sum ./

# Download dependencies
RUN go mod download

# Copy source code
COPY . .

# Build the binary
RUN CGO_ENABLED=0 GOOS=linux go build \
    -ldflags="-s -w" \
    -o emojify \
    ./cmd/emojify

# Final minimal image
FROM scratch

# Copy certificates and timezone data from builder
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /usr/share/zoneinfo /usr/share/zoneinfo

# Copy the binary from builder
COPY --from=builder /app/emojify /emojify

# Set the binary as entrypoint
ENTRYPOINT ["/emojify"]
