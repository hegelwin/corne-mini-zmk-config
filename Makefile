SHELL := /bin/bash
.DEFAULT_GOAL := help

# Host OS (used for flashing helpers)
UNAME_S := $(shell uname -s)

# ---- User-tunable vars ----

KEYMAP ?= config/corne_choc.keymap

# PDF
PDF_OUTDIR ?= artifacts/layouts
PDF_COLUMNS ?= 10
PDF_LAYOUT ?= {split: true, rows: 3, columns: 5, thumbs: 3}
PDF_PAGES ?= 2
PDF_WITH_COMBOS ?= 0
PDF_LAYERS ?=

# Join existing SVGs into a multi-page PDF
PDF_SVGS ?=
PDF_SVGS_OUT ?= artifacts/layouts/from_svgs.pdf

# Firmware (Docker)
ZMK_DOCKER_IMAGE ?= zmkfirmware/zmk-build-arm:stable
DIST_DIR ?= dist
DOCKER_USER_ARGS ?= --user $(shell id -u):$(shell id -g)
ZMK_WORKSPACE_DIR ?= .zmk-workspace
WEST_UPDATE ?= 1

# Flash
# Example: make flash-right MOUNT=/Volumes/NICENANO
MOUNT ?=

.PHONY: help
help:
	@printf '%s\n' \
		"Targets:" \
		"  make pdf                     Build keymap PDF (outputs to artifacts/layouts/)" \
		"  make pdf-svgs                Join SVGs into a multi-page PDF" \
		"  make firmware                 Build normal UF2s (nice_view) (outputs to dist/)" \
		"  make firmware-reset           Build settings_reset UF2s (outputs to dist/)" \
		"  make firmware-all             Build normal + reset UF2s (outputs to dist/)" \
		"  make firmware-left-niceview   Build left nice_view UF2" \
		"  make firmware-right-niceview  Build right nice_view UF2" \
		"  make firmware-left-reset      Build left settings_reset UF2" \
		"  make firmware-right-reset     Build right settings_reset UF2" \
		"  make firmware-clean           Remove cached west workspace (.zmk-workspace/)" \
		"  make flash-left                Copy dist/left-niceview.uf2 to MOUNT" \
		"  make flash-right               Copy dist/right-niceview.uf2 to MOUNT" \
		"  make flash-left-reset         Copy dist/left-reset.uf2 to MOUNT" \
		"  make flash-right-reset        Copy dist/right-reset.uf2 to MOUNT" \
		"" \
		"Common vars:" \
		"  KEYMAP=<path>        ZMK *.keymap file (default: config/corne_choc.keymap)" \
		"  MOUNT=<dir>          UF2 drive mount, like /Volumes/NICENANO (flash targets)" \
		"" \
		"PDF vars:" \
		"  PDF_PAGES=2         Split layers across this many PDF pages (default: 2)" \
		"  PDF_WITH_COMBOS=1    Include combos (default: skip combos)" \
		"  PDF_LAYERS=\"A B\"     Only draw these layer names (optional)" \
		"  PDF_LAYOUT='{...}'   Ortho layout YAML string (optional)" \
		"  PDF_SVGS=\"a.svg b.svg\"  Input SVGs for pdf-svgs target" \
		"  PDF_SVGS_OUT=...     Output PDF path for pdf-svgs target" \
		"" \
		"Firmware vars:" \
		"  ZMK_DOCKER_IMAGE=... Docker image to use (optional)" \
		"  ZMK_WORKSPACE_DIR=.. Cached west workspace dir (default: .zmk-workspace)" \
		"  WEST_UPDATE=0       Skip west update (use cached repos as-is)"

# ---- PDF ----

ifneq ($(strip $(PDF_LAYERS)),)
PDF_LAYERS_ARGS := --layers $(PDF_LAYERS)
endif

ifneq ($(strip $(PDF_WITH_COMBOS)),0)
PDF_COMBO_ARGS := --with-combos
endif

.PHONY: pdf
pdf:
	./scripts/make-layout-pdf.sh \
		--keymap "$(KEYMAP)" \
		--outdir "$(PDF_OUTDIR)" \
		--columns "$(PDF_COLUMNS)" \
		--pages "$(PDF_PAGES)" \
		--layout '$(PDF_LAYOUT)' \
		$(PDF_COMBO_ARGS) \
		$(PDF_LAYERS_ARGS)

.PHONY: pdf-svgs
pdf-svgs:
	./scripts/svgs-to-pdf.sh \
		--out "$(PDF_SVGS_OUT)" \
		$(PDF_SVGS)

# ---- Firmware (Docker) ----

