#! /bin/bash -e

SRC=$1; shift
SUBDIR=$1; shift

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

PANDOC='pandoc -s -M pagetitle=foo -V lang=en_US
       -t html --section-divs --no-highlight --toc'

dopandoc() {
  if ! $PANDOC $SRC -o -; then exit 1; fi
}

dotidy() {
  tidy -q -utf8 -asxhtml -n --doctype omit --tidy-mark n -w 0 \
       --warn-proprietary-attributes n
  if [ $? = 2 ]; then exit 2; fi     # 2 => Warnings only
}

HEADER_XSL=$HOME/header.xsl
PAGE_XSL=$HOME/page.xsl

doheader() {
  xsltproc --nonet $HEADER_XSL -
}

dopage() {
  xsltproc --nonet \
    --stringparam year $YEAR \
    --stringparam hash $HASH \
    --stringparam time "$TIME" \
    --stringparam isotime "$ISOTIME" \
    --stringparam remote "$REMOTE" \
    --stringparam branch "$BRANCH" \
    --stringparam file "$SUBDIR$SRC" \
    --stringparam head "$HEAD" \
    $PAGE_XSL -
}

cleanup() {
  sed -re 's!<br></br>!<br>!' -e 's/ – /\&#x200A;—\&#x200A;/g'
}

set -o pipefail
dopandoc | dotidy | doheader | dopage | cleanup
