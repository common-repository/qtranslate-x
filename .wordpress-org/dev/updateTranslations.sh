cd `dirname $0`/../../trunk
#pwd
if [ -z "$1" -a -z "$2" -a -z "$3" ]; then
  echo "USAGE: `basename $0` [pot] [po] [mo]";
fi
if [ -z "$1" ]; then
  cd lang
else
YEAR=2015
ver=`grep 'Version:' qtranslate.php|awk '{print $2}'`
descr=`grep 'Description:' qtranslate.php|awk -F': ' '{print $2}'`
#ver=3.3
echo -n 'Generating qtranslate.pot ... '
find . -name "*.php" ! -path '*/slugs/*' |sort >tmpfns.txt
# Extract translatable strings into the template
xgettext -f tmpfns.txt \
    --from-code=UTF-8 \
    --sort-by-file \
    --default-domain=default \
    --language=PHP \
    --keyword=__ \
    --keyword=qtranxf_translate \
    --keyword=_e \
    --keyword=_x:1,2c \
    --keyword=esc_attr_e \
    --no-wrap \
    --package-name=qTranslate-X \
    --package-version=$ver \
    --copyright-holder="qTranslate Team" \
    --output lang/qtranslate.pot.raw

# --add-comments=/ #works, but sometimes picks wrong things, we currently do not have any comments for TRANSLATORS.
# --sort-output
rm tmpfns.txt

#tail -n +18 qtranslate.pot >qtranslate.pot-nohead
#tail -n +18 qtranslate.pot.raw >qtranslate.pot.raw-nohead
#diff=`diff qtranslate.pot-nohead qtranslate.pot.raw-nohea`
#rm qtranslate.pot.raw* qtranslate.pot-nohead
#if [ -z "$diff" ]; then
#  echo "lang/qtranslate.pot has not changed - nothing to update"
#  exit
#fi

cd lang

if [ -e "qtranslate.pot" ]; then
  if [ ! -e "qtranslate.pot.org" ]; then
    cp -p qtranslate.pot qtranslate.pot.org
  fi
  cp -p qtranslate.pot qtranslate.pot~
fi

sed 's/charset=CHARSET/charset=UTF-8/' qtranslate.pot.raw |sed 's/SOME DESCRIPTIVE TITLE/qTranslate-X Translation Template/' |sed "s/Copyright (C) YEAR/Copyright (C) $YEAR/" |sed "s/LANGUAGE <LL@li.org>/qTranslate Team Translators/" |sed 's/license as the PACKAGE package/license as the qTranslate-X package/' |sed "s/FIRST AUTHOR <EMAIL@ADDRESS>, YEAR/qTranslate Team <qtranslateteam@gmail.com>, 2015/" >qtranslate.pot
#|sed 'N;N;N;s/^.*admin\/qtx_configuration.php:.*\nmsgid "Admin Color Scheme"\nmsgstr ""//'
#mv qtranslate.pot.raw qtranslate.pot
#exit
rm qtranslate.pot.raw
echo -e "\n#: qtranslate.php:5\nmsgid \"$descr\"\nmsgstr \"\"" >>qtranslate.pot
if [ -f 'language-names.pot' ]; then
  grep -v '# ' language-names.pot | tail -n +4 >>qtranslate.pot
fi
echo done; #.pot
fi

if [ ! -z "$2" ]; then
  find . -maxdepth 1 -name "*.po"|while read po
  do
    echo Merging $po
    msgmerge --no-wrap -o $po.new $po qtranslate.pot
    if [ -f "$po.new" ]; then
      sed -r "s/\"Project-Id-Version: qTranslate-X \S+/\"Project-Id-Version: qTranslate-X $ver\\\\n\"/" $po.new >$po
      rm -f $po.new
    fi
  done
fi

if [ ! -z "$3" ]; then
  find . -maxdepth 1 -name "*.po"|while read po
  do
  mo=`basename $po .po`.mo
  echo Making $mo
  mv $mo $mo.org
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
exit

if [ ! -z "" ]; then
  find . -maxdepth 1 -name "*.po"|while read po
  do
  echo Updating $po
  if [ ! -f $po.fuzzy ]; then mv $po $po.fuzzy; fi
  sed "N;N;s/#, fuzzy.*\n#, fuzzy.*/#, fuzzy/" $po.fuzzy > $po
  # rm $po.fuzzy
  done
fi

