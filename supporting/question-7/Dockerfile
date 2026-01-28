# Initial (non-hardened) Dockerfile for candidates to improve.
FROM golang:1.21
WORKDIR /src
COPY . .
RUN go build -o /app/main ./main.go
EXPOSE 8080
CMD ["/app/main"]
