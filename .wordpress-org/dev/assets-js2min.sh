#!/bin/bash
d=`dirname $0`
cd $d
if [ -h "../../trunk/qtranslate.min.js" ]; then
  rm ../../trunk/qtranslate.min.js
  curl -X POST -s --data-urlencode 'input@qtranslate.js' http://javascript-minifier.com/raw > ../../trunk/qtranslate.min.js
else
  rm -f ../../trunk/qtranslate.min.js
  ln -s ../assets/dev/qtranslate.js ../../trunk/qtranslate.min.js
fi
