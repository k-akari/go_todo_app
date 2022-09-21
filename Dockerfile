# デプロイ用コンテナに含めるバイナリを作成するコンテナ
FROM golang:1.18.2-bullseye as deploy-builder

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN go build -trimpath -ldflags "-w -s" -o app

# -------

# デプロイ用のコンテナ
FROM debian:bullseye-slim as deploy
RUN apt-get update
COPY --from=deploy-builder /app/app .
CMD ["./app"]

# -------

# ローカル開発環境
FROM golang:1.18.2 as dev
WORKDIR /app
RUN curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b $(go env GOPATH)/bin v1.49.0
RUN go install github.com/cosmtrek/air@latest
CMD ["air"]
