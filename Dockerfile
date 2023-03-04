FROM golang:1.13.15-alpine3.12 as build
WORKDIR /usr/local/app
COPY . .
RUN apk add git
RUN go mod download 
RUN GITVERSION=$(git describe --tags --always)
RUN GITBRANCH=$(git branch | grep \* | cut -d ' ' -f2)
RUN GITREVISION=$(git log -1 --oneline | cut -d ' ' -f1)
RUN TIME=$(date +%FT%T%z)
RUN LDFLAGS="-s -X github.com/prometheus/common/version.Version=${GITVERSION} \
-X github.com/prometheus/common/version.Revision=${GITREVISION} \
-X github.com/prometheus/common/version.Branch=master \
-X github.com/prometheus/common/version.BuildUser=${GITHUB_ACTOR} \
-X github.com/prometheus/common/version.BuildDate=${TIME}"
RUN GO111MODULE=on CGO_ENABLED=0  go build -ldflags "${LDFLAGS}" -tags 'netgo static_build' -a 

FROM quay.io/prometheus/busybox:latest
LABEL MAINTAINER="Juan Ignacio Borda <juan.borda@tfgco.com>"

COPY --from=build /usr/local/app/beat-exporter /bin/beat-exporter

EXPOSE      9479
ENTRYPOINT  [ "/bin/beat-exporter" ]