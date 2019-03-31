#================================
# Stage 1: Build borges
#================================
FROM golang:1.12-alpine as builder
MAINTAINER dpordomingo

ENV REPO=${GOPATH}/src/github.com/src-d/borges

# RUN apk add --update --no-cache libxml2-dev git make bash gcc g++ curl oniguruma-dev oniguruma
RUN apk add --update --no-cache make bash git curl

COPY . ${REPO}
WORKDIR ${REPO}

RUN make build

#=================================
# Stage 2: Start borges
#=================================
FROM alpine:3.8
MAINTAINER source{d}

ENV REPO=/go/src/github.com/src-d/borges

ENV BORGES_DATABASE=postgres://testing:testing@postgres/testing?application_name=borges&sslmode=disable&connect_timeout=30
ENV BORGES_BROKER=amqp://guest:guest@rabbitmq:5672/
ENV BORGES_ROOT_REPOSITORIES_DIR=/var/root-repositories

RUN mkdir -p /var/root-repositories

RUN apk add --no-cache ca-certificates dumb-init=1.2.1-r0 git

COPY --from=builder ${REPO}/build/borges_linux_amd64/borges /bin/

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["borges"]