if [ ! -z "" ]; then
  find . -maxdepth 1 -name "*.po"|while read po
  do
  if [ "$po" == './qtranslate-pt_PT.po' ]; then echo Skipping $po; continue; fi
  if [ "$po" == './qtranslate-sv_SE.po' ]; then echo Skipping $po; continue; fi
  echo Updating $po
  if [ ! -f $po.old ]; then cp -p $po $po.old; fi
  sed 's/msgid "General"/#, fuzzy\nmsgid "General"/' $po.old |sed 's/msgid "Advanced"/#, fuzzy\nmsgid "Advanced"/' |sed 's/msgid "Integration"/#, fuzzy\nmsgid "Integration"/' > $po
  # rm $po.old
  done
fi
exit

if [ ! -z "" ]; then
  find . -maxdepth 1 -name "*.po"|while read po
  do
  echo Updating $po
  mv $po $po.old
  sed 's/msgid "General Settings"/msgid "General"/' $po.old |sed 's/msgid "Advanced Settings"/msgid "Advanced"/' |sed 's/msgid "Custom Integration"/msgid "Integration"/' > $po
  rm $po.old
  done
fi
exit

find . -maxdepth 1 -name "*.mo"|while read mo
do
  po=`basename $mo .mo`.po
  #echo po: $po
  if [ -f "$po" ]; then continue; fi
  echo Creating $po
  msgunfmt --no-wrap $mo -o $po &>$po.err
  if [ -s "$po.err" ]; then
    mv $po $po.bad
  else
    rm $po.err
  fi
done


svn up ../../../mqtranslate/trunk

find . -maxdepth 1 -name "*.po"|while read po
do
  if [ -e "$po.err" ]; then
    echo Skipping $po since there is $po.err
    continue
  fi
  if [ ! -e "$po.org" ]; then
    cp -p $po $po.org
    cp -p $po.org $po.org-sorted
    msgmerge --no-wrap --sort-output --update $po.org-sorted $po.org
  fi
  if [ ! -e "$po.cur" ]; then
    cp -p $po $po.cur
    cp -p $po.org $po.cur-sorted
    msgmerge --no-wrap --sort-output --update $po.cur-sorted $po.cur
  fi
  mqpo=../../../mqtranslate/trunk/lang/m`basename $po`
  if [ -e "$mqpo" ]; then
   if [ ! -e $po.q -o $po.q -ot $mqpo ]; then
    echo Updating $po from mqTranslate
    sed 's/mqTranslate/qTranslate/g' $mqpo >$po.q
    cp -p $po.q $po.q-sorted
    msgmerge --no-wrap --sort-output --update $po.q-sorted $po.q
    msgmerge --no-wrap --update $po.q qtranslate.pot
    msgmerge --no-wrap --update $po $po.q
    cp -p $po $po.mq
    cp -p $po $po.mq-sorted
    msgmerge --no-wrap --sort-output --update $po.mq-sorted $po.mq
   fi
  else
    echo no mqTranslate file $mqpo
  fi
  
  echo Updating $po from qtranslate.pot
  mv $po $po.tmp
  sed "s/\"Project-Id-Version:.*\"/\"Project-Id-Version: qTranslate-X $ver\\\\n\"/g" $po.tmp >$po
  rm $po.tmp
  msgmerge --no-wrap --update $po qtranslate.pot
  cp -p $po $po-sorted
  msgmerge --no-wrap --sort-output --update $po-sorted $po

  continue; #do not auto-update .mo, only after human verification

  mo=`basename $po .po`.mo
  echo Making $mo
  mv $mo $mo.org
  msgfmt $po -o $mo &>$mo.err
  if [ -s "$mo.err" ]; then
    mv $mo $mo.bad
    mv $mo.org $mo
  else
    rm $mo.err
    rm $mo.org
  fi
done
exit

#code from mqTranslate
for lang in az_AZ bg_BG cs_CZ da_DK de_DE eo es_CA es_ES fr_FR hu_HU id_ID it_IT ja_JP mk_MK ms_MY nl_NL pl_PL pt_BR pt_PT ro_RO sr_RS sv_SE tr_TR zh_CN; do
    # Create empty files if the do not exist yet
    touch mqtranslate-$lang.po

    # Merge the .po files with the template
    msgmerge --update mqtranslate-$lang.po mqtranslate.pot

    # Convert all .po files into .mo
    pocompile mqtranslate-$lang.po mqtranslate-$lang.mo
done