.PHONY: firmware firmware-reset firmware-all firmware-left-niceview firmware-right-niceview firmware-left-reset firmware-right-reset
firmware:
	@mkdir -p "$(DIST_DIR)" "$(ZMK_WORKSPACE_DIR)"
	docker run --rm \
		$(DOCKER_USER_ARGS) \
		-e HOME=/tmp/home \
		-v "$$PWD":/workspace \
		-v "$(abspath $(ZMK_WORKSPACE_DIR))":/zmk-workspace \
		-w /workspace \
		"$(ZMK_DOCKER_IMAGE)" bash -lc ' \
			set -euo pipefail; \
			mkdir -p "$$HOME"; \
			mkdir -p /zmk-workspace; \
			rm -rf /zmk-workspace/config; \
			cp -R /workspace/config /zmk-workspace/config; \
			cd /zmk-workspace; \
			if [ ! -d .west ]; then west init -l config; fi; \
			if [ "$(WEST_UPDATE)" = "1" ]; then west update --fetch-opt=--filter=tree:0; fi; \
			west zephyr-export; \
			mkdir -p /workspace/$(DIST_DIR); \
			build() { \
			  local name="$$1"; shift; \
			  local board="$$1"; shift; \
			  local shield="$$1"; shift; \
			  local snippet="$${1:-}"; shift || true; \
			  local extra="$${1:-}"; \
			  local snippet_args=""; \
			  if [ -n "$$snippet" ]; then snippet_args="-S $$snippet"; fi; \
			  local build_dir="/zmk-workspace/build-$${name}"; \
			  west build -s zmk/app -d "$$build_dir" -b "$$board" $$snippet_args -- \
			    -DZMK_CONFIG=/zmk-workspace/config -DSHIELD="$$shield" -DZMK_EXTRA_MODULES=/workspace $$extra; \
			  if [ -f "$$build_dir/zephyr/zmk.uf2" ]; then \
			    cp "$$build_dir/zephyr/zmk.uf2" "/workspace/$(DIST_DIR)/$${name}.uf2"; \
			  elif [ -f "$$build_dir/zmk.uf2" ]; then \
			    cp "$$build_dir/zmk.uf2" "/workspace/$(DIST_DIR)/$${name}.uf2"; \
			  else \
			    echo "UF2 not found in $$build_dir" >&2; exit 2; \
			  fi; \
			}; \
			build left-niceview  corne_choc_left  nice_view studio-rpc-usb-uart "-DCONFIG_ZMK_STUDIO=y -DCONFIG_ZMK_BLE_EXPERIMENTAL_CONN=y"; \
			build right-niceview corne_choc_right nice_view; \
		'

firmware-reset:
	@mkdir -p "$(DIST_DIR)" "$(ZMK_WORKSPACE_DIR)"
	docker run --rm \
		$(DOCKER_USER_ARGS) \
		-e HOME=/tmp/home \
		-v "$$PWD":/workspace \
		-v "$(abspath $(ZMK_WORKSPACE_DIR))":/zmk-workspace \
		-w /workspace \
		"$(ZMK_DOCKER_IMAGE)" bash -lc ' \
			set -euo pipefail; \
			mkdir -p "$$HOME"; \
			mkdir -p /zmk-workspace; \
			rm -rf /zmk-workspace/config; \
			cp -R /workspace/config /zmk-workspace/config; \
			cd /zmk-workspace; \
			if [ ! -d .west ]; then west init -l config; fi; \
			if [ "$(WEST_UPDATE)" = "1" ]; then west update --fetch-opt=--filter=tree:0; fi; \
			west zephyr-export; \
			mkdir -p /workspace/$(DIST_DIR); \
			build() { \
			  local name="$$1"; shift; \
			  local board="$$1"; shift; \
			  local shield="$$1"; shift; \
			  local snippet="$${1:-}"; shift || true; \
			  local extra="$${1:-}"; \
			  local snippet_args=""; \
			  if [ -n "$$snippet" ]; then snippet_args="-S $$snippet"; fi; \
			  local build_dir="/zmk-workspace/build-$${name}"; \
			  west build -s zmk/app -d "$$build_dir" -b "$$board" $$snippet_args -- \
			    -DZMK_CONFIG=/zmk-workspace/config -DSHIELD="$$shield" -DZMK_EXTRA_MODULES=/workspace $$extra; \
			  if [ -f "$$build_dir/zephyr/zmk.uf2" ]; then \
			    cp "$$build_dir/zephyr/zmk.uf2" "/workspace/$(DIST_DIR)/$${name}.uf2"; \
			  elif [ -f "$$build_dir/zmk.uf2" ]; then \
			    cp "$$build_dir/zmk.uf2" "/workspace/$(DIST_DIR)/$${name}.uf2"; \
			  else \
			    echo "UF2 not found in $$build_dir" >&2; exit 2; \
			  fi; \
			}; \
			build left-reset     corne_choc_left  settings_reset; \
			build right-reset    corne_choc_right settings_reset; \
		'

