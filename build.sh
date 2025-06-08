rm -f -rf -- ./_site/
mkdir ./_site

cd site
mordant -c ../mordant.toml --output-dir ../_tmp_mordant ./**/*.md ./*.md
cd ..

for file in $(find ./_tmp_mordant -name *.md); do
	base_name=$(basename $file .md)
	site_path=$(dirname $file | sed 's/\.\/_tmp_mordant//')
	mkdir -p "./_site/$site_path"
	lowdown --template=./template.html \
	  -s "./_tmp_mordant/$site_path/$base_name.md" \
	  -thtml \
	  --html-no-skiphtml \
	  --html-no-escapehtml > "./_site/$site_path/$base_name.html"
done

cp -r static/ ./_site/
rm -rf _tmp_mordant/
