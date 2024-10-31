cd `dirname $0`/../../trunk/lang/language-names
pwd
echo -n 'Generating language-*-mo... '

if [ ! -z "2" ]; then
  find . -name "*.po"|while read po
  do
  mo=`basename $po .po`.mo
  echo Making $mo
  if [ -f "$mo" ]; then mv $mo $mo.org; fi
  msgfmt $po -o $mo &>$mo.err
  if [ -s "$mo.err" ]; then
    mv $mo $mo.bad
    mv $mo.org $mo
  else
    rm -f $mo.err
    rm -f $mo.org
  fi
  done
fi

