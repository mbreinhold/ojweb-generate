#! /bin/bash -e

SRC=$1
DST=$2

YEAR=$(date +%Y)

GIT=$(TZ=UTC git log -1 --abbrev=12 \
             --date=format-local:'%Y/%m/%d %02H:%02M %Z' \
             --format='%cd@%h' $SRC)
if ! [ "$GIT" ]; then GIT='unknown@unknown'; fi
TIME=$(echo "$GIT" | cut -d@ -f1)
HASH=$(echo "$GIT" | cut -d@ -f2)
BRANCH=$(git branch --show-current)

r=$(git config remote.origin.url)
case "$r" in
  http*) REMOTE="$(echo $r | sed -re 's/\.git$//')";;
  *) REMOTE=unknown;;
esac

PAGE_XSL=$HOME/page.xsl
PANDOC='pandoc -t html --section-divs --no-highlight'

dopandoc() {
  echo '<html><head><title/></head><body>'
  if ! $PANDOC $SRC -o -; then exit 1; fi
  echo '</body></html>'
}

dotidy() {
  tidy -q -utf8 -asxhtml -n --doctype omit --tidy-mark n -w 0
}

doxslt() {
  xsltproc --nonet \
    --stringparam year $YEAR \
    --stringparam hash $HASH \
    --stringparam time "$TIME" \
    --stringparam remote "$REMOTE" \
    --stringparam branch "$BRANCH" \
    --stringparam file "$SRC" \
    $PAGE_XSL -
}

cleanup() {
  sed -re 's!<br></br>!<br>!' -e 's/ – /\&#x200A;—\&#x200A;/g'
}

set -o pipefail
dopandoc | dotidy | doxslt | cleanup