firmware-all: firmware firmware-reset

firmware-left-niceview:
	@mkdir -p "$(DIST_DIR)" "$(ZMK_WORKSPACE_DIR)"
	docker run --rm $(DOCKER_USER_ARGS) -e HOME=/tmp/home -v "$$PWD":/workspace -v "$(abspath $(ZMK_WORKSPACE_DIR))":/zmk-workspace -w /workspace "$(ZMK_DOCKER_IMAGE)" bash -lc ' \
		set -euo pipefail; mkdir -p "$$HOME"; mkdir -p /zmk-workspace; rm -rf /zmk-workspace/config; cp -R /workspace/config /zmk-workspace/config; cd /zmk-workspace; \
		if [ ! -d .west ]; then west init -l config; fi; if [ "$(WEST_UPDATE)" = "1" ]; then west update --fetch-opt=--filter=tree:0; fi; west zephyr-export; mkdir -p /workspace/$(DIST_DIR); \
		west build -s zmk/app -d /zmk-workspace/build-left-niceview -b corne_choc_left -S studio-rpc-usb-uart -- \
		  -DZMK_CONFIG=/zmk-workspace/config -DSHIELD=nice_view -DZMK_EXTRA_MODULES=/workspace -DCONFIG_ZMK_STUDIO=y -DCONFIG_ZMK_BLE_EXPERIMENTAL_CONN=y; \
		if [ -f /zmk-workspace/build-left-niceview/zephyr/zmk.uf2 ]; then cp /zmk-workspace/build-left-niceview/zephyr/zmk.uf2 /workspace/$(DIST_DIR)/left-niceview.uf2; \
		elif [ -f /zmk-workspace/build-left-niceview/zmk.uf2 ]; then cp /zmk-workspace/build-left-niceview/zmk.uf2 /workspace/$(DIST_DIR)/left-niceview.uf2; \
		else echo "UF2 not found" >&2; exit 2; fi; \
	'

firmware-right-niceview:
	@mkdir -p "$(DIST_DIR)" "$(ZMK_WORKSPACE_DIR)"
	docker run --rm $(DOCKER_USER_ARGS) -e HOME=/tmp/home -v "$$PWD":/workspace -v "$(abspath $(ZMK_WORKSPACE_DIR))":/zmk-workspace -w /workspace "$(ZMK_DOCKER_IMAGE)" bash -lc ' \
		set -euo pipefail; mkdir -p "$$HOME"; mkdir -p /zmk-workspace; rm -rf /zmk-workspace/config; cp -R /workspace/config /zmk-workspace/config; cd /zmk-workspace; \
		if [ ! -d .west ]; then west init -l config; fi; if [ "$(WEST_UPDATE)" = "1" ]; then west update --fetch-opt=--filter=tree:0; fi; west zephyr-export; mkdir -p /workspace/$(DIST_DIR); \
		west build -s zmk/app -d /zmk-workspace/build-right-niceview -b corne_choc_right -- \
		  -DZMK_CONFIG=/zmk-workspace/config -DSHIELD=nice_view -DZMK_EXTRA_MODULES=/workspace; \
		if [ -f /zmk-workspace/build-right-niceview/zephyr/zmk.uf2 ]; then cp /zmk-workspace/build-right-niceview/zephyr/zmk.uf2 /workspace/$(DIST_DIR)/right-niceview.uf2; \
		elif [ -f /zmk-workspace/build-right-niceview/zmk.uf2 ]; then cp /zmk-workspace/build-right-niceview/zmk.uf2 /workspace/$(DIST_DIR)/right-niceview.uf2; \
		else echo "UF2 not found" >&2; exit 2; fi; \
	'

