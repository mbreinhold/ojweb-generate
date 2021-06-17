#
# Copyright (c) 2021, Oracle and/or its affiliates. All rights reserved.
# DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
#
# This code is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 2 only, as
# published by the Free Software Foundation.  Oracle designates this
# particular file as subject to the "Classpath" exception as provided
# by Oracle in the LICENSE file that accompanied this code.
#
# This code is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# version 2 for more details (a copy is included in the LICENSE file that
# accompanied this code).
#
# You should have received a copy of the GNU General Public License version
# 2 along with this work; if not, write to the Free Software Foundation,
# Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA.
#
# Please contact Oracle, 500 Oracle Parkway, Redwood Shores, CA 94065 USA
# or visit www.oracle.com if you need additional information or have any
# questions.
#

HOME = $(dir $(firstword $(MAKEFILE_LIST)))

SUBDIR ?=			# Optional subdirectory to include in Git URLs
BUILD ?= build

TS = $(shell git log --abbrev=12 --format=%h -1) $(shell date -Im)
UPDATED = $(BUILD)/.updated

CSS = page-serif.css


# Note an update
define updated
	@echo '$(TS)' >$(UPDATED)
	@rm -f $(BUILD)/_map
endef


# Markdown

MD_SRC = $(shell find * -type f -name '*.md')
MD_DST = $(patsubst %.md,$(BUILD)/%,$(MD_SRC))
MAP += $(patsubst $(BUILD)/%, %, $(MD_DST))

all:: $(MD_DST)

$(BUILD)/%: %.md $(HOME)/header.xsl $(HOME)/page.xsl $(HOME)/generate.sh
	@mkdir -p $(dir $@)
	HOME=$(HOME) bash $(HOME)/generate.sh $< $(SUBDIR) >$@ || (rm -f $@; exit 1)
	$(updated)

$(foreach file,$(MD_SRC),$(eval $(patsubst %.md,$(BUILD)/%,$(file)): \
                                $(wildcard $(basename $(file)).head)))

# Just copy a file
define copy-file
	@mkdir -p $(dir $@)
	cp "$<" "$@"
	$(updated)
endef


# CSS

$(BUILD)/$(CSS): $(HOME)/$(CSS)
	@mkdir -p $(dir $@)
	sed -re '1,/^ \*\//d' $< >$@
	$(updated)

ifndef NOCSS
all:: $(BUILD)/$(CSS)
endif


# HTML content

HTML_SRC = $(shell find * -type f -name '*.html')
HTML_DST = $(patsubst %.html,$(BUILD)/%,$(HTML_SRC))
MAP += $(patsubst $(BUILD)/%, %, $(HTML_DST))

all:: $(HTML_DST)

$(BUILD)/%: %.html
	$(copy-file)


# Non-Markdown/HTML content

OTHER_SRC = $(shell find * -type f \
                           \( -name '*.jpg' -o -name '*.gif' -o -name '*.svg' \))
OTHER_DST = $(patsubst %,$(BUILD)/%,$(OTHER_SRC))

all:: $(OTHER_DST)

$(BUILD)/%: %
	$(copy-file)


# Simple subtree map

all:: $(BUILD)/_map

$(BUILD)/_map: $(HOME)/map.sh
	@mkdir -p $(dir $@)
	bash $(HOME)/map.sh "$(TS)" $(MAP) >$@ || (rm -f $@; exit 1)


# Preview

preview:
	java $(HOME)/TinyWebServer.java $(BUILD) &
