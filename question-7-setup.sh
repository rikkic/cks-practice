#!/usr/bin/env bash
set -euo pipefail

# Setup for Question 7: create a small app source tree.

app_dir=/home/ubuntu/q7/app
answers_dir=/home/ubuntu/answers
mkdir -p "$app_dir" "$answers_dir"

cat > "$app_dir/go.mod" <<'MOD'
module example.com/hardened-web

go 1.21
MOD

cat > "$app_dir/main.go" <<'GO'
package main

import (
  "fmt"
  "log"
  "net/http"
)

func main() {
  http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
    fmt.Fprintln(w, "ok")
  })
  log.Fatal(http.ListenAndServe(":8080", nil))
}
GO

cat > "$app_dir/Dockerfile" <<'DOCKER'
# Initial (non-hardened) Dockerfile for candidates to improve.
FROM golang:1.21
WORKDIR /src
COPY . .
RUN go build -o /app/main ./main.go
EXPOSE 8080
CMD ["/app/main"]
DOCKER
