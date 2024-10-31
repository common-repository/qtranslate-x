tag=$1
cd `dirname $0`/../../
pwd
if [ -z "$tag" ]; then
  tag=`grep "Version" trunk/qtranslate.php|awk '{print $2}'`
fi
if [ -z "$tag" ]; then
  echo "Usage: `basename $0` <tag>"
  exit;
fi
echo tag=$tag
if [ -e "tags/$tag" ]; then
  echo "Error: tags/$tag already exists"
  exit;
fi

if [ -h "trunk/admin/js/common.min.js" ]; then
  ./assets/dev/js2min.sh
fi

rm -f trunk/lang/*.cur
#./assets/dev/updateTranslations.sh "po"

svn cp trunk tags/$tag

rm -rf tags/$tag/lang/*.po*
rm -rf tags/$tag/lang/*.org
rm -rf tags/$tag/lang/*.bad
rm -rf tags/$tag/lang/*.cur
rm -rf tags/$tag/lang/*.err
rm -rf tags/$tag/lang/language-names/*.po*
rm -rf tags/$tag/lang/.tx
rm -rf tags/$tag/.git*
rm -rf tags/$tag/*.bak
rm -rf tags/$tag/*.md
rm -rf tags/$tag/dev
rm -rf tags/$tag/slugs
rm -rf tags/$tag/front
rm -rf tags/$tag/admin/css/opLSBStyle/NewStyle.css
rm -rf tags/$tag/i18n-config/themes/wpex-elegant
rm -f tags/$tag/qtranslate_services.php

echo "now run svn ci -m \"$tag release\""
exit

svn ci -m "$tag release"

