# https://github.com/protocolbuffers/protobuf/releases
PROTOC_VERSION = 3.13.0

# https://github.com/bufbuild/buf/releases
BUF_VERISON = 0.27.1

# https://golang.org/doc/devel/release.html
GO_VERSION = 1.15.2

# https://github.com/protocolbuffers/protobuf-go/releases
PROTOC_GEN_GO_VERSION = v1.25.0

# https://github.com/grpc/grpc-go/releases
PROTOC_GEN_GO_GRPC_VERSION = v1.0.0

# https://github.com/grpc-ecosystem/grpc-gateway/releases
GATEWAY_VERSION = v1.15.2

IMAGE = safebike/protoc
TAG = latest

.PHONY: all
all: build example ## Build and run the example

.PHONY: help
help: ## Show help
	@egrep '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

.PHONY: test
test: ## Check the environment variables
	@test $(PROTOC_VERSION)
	@test $(BUF_VERISON)
	@test $(GO_VERSION)
	@test $(PROTOC_GEN_GO_VERSION)
	@test $(PROTOC_GEN_GO_GRPC_VERSION)
	@test $(GATEWAY_VERSION)
	@test $(IMAGE)
	@test $(TAG)

.PHONY: build
build: test ## Build Docker image
	docker build \
	--tag $(IMAGE):$(TAG) \
	--build-arg PROTOC_VERSION=$(PROTOC_VERSION) \
	--build-arg BUF_VERISON=$(BUF_VERISON) \
	--build-arg GO_VERSION=$(GO_VERSION) \
	--build-arg PROTOC_GEN_GO_VERSION=$(PROTOC_GEN_GO_VERSION) \
	--build-arg PROTOC_GEN_GO_GRPC_VERSION=$(PROTOC_GEN_GO_GRPC_VERSION) \
	--build-arg GATEWAY_VERSION=$(GATEWAY_VERSION) \
	.

.PHONY: example
example: test ## Build hello/hello.proto with protoc
	docker run --rm --volume pwd:/home/docker/app --workdir /home/docker/app $(IMAGE):$(TAG) \
    	protoc \
    		-I /home/docker/.local/include \
    		-I /home/docker/.local/include/third_party/googleapis \
    		-I hello \
    		--go_out=hello \
    		--go-grpc_out=hello \
    		hello/hello.proto

.PHONY: push
push: build ## Push image to `https://hub.docker.com`
	docker push $(IMAGE):$(TAG)