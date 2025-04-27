# make a temp directory for the mordant-ified md files.
#
rm -f -rf -- ./_site/
mkdir ./_site
mkdir _tmp_mordant/
for file in $(find ./site -name *.md); do
	base_name=$(basename $file .md)
	site_path=$(dirname $file | sed 's/^\.\/site//')
	mkdir -p "./_tmp_mordant$site_path"
	mkdir -p "./_site/$site_path"
	mordant $file -c ./mordant.toml > "./_tmp_mordant/$site_path/$base_name.md"
    #we need the no skip/escape html options, since we want to use inline tags.
	lowdown --template=./template.html \
	  -s "./_tmp_mordant/$site_path/$base_name.md" \
	  -thtml \
	  --html-no-skiphtml \
	  --html-no-escapehtml > "./_site/$site_path/$base_name.html"
done
rm -rf _tmp_mordant/

cp -r static/ ./_site/
