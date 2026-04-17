CONTAINER_ENGINE = podman
CODENAME = trixie
GPG_KEY = sietch-tabr.pub.asc
REPO_URL ?= http://localhost:8080

.PHONY: help
help: # Show this help.
	@egrep -h '\s#\s' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?# "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

###############################################################################
# Develop
###############################################################################

DEV_IMG = sietch-tabr-dev:latest
.PHONY: dev-init
dev-init: dev.Containerfile # Builds dev container.
	mkdir -p ./.gnupg/
	$(CONTAINER_ENGINE) build -t $(DEV_IMG) -f dev.Containerfile .

INTERACTIVE := $(shell [ -t 0 ] && echo "-it" || echo "-i")
DEV_CONTAINER = $(CONTAINER_ENGINE) run $(INTERACTIVE) --rm \
	-v $(shell pwd):/repo:Z \
	-v $(shell pwd)/.gnupg:/root/.gnupg:Z \
	-e GPG_TTY=/dev/pts/0 \
	-e GNUPGHOME=/root/.gnupg \
	$(DEV_IMG)
.PHONY: dev
dev: dev-init # Developer Container.
	$(DEV_CONTAINER)

SERVER_CONTAINER = sietch-tabr-server
.PHONY: serve
serve: # Serve localhost apt repository.
	$(MAKE) stop-serve
	@echo "Starting local mirror at http://localhost:8080..."
	$(CONTAINER_ENGINE) run --rm -d --replace \
		--name $(SERVER_CONTAINER) \
		-p 8080:8080 \
		--userns=keep-id \
		-v $(shell pwd)/tests/nginx.conf:/etc/nginx/nginx.conf:ro \
		-v $(shell pwd)/public:/usr/share/nginx/html:Z,ro \
		docker.io/library/nginx:alpine

.PHONY: stop-serve
stop-serve: # Safely stops localhost apt repository.
	@if $(CONTAINER_ENGINE) ps | grep -q $(SERVER_CONTAINER); then $(CONTAINER_ENGINE) stop $(SERVER_CONTAINER); fi

.PHONY: clean
clean: # Removes generated public artifacts.
	rm -fr public/*
	rm -fr build/*
	rm -fr db/*

###############################################################################
# Build
###############################################################################
PACKAGES_LIST := $(shell sed 's/=.*//' ./packages/versions.ini | xargs)

.PHONY: build
build: dev-init # Builds repository.
	mkdir -p public/
	cp -r static/* public/
	sed \
		-e 's/{{ %packages% }}/$(PACKAGES_LIST)/' \
		-e "s|{{ %REPO_URL% }}|$(REPO_URL)|" \
		-e "s|{{ %GPG_KEY% }}|$(GPG_KEY)|" \
		index.html.template > public/index.html
	cp -r keys/ public/

	$(DEV_CONTAINER) reprepro createsymlinks

	./scripts/check_updates.sh
	./scripts/download_release.sh
	./scripts/build_debs.sh

	@for d in build/debs/*.deb; do \
		$(DEV_CONTAINER) reprepro includedeb $(CODENAME) $$d; \
	done

###############################################################################
# Test
###############################################################################

.PHONY: test
test: dev-init build # Runs install against http://localhost:8080
	@echo "Running ./scripts/ Test..."
	$(CONTAINER_ENGINE) run --rm \
		-v $(shell pwd)/tests/test_scripts.sh:/opt/test_scripts.sh:Z,ro \
		-v $(shell pwd)/scripts:/repo/scripts:Z,ro \
		$(DEV_IMG) "/opt/test_scripts.sh"
	@echo "Running End-to-End Repository Test..."
	$(MAKE) stop-serve
	$(MAKE) serve
	$(CONTAINER_ENGINE) run --rm \
		--network=host \
		-v $(shell pwd)/tests/test_sietch.sh:/opt/test_sietch.sh:Z,ro \
		$(DEV_IMG) "/opt/test_sietch.sh" "$(REPO_URL)" "$(GPG_KEY)" "$(CODENAME)" "$(PACKAGES_LIST)"
