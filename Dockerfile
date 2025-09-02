# Step 1: Build stage
FROM golang:1.24 AS builder

# Set working directory
WORKDIR /app

# Copy go.mod and go.sum first for caching (if using modules)
COPY go.mod ./
RUN go mod download

# Copy the Go source code and index.html
COPY main.go .
COPY index.html .

# Set environment variables for Alpine compatibility
ENV CGO_ENABLED=0
ENV GOOS=linux
ENV GOARCH=amd64

# Build the Go binary statically linked for Alpine
RUN go build -o main .

# Step 2: Create a smaller image using Alpine
FROM alpine:latest

WORKDIR /app

# Copy the statically linked binary and index.html
COPY --from=builder /app/main .
COPY --from=builder /app/index.html .

# Expose port 8980
EXPOSE 8980

# Command to run the Go binary
CMD ["./main"]
