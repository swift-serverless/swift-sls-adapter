SWIFT_DOCKER_IMAGE = swift:5.10-jammy
MOUNT_ROOT=$(shell pwd)
SWIFT_BIN_PATH = $(shell swift build --show-bin-path)
TEST_PACKAGE= $(SWIFT_BIN_PATH)/swift-sls-adapterPackageTests.xctest
BUILD_TEMP = .build/temp

docker_bash:
	docker run \
		-it \
		--rm \
		--volume "$(MOUNT_ROOT):/src" \
		--workdir "/src/" \
		$(SWIFT_DOCKER_IMAGE) \
		/bin/bash

test:
	swift test --enable-code-coverage

coverage:
	llvm-cov export $(TEST_PACKAGE) \
		--instr-profile=$(SWIFT_BIN_PATH)/codecov/default.profdata \
		--format=lcov > $(GITHUB_WORKSPACE)/lcov.info