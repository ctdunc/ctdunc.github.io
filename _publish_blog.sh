# make a temp directory for the mordant-ified md files.
mkdir _blog_intermediate/

for file in ./_blog/**.md; do
	mordant $file -c ./_mordant.toml > ./_blog_intermediate/$(basename $file)
	# we need the no skip/escape html options, since we want to use inline tags.
	lowdown --template=./_template.html \
	  -s ./_blog_intermediate/$(basename $file) \
	  -thtml \
	  --html-no-skiphtml \
	  --html-no-escapehtml > ./blog/$(basename $file .md).html
done
rm -rf _blog_intermediate/
