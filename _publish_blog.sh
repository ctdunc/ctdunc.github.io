mkdir _blog_intermediate/
cp _blog/**.html ./_blog_intermediate

for file in ./_blog/**.md; do
	mordant $file -c ./_mordant.toml > ./_blog_intermediate/$(basename $file)
	lowdown --template=./_template.html -s ./_blog_intermediate/$(basename $file) -thtml --html-no-skiphtml --html-no-escapehtml > ./blog/$(basename $file .md).html
done
rm -rf _blog_intermediate/
