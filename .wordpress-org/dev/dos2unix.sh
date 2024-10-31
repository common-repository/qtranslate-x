git status
find . -type f -name '*.php' -exec dos2unix {} \;
find . -type f -name '*.css' -exec dos2unix {} \;
find . -type f -name '*.po' -exec dos2unix {} \;
find . -type f -name '*.pot' -exec dos2unix {} \;
find . -type f -name '*.js' -exec dos2unix {} \;
find . -type f -name '*.json' -exec dos2unix {} \;
find . -type f -name '*.txt' -exec dos2unix {} \;
git status
