PKG := ./...                      
BENCH_FUNC := ^BenchmarkNumMatrix_SumRegion$
OLD_REF ?= HEAD~1
NEW_REF ?= HEAD
BENCH_COUNT ?= 5

.PHONY: all build test bench clean bench-compare install-benchstat help


all: build

build:
	go build $(PKG) 

test:
	go test $(PKG)

bench:
	@echo ">>> Benchmarking '$(BENCH_FUNC)' for current version..."
	go test -bench=$(BENCH_FUNC) -benchmem -count=$(BENCH_COUNT) $(PKG)

bench-compare: install-benchstat
	@echo ">>> Compare benchmarks '$(BENCH_FUNC)' between [$(OLD_REF)] and [$(NEW_REF)]"
	@# Checking if repo is clean
	@if ! git diff --quiet HEAD; then \
		echo "Error: Git state unclean."; \
		exit 1; \
	fi
	@# Saving current state
	@{ \
		CURRENT_STATE=$$(git rev-parse --abbrev-ref HEAD); \
		if [ "$$CURRENT_STATE" = "HEAD" ]; then \
			CURRENT_STATE=$$(git rev-parse HEAD); \
		fi; \
		echo "   Current: $$CURRENT_STATE"; \
		echo "   Benchmarking OLD_REF [$(OLD_REF)]..."; \
		git checkout $(OLD_REF) --quiet; \
		go test -bench=$(BENCH_FUNC) -benchmem -count=$(BENCH_COUNT) $(PKG) > old.bench || \
			(echo "Error: Benchmarking $(OLD_REF) failed."; git checkout $$CURRENT_STATE --quiet; exit 1); \
		\
		echo "   Benchmarking NEW_REF [$(NEW_REF)]..."; \
		git checkout $(NEW_REF) --quiet; \
		go test -bench=$(BENCH_FUNC) -benchmem -count=$(BENCH_COUNT) $(PKG) > new.bench || \
			(echo "Error: Benchmarking $(NEW_REF) failed."; git checkout $$CURRENT_STATE --quiet; rm -f old.bench; exit 1); \
		\
		echo "   Reverting to [$$CURRENT_STATE]"; \
		git checkout $$CURRENT_STATE --quiet; \
		\
		echo ">>> Benchmark results:"; \
		benchstat old.bench new.bench; \
		\
		echo "   Removing benchmark files"; \
		rm -f old.bench new.bench; \
		echo "Done"; \
	}

install-benchstat:
	@if ! command -v benchstat > /dev/null; then \
		echo ">>> Missing 'benchstat'. Installing..."; \
		go install golang.org/x/perf/cmd/benchstat@latest; \
		export PATH=$$PATH:$(go env GOPATH)/bin; \
		if ! command -v benchstat > /dev/null; then \
			echo "Error: Installing 'benchstat' failed or missing in  PATH."; \
			echo "   Install manually: go install golang.org/x/perf/cmd/benchstat@latest"; \
			exit 1; \
		fi \
	else \
		echo "   'benchstat' already installed."; \
	fi

clean:
	go clean
	rm -f old.bench new.bench

help:
	@echo "Available commands:"
	@echo "  make build"
	@echo "  make test"
	@echo "  make bench          -> Runs benchmark '$(BENCH_FUNC)' for current version"
	@echo "  make bench-compare  -> Compare benchmarks '$(BENCH_FUNC)' between two versions"
	@echo "                       Default: OLD_REF=HEAD~1 NEW_REF=HEAD"
	@echo "                       Example: make bench-compare OLD_REF=v1.0 NEW_REF=v1.1"
	@echo "                       Example: make bench-compare OLD_REF=main NEW_REF=feature-branch BENCH_COUNT=10"
	@echo "  make install-benchstat -> Install 'benchstat' if missing"
	@echo "  make clean"
	@echo "  make help"

.DEFAULT_GOAL := help