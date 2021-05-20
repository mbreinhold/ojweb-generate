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

SHELL = /bin/bash		# So that we can use set -o pipefail

DATE = $(shell date +%Y)
BUILD ?= build
UPDATED = $(BUILD)/.updated

TIDY = tidy -q -utf8 -asxhtml -n --doctype omit --tidy-mark n -w 80
XSLT_PARAMS = --stringparam year "$(DATE)"
XSLT = xsltproc --nonet $(XSLT_PARAMS)
PANDOC = pandoc -f gfm-auto_identifiers+grid_tables+smart -t html \
                --section-divs --no-highlight

PAGE_XSL = $(HOME)/page.xsl


# Markdown

MD_SRC = $(shell find * -type f -name '*.md')
MD_DST = $(patsubst %.md,$(BUILD)/%,$(MD_SRC))

$(BUILD)/%: %.md
	@mkdir -p $(dir $@)
	(set -o pipefail; \
	 (echo '<html><head><title/></head><body>'; $(PANDOC) $< -o -; echo '</body></html>') \
	  | tee /tmp/h1 | $(TIDY) | $(XSLT) $(PAGE_XSL) - \
	  | sed -re 's!<br></br>!<br>!' >$@) || (rm -f $@; exit 1)
	@touch $(UPDATED)

all:: $(MD_DST)


# Just copy a file
define copy-file
	@mkdir -p $(dir $@)
	cp $< $@
	@touch $(UPDATED)
endef


# CSS

$(BUILD)/project.css: $(HOME)/project.css
	$(copy-file)

ifndef NOCSS
all:: $(BUILD)/project.css
endif

# HTML content

HTML_SRC = $(shell find * -type f -name '*.html')
HTML_DST = $(patsubst %.html,$(BUILD)/%,$(HTML_SRC))

$(BUILD)/%: %.html
	$(copy-file)

all:: $(HTML_DST)


# Non-Markdown/HTML content

OTHER_SRC = $(shell find * -type f \
                           \( -name '*.jpg' -o -name '*.gif' -o -name '*.svg' \))
OTHER_DST = $(patsubst %,$(BUILD)/%,$(OTHER_SRC))

all:: $(OTHER_DST)

$(BUILD)/%: %
	$(copy-file)


# Preview

preview:
	java $(HOME)/TinyWebServer.java $(BUILD) &