firmware-left-reset:
	@mkdir -p "$(DIST_DIR)" "$(ZMK_WORKSPACE_DIR)"
	docker run --rm $(DOCKER_USER_ARGS) -e HOME=/tmp/home -v "$$PWD":/workspace -v "$(abspath $(ZMK_WORKSPACE_DIR))":/zmk-workspace -w /workspace "$(ZMK_DOCKER_IMAGE)" bash -lc ' \
		set -euo pipefail; mkdir -p "$$HOME"; mkdir -p /zmk-workspace; rm -rf /zmk-workspace/config; cp -R /workspace/config /zmk-workspace/config; cd /zmk-workspace; \
		if [ ! -d .west ]; then west init -l config; fi; if [ "$(WEST_UPDATE)" = "1" ]; then west update --fetch-opt=--filter=tree:0; fi; west zephyr-export; mkdir -p /workspace/$(DIST_DIR); \
		west build -s zmk/app -d /zmk-workspace/build-left-reset -b corne_choc_left -- \
		  -DZMK_CONFIG=/zmk-workspace/config -DSHIELD=settings_reset -DZMK_EXTRA_MODULES=/workspace; \
		if [ -f /zmk-workspace/build-left-reset/zephyr/zmk.uf2 ]; then cp /zmk-workspace/build-left-reset/zephyr/zmk.uf2 /workspace/$(DIST_DIR)/left-reset.uf2; \
		elif [ -f /zmk-workspace/build-left-reset/zmk.uf2 ]; then cp /zmk-workspace/build-left-reset/zmk.uf2 /workspace/$(DIST_DIR)/left-reset.uf2; \
		else echo "UF2 not found" >&2; exit 2; fi; \
	'

firmware-right-reset:
	@mkdir -p "$(DIST_DIR)" "$(ZMK_WORKSPACE_DIR)"
	docker run --rm $(DOCKER_USER_ARGS) -e HOME=/tmp/home -v "$$PWD":/workspace -v "$(abspath $(ZMK_WORKSPACE_DIR))":/zmk-workspace -w /workspace "$(ZMK_DOCKER_IMAGE)" bash -lc ' \
		set -euo pipefail; mkdir -p "$$HOME"; mkdir -p /zmk-workspace; rm -rf /zmk-workspace/config; cp -R /workspace/config /zmk-workspace/config; cd /zmk-workspace; \
		if [ ! -d .west ]; then west init -l config; fi; if [ "$(WEST_UPDATE)" = "1" ]; then west update --fetch-opt=--filter=tree:0; fi; west zephyr-export; mkdir -p /workspace/$(DIST_DIR); \
		west build -s zmk/app -d /zmk-workspace/build-right-reset -b corne_choc_right -- \
		  -DZMK_CONFIG=/zmk-workspace/config -DSHIELD=settings_reset -DZMK_EXTRA_MODULES=/workspace; \
		if [ -f /zmk-workspace/build-right-reset/zephyr/zmk.uf2 ]; then cp /zmk-workspace/build-right-reset/zephyr/zmk.uf2 /workspace/$(DIST_DIR)/right-reset.uf2; \
		elif [ -f /zmk-workspace/build-right-reset/zmk.uf2 ]; then cp /zmk-workspace/build-right-reset/zmk.uf2 /workspace/$(DIST_DIR)/right-reset.uf2; \
		else echo "UF2 not found" >&2; exit 2; fi; \
	'

.PHONY: firmware-clean
firmware-clean:
	rm -rf "$(ZMK_WORKSPACE_DIR)"

# ---- Flash ----

define _flash_template
	@bash -lc 'set -euo pipefail; \
	  uf2="$(1)"; \
	  mount="$(MOUNT)"; \
	  if [ -z "$$mount" ] && [ "$$(uname -s)" = "Darwin" ]; then \
	    for v in /Volumes/*; do \
	      if [ -f "$$v/INFO_UF2.TXT" ]; then mount="$$v"; break; fi; \
	    done; \
	  fi; \
	  test -n "$$mount" || { echo "Error: set MOUNT=/Volumes/<UF2_DRIVE> (or mount a UF2 drive so it can be auto-detected)" >&2; exit 2; }; \
	  test -d "$$mount" || { echo "Error: mount not found: $$mount" >&2; exit 2; }; \
	  test -f "$$uf2" || { echo "Error: missing file: $$uf2 (run make firmware first)" >&2; exit 2; }; \
	  echo "Using UF2 mount: $$mount"; \
	  if [ "$$(uname -s)" = "Darwin" ]; then \
	    xattr -c "$$uf2" 2>/dev/null || true; \
	    dot_clean "$$mount" 2>/dev/null || true; \
	    cp -X "$$uf2" "$$mount/"; \
	  else \
	    cp "$$uf2" "$$mount/"; \
	  fi; \
	  sync || true; \
	  echo "Flashed: $$uf2 -> $$mount/"; \
	'
endef

.PHONY: flash-left flash-left-niceview flash-right flash-right-niceview flash-left-reset flash-right-reset
flash-left:
	$(call _flash_template,$(DIST_DIR)/left-niceview.uf2)

flash-left-niceview: flash-left

flash-right:
	$(call _flash_template,$(DIST_DIR)/right-niceview.uf2)

flash-right-niceview: flash-right

flash-left-reset:
	$(call _flash_template,$(DIST_DIR)/left-reset.uf2)

flash-right-reset:
	$(call _flash_template,$(DIST_DIR)/right-reset.uf2)

