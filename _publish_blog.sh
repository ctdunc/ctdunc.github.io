mkdir _blog_intermediate/
cp _blog/**.html ./_blog_intermediate

for file in ./_blog/**.md; do
	echo $file
	mordant --file $file -c ./_mordant.toml > ./_blog_intermediate/$(basename $file)
done
ls _blog_intermediate
ssg _blog_intermediate/ blog/ "Connor Duncan\'s Blog" 'https://www.connorduncan.xyz/blog/'
rm -rf _blog_intermediate/
