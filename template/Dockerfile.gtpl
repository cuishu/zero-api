FROM alpine

ENV GIN_MODE release

WORKDIR /app

COPY {{.Package.ShortName}} .

CMD ["./{{.Package.ShortName}}"]