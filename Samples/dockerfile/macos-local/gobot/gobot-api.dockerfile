# builder image
FROM golang:1.19-alpine3.17 as builder
RUN mkdir /build
WORKDIR /build
RUN apk add build-base git && rm -rf gobot-git-next && git -c http.sslVerify=false clone https://gitlab.cee.redhat.com/tme/gobot-api-next.git
COPY gobot-api-next .
RUN go build -a -o gobot-api-next .

# generate clean, final image for end users
FROM alpine:3.14
COPY --from=builder /build/gobot-api-next .

# executable
ENTRYPOINT [ "./gobot-api-next --dev-mode" ]