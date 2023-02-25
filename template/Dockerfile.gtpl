FROM alpine

WORKDIR /app

COPY {{.Package}} .

CMD ["./{{.Package}}"]