BIN_DIR?=./bin
GOLANGCI_LINT_BIN?=$(BIN_DIR)/golangci-lint
GOLANGCI_LINT_VERSION=v1.40.1

all: build
.PHONY: all

build:
	hack/build-go.sh
.PHONY: build

test:
	go test ./...
.PHONY: test

clean:
	rm -rf _output/
.PHONY: clean

update-codegen-crds:
	go run ./vendor/github.com/openshift/library-go/cmd/crd-schema-gen/main.go --domain openshift.io --apis-dir vendor/github.com/openshift/api --manifests-dir install/
update-codegen: update-codegen-crds
verify-codegen-crds:
	go run ./vendor/github.com/openshift/library-go/cmd/crd-schema-gen/main.go --domain openshift.io --apis-dir vendor/github.com/openshift/api --manifests-dir install/ --verify-only
verify-codegen: verify-codegen-crds
verify: verify-codegen
.PHONY: update-codegen-crds update-codegen verify-codegen-crds verify-codegen verify


.PHONY: lint
## Checks the code with golangci-lint
lint: $(GOLANGCI_LINT_BIN)
	$(GOLANGCI_LINT_BIN) run -c .golangci.yaml --deadline=30m

$(GOLANGCI_LINT_BIN):
	curl -sfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b ${BIN_DIR} ${GOLANGCI_LINT_VERSION}
