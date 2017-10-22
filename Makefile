# Makefile

PIL_MODULE_DIR ?= .modules
REPO_PREFIX ?= https://github.com/aw

## Edit below
JSON_REPO = $(REPO_PREFIX)/picolisp-json.git
JSON_DIR = $(PIL_MODULE_DIR)/picolisp-json/HEAD
JSON_REF ?= v2.2.0
SEMVER_REPO = $(REPO_PREFIX)/picolisp-semver.git
SEMVER_DIR = $(PIL_MODULE_DIR)/picolisp-semver/HEAD
SEMVER_REF ?= v0.8.0
## Edit above

# Unit testing
TEST_REPO = $(REPO_PREFIX)/picolisp-unit.git
TEST_DIR = $(PIL_MODULE_DIR)/picolisp-unit/HEAD

# Generic
.PHONY: all clean

all: $(JSON_DIR) $(SEMVER_DIR)

$(JSON_DIR):
		mkdir -p $(JSON_DIR) && \
		git clone $(JSON_REPO) $(JSON_DIR) && \
		cd $(JSON_DIR) && \
		git checkout $(JSON_REF) && \
		$(MAKE)

$(SEMVER_DIR):
		mkdir -p $(SEMVER_DIR) && \
		git clone $(SEMVER_REPO) $(SEMVER_DIR) && \
		cd $(SEMVER_DIR) && \
		git checkout $(SEMVER_REF) && \
		$(MAKE)

$(TEST_DIR):
		mkdir -p $(TEST_DIR) && \
		git clone $(TEST_REPO) $(TEST_DIR)

check: all $(TEST_DIR) run-tests

run-tests:
		PIL_NAMESPACES=false ./test.l

html:
		jade -o . -P -E html ui/index.jade

javascript:
		cat ui/license.coffee ui/generic.coffee ui/ui.coffee | coffee --no-header -c -s > docs/ui.js

js: javascript

minify:
		head -n 8 docs/ui.js > docs/ui.min.js
		minify docs/ui.js >> docs/ui.min.js

ui: html javascript minify

clean:
		rm -rf $(JSON_DIR) $(SEMVER_DIR) $(TEST_DIR)
