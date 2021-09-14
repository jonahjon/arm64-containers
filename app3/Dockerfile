FROM golang:1.17 AS builder

ENV GO111MODULE=off \
    CGO_ENABLED=0 \
    GOOS=linux

# Add your app and do what you need to for dependencies
WORKDIR /build
COPY ./app.go .
RUN go build -o webserver ./app.go

# Final stage
FROM alpine
EXPOSE 8080
WORKDIR /app
COPY --from=builder /build/webserver /app/webserver
ENTRYPOINT ["/app/webserver"]