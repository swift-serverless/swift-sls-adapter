SWIFT_BIN_PATH = $(shell swift build --show-bin-path)
TEST_PACKAGE= $(SWIFT_BIN_PATH)/SwiftSlsAdapterTestsPackageTests.xctest
BUILD_TEMP = .build/temp

coverage:
	llvm-cov export $(TEST_PACKAGE) \
		--instr-profile=$(SWIFT_BIN_PATH)/codecov/default.profdata \
		--format=lcov > $(GITHUB_WORKSPACE)/lcov.info