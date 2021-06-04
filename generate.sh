#! /bin/bash -e

SRC=$1
DST=$2

YEAR=$(date +%Y)

TIDY='tidy -q -utf8 -asxhtml -n --doctype omit --tidy-mark n -w 0'
PAGE_XSL=$HOME/page.xsl
XSLT_PARAMS="--stringparam year $YEAR"
XSLT="xsltproc --nonet $XSLT_PARAMS"
PANDOC='pandoc -t html --section-divs --no-highlight'

dopandoc() {
  echo '<html><head><title/></head><body>'
  if ! $PANDOC $SRC -o -; then exit 1; fi
  echo '</body></html>'
}

set -o pipefail
dopandoc \
| $TIDY | $XSLT $PAGE_XSL - \
| sed -re 's!<br></br>!<br>!' -e 's/ – /\&#x200A;—\&#x200A;/g'
