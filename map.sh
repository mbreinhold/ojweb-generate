#! /bin/bash

TS="$1"; shift

echo '<h2>Subtree map</h2><pre>'
echo $* | sed -re 's! +!\n!g' | sort \
| sed -re 's!.*!<a href="&">&</a>!'
echo
echo $TS | sed -re 's/ /\n/'
echo '</pre>'
