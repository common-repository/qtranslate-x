#!/bin/bash
d=`dirname $0`
cd $d
cd ../../trunk
find . -name "*.js" -a ! -name "*.min.js" -a ! -path "./dev/*" | while read fn; do
  echo -n "$fn -> "
  fnmin=${fn/.js}.min.js
  #echo fnmin=$fnmin
  if [ -h "$fnmin" ]; then
    echo "$fnmin (file)"
    rm -f $fnmin
    #echo "curl -X POST -s --data-urlencode 'input@'$fn http://javascript-minifier.com/raw > $fnmin";
    curl -X POST -s --data-urlencode 'input@'$fn http://javascript-minifier.com/raw > $fnmin
  else
    echo "$fnmin (link)"
    rm -f $fnmin
    fnb=`basename $fn`
    #echo "ln -s $fnb $fnmin"
    ln -s $fnb $fnmin
  fi
done
exit
