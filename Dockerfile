# ---------- Stage 1: Build ----------
FROM golang:1.22.5 AS builder

WORKDIR /app

# Copy only go.mod first for dependency caching
COPY go.mod ./
RUN go mod download

# Copy the rest of the source code
COPY . .

# Build static binary to avoid GLIBC issues
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o main .

# ---------- Stage 2: Run ----------
FROM gcr.io/distroless/static-debian11

WORKDIR /app

COPY --from=builder /app/main .
COPY --from=builder /app/static ./static

EXPOSE 8080

CMD ["./main"]
