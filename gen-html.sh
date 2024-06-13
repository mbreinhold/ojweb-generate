#! /bin/bash -e

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

PAGE_XSL=$HOME/page.xsl
MATHJAX_URL=https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-chtml.js

SRC=$1; shift
SUBDIR=$1; shift
COMMENTS_TO=$1; shift

case $SUBDIR in
  .) SUBDIR=;;
  *) SUBDIR=$SUBDIR/;;
esac

YEAR=$(date +%Y)

GIT=$(TZ=UTC git log -1 --abbrev=12 \
             --date=format-local:'%Y/%m/%d %02H:%02M %Z' \
             --format='%cd@%h' $SRC)
if ! [ "$GIT" ]; then GIT='unknown@unknown'; fi
TIME=$(echo "$GIT" | cut -d@ -f1)
HASH=$(echo "$GIT" | cut -d@ -f2)
ISOTIME=$(git log -1 --date=iso-strict --format='%cd' $SRC)
BRANCH=$(git branch --show-current)

r=$(git config remote.origin.url)
case "$r" in
  http*) REMOTE="$(echo $r | sed -re 's/\.git$//')";;
  *) REMOTE=unknown;;
esac

s=$(echo $SRC | sed -re 's/\.[^\.]+//')
HEAD=
if [ -r $s.head ]; then HEAD=$(realpath $s.head); fi

xsltproc --nonet \
  --stringparam year $YEAR \
  --stringparam hash $HASH \
  --stringparam time "$TIME" \
  --stringparam isotime "$ISOTIME" \
  --stringparam remote "$REMOTE" \
  --stringparam branch "$BRANCH" \
  --stringparam file "$SUBDIR$SRC" \
  --stringparam head "$HEAD" \
  --stringparam mathjax-url "$MATHJAX_URL" \
  --stringparam comments-to "$COMMENTS_TO" \
  $PAGE_XSL - \
| sed -re 's!<br></br>!<br>!' -e 's/ – /\&#x200A;—\&#x200A;/g'

if [ $? != 0 ]; then exit 4; fi
