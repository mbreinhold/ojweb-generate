#! /bin/bash

echo '<h2>Site map</h2>'
echo $* | sed -re 's! +!\n!g' | sort \
| sed -re 's!.*!<a href="&">&</a><br>!'
