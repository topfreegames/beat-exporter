FROM golang:1.13.15-alpine3.12 as build
WORKDIR /usr/local/app
COPY . .
RUN go mod download 
RUN go build


FROM quay.io/prometheus/busybox:latest
LABEL MAINTAINER="Juan Ignacio Borda <juan.borda@tfgco.com>"

COPY --from=build /usr/local/app/beat-exporter /bin/beat-exporter

EXPOSE      9479
ENTRYPOINT  [ "/bin/beat-exporter" ]