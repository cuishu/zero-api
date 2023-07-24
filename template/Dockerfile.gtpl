FROM alpine

WORKDIR /app

COPY {{.Package.ShortName}} .

CMD ["./{{.Package.ShortName}}"]