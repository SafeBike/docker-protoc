# docker-protoc

Based on https://github.com/haunt98/docker-protoc

Run `protoc` with `docker`.

## What's included:

- [protobuf](https://github.com/protocolbuffers/protobuf)
- [protoc-gen-go](https://pkg.go.dev/google.golang.org/protobuf/cmd/protoc-gen-go)
- [protoc-gen-go-grpc](https://pkg.go.dev/google.golang.org/grpc/cmd/protoc-gen-go-grpc)
- [grpc-gateway](https://github.com/grpc-ecosystem/grpc-gateway)
- [buf](https://github.com/bufbuild/buf)

## Supported language

- Go

## Install

```sh
make build IMAGE=image TAG=tag
```

## Example

Run `make example` to generate gRPC code of `hello/hello.proto` with `protoc`.

This will regenerate the `hello/hello.pb.go` and `hello/hello_grpc.pb.go` files, which contain:
- Code for populating, serializing, and retrieving HelloRequest and HelloReply message types.
- Generated client and server code.


## Usage

`/home/docker/app` is mount point in docker container, because user is `docker` not `root`.

`/home/docker/.local/include`, `/home/docker/.local/include/third_party/googleapis` is where to store imported proto files.

Need to replace `/path/to/output`, `/path/to/proto` with your path.

Need to replace `image`, `tag` with your docker image, tag.

### Lint

With `buf`:

Should include [buf.yaml](buf.yaml) file.

```sh
docker run --rm --volume $(pwd):/home/docker/app --workdir /home/docker/app image:tag \
    protoc \
        -I /home/docker/.local/include \
        -I /home/docker/.local/include/third_party/googleapis \
        -I . \
        --buf-check-lint_out . \
        /path/to/proto
```

### Build

```sh
docker run --rm --volume $(pwd):/home/docker/app --workdir /home/docker/app image:tag \
    protoc \
        -I /home/docker/.local/include \
        -I /home/docker/.local/include/third_party/googleapis \
        -I . \
        --go_out /path/to/output \
        --go-grpc_out /path/to/output \
        /path/to/proto
```

With `grpc-gateway`:

```sh
docker run --rm --volume $(pwd):/home/docker/app --workdir /home/docker/app image:tag \
    protoc \
        -I /home/docker/.local/include \
        -I /home/docker/.local/include/third_party/googleapis \
        -I . \
        --go_out /path/to/output \
        --go-grpc_out /path/to/output \
        --grpc-gateway_out /path/to/output \
        --grpc-gateway_opt logtostderr=true \
        --swagger_out /path/to/output \
        --swagger_out logtostderr=true \
        /path/to/proto
```

### Format

Should include [.clang-format](.clang-format) file.

```sh
docker run --rm --volume $(pwd):/home/docker/app --workdir /home/docker/app image:tag \
    clang-format -i \
        /path/to/proto
```