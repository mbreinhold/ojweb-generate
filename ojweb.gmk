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

# To customize this Makefile, create a `Local.gmk` file in your docs
# directory.  Be aware, however, that the more complex your customization
# then the higher the probability that it will break with future versions
# of this Makefile.  Consider, instead, proposing changes to this
# Makefile and related files.


SHELL = /bin/bash		# So that we can `set -o pipefail`

HOME = $(patsubst %/,%,$(dir $(firstword $(MAKEFILE_LIST))))

SUBDIR ?=			# Optional subdirectory to include in Git URLs
BUILD ?= build

TIMESTAMP = $(shell git log --abbrev=12 --format=%h -1) $(shell date -Im)


# Note an update

UPDATED_FILE = $(BUILD)/.updated

define UPDATED
	@echo '$(TIMESTAMP)' >$(UPDATED_FILE)
	@rm -f $(BUILD)/_map
endef


# Markdown

MD_SRC = $(shell find * -type f -name '*.md')
MD_DST = $(patsubst %.md,$(BUILD)/%,$(MD_SRC))
MAP += $(patsubst $(BUILD)/%, %, $(MD_DST))

all:: $(MD_DST)

PANDOC_OPTS = -f markdown+tex_math_single_backslash --mathjax \
              -t html --section-divs --no-highlight --toc \
              $(MORE_PANDOC_OPTS)

define PANDOC
pandoc -s -M pagetitle=Untitled -V lang=en_US \
	$(PANDOC_OPTS) $(1) -o -
endef

define TIDY
(tidy -q -utf8 -asxhtml -n --doctype omit --tidy-mark n -w 0 \
      --warn-proprietary-attributes n; \
 if [ $$? = 2 ]; then exit 2; fi)
endef

HEADER_XSL = $(HOME)/header.xsl

define HEADER
(xsltproc --nonet $(HEADER_XSL) -; if [ $$? != 0 ]; then exit 3; fi)
endef

define GENERATE
HOME=$(HOME) bash $(HOME)/gen-html.sh $(1) $(SUBDIR)
endef

# If you're creating a `Local.gmk` to customize Markdown processing then
# if overriding any of the above variables does not suffice then consider
# creating a variant of this rule for specific targets:
$(BUILD)/%: %.md $(HOME)/header.xsl $(HOME)/page.xsl $(HOME)/gen-html.sh
	@mkdir -p $(dir $@)
	set -o pipefail; \
	  $(call PANDOC,$<) | $(TIDY) | $(HEADER) | $(call GENERATE,$<) >$@ \
	  || (s=$$?; rm -f $@; exit $$s)
	$(UPDATED)


# Prerequisites for optional .head files

$(foreach file,$(MD_SRC),$(eval $(patsubst %.md,$(BUILD)/%,$(file)): \
                                $(wildcard $(basename $(file)).head)))


# Just copy a file
define COPY_FILE
	@mkdir -p $(dir $@)
	cp "$<" "$@"
	$(UPDATED)
endef


# CSS

CSS_NAME = page-serif.css

$(BUILD)/$(CSS_NAME): $(HOME)/$(CSS_NAME)
	@mkdir -p $(dir $@)
	sed -re '1,/^ \*\//d' $< >$@
	$(UPDATED)

ifndef NOCSS
all:: $(BUILD)/$(CSS_NAME)
endif


# HTML content

HTML_SRC = $(shell find * -type f -name '*.html')
HTML_DST = $(patsubst %.html,$(BUILD)/%,$(HTML_SRC))
MAP += $(patsubst $(BUILD)/%, %, $(HTML_DST))

all:: $(HTML_DST)

$(BUILD)/%: %.html
	$(COPY_FILE)


# Non-Markdown/HTML content

OTHER_SRC = $(shell find * -type f \
	                 \( -name '*.jpg' -o -name '*.png' -o -name '*.svg' \) \
                    | grep -v '^build/')
OTHER_DST = $(patsubst %,$(BUILD)/%,$(OTHER_SRC))

all:: $(OTHER_DST)

$(BUILD)/%: %
	$(COPY_FILE)


# Local definitions

-include Local.gmk


# Simple subtree map

all:: $(BUILD)/_map

$(BUILD)/_map: $(HOME)/map.sh
	@mkdir -p $(dir $@)
	bash $(HOME)/map.sh "$(TIMESTAMP)" $(MAP) >$@ || (rm -f $@; exit 1)


# Preview

preview:
	java $(HOME)/TinyWebServer.java $(BUILD) &


# Cleanup

clean:
	rm -rf $(BUILD)


.PHONY: all preview clean
