FROM golang:1.24-alpine AS builder

WORKDIR /app

COPY go.mod main.go ./

RUN go mod download && \
    CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o /app/app /app/main.go

FROM scratch

COPY --from=builder /app/app /app

EXPOSE 8080

ARG ENVIRONMENT="local"
ARG SECRET="local-secret"
ARG PORT="8080"

ENV ENVIRONMENT=${ENVIRONMENT} \
    SECRET=${SECRET} \
    PORT=${PORT}

CMD ["/app"]
