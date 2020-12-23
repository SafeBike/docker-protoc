FROM alpine:latest AS base

RUN apk update && apk upgrade
RUN apk --no-cache add ca-certificates wget && \
    wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub && \
    wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.28-r0/glibc-2.28-r0.apk && \
    apk add glibc-2.28-r0.apk

RUN addgroup -S appgroup && adduser -S docker -G appgroup
USER docker

ENV HOME /home/docker
WORKDIR ${HOME}

ENV LOCAL ${HOME}/.local
RUN mkdir -p ${LOCAL}/bin
RUN mkdir -p ${LOCAL}/include
RUN mkdir -p ${LOCAL}/protoc
ENV PATH $PATH:${LOCAL}/bin

ARG PROTOC_VERSION
RUN wget https://github.com/protocolbuffers/protobuf/releases/download/v${PROTOC_VERSION}/protoc-${PROTOC_VERSION}-linux-x86_64.zip \
    && unzip protoc-${PROTOC_VERSION}-linux-x86_64.zip -d ${LOCAL}/protoc \
    && rm protoc-${PROTOC_VERSION}-linux-x86_64.zip
ENV PATH $PATH:${LOCAL}/protoc/bin

ARG BUF_VERISON
RUN wget https://github.com/bufbuild/buf/releases/download/v${BUF_VERISON}/buf-Linux-x86_64 \
    && chmod +x buf-Linux-x86_64 \
    && mv buf-Linux-x86_64 ${LOCAL}/bin/buf
RUN wget https://github.com/bufbuild/buf/releases/download/v${BUF_VERISON}/protoc-gen-buf-check-lint-Linux-x86_64 \
    && chmod +x protoc-gen-buf-check-lint-Linux-x86_64 \
    && mv protoc-gen-buf-check-lint-Linux-x86_64 ${LOCAL}/bin/protoc-gen-buf-check-lint

ARG GO_VERSION
RUN wget https://golang.org/dl/go${GO_VERSION}.linux-amd64.tar.gz \
    && tar -C ${LOCAL} -xzf go${GO_VERSION}.linux-amd64.tar.gz \
    && rm go${GO_VERSION}.linux-amd64.tar.gz
ENV GOPATH ${HOME}/go
ENV PATH $PATH:${LOCAL}/go/bin:$GOPATH/bin

ARG PROTOC_GEN_GO_VERSION
RUN GO111MODULE=on go get google.golang.org/protobuf/cmd/protoc-gen-go@${PROTOC_GEN_GO_VERSION}

ARG PROTOC_GEN_GO_GRPC_VERSION
RUN GO111MODULE=on go get google.golang.org/grpc/cmd/protoc-gen-go-grpc@${PROTOC_GEN_GO_GRPC_VERSION}

ARG GATEWAY_VERSION
RUN GO111MODULE=on go get github.com/grpc-ecosystem/grpc-gateway/protoc-gen-grpc-gateway@${GATEWAY_VERSION}
RUN GO111MODULE=on go get github.com/grpc-ecosystem/grpc-gateway/protoc-gen-swagger@${GATEWAY_VERSION}

RUN cp -r $GOPATH/pkg/mod/github.com/grpc-ecosystem/grpc-gateway\@${GATEWAY_VERSION}/protoc-gen-grpc-gateway ${LOCAL}/include/
RUN cp -r $GOPATH/pkg/mod/github.com/grpc-ecosystem/grpc-gateway\@${GATEWAY_VERSION}/protoc-gen-swagger ${LOCAL}/include/
RUN cp -r $GOPATH/pkg/mod/github.com/grpc-ecosystem/grpc-gateway\@${GATEWAY_VERSION}/third_party ${LOCAL}/include/