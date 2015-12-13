#/usr/bin/bash

mkdir build -p

if [ ! -d src ]; then
	git clone https://github.com/open-xml-templating/docxtemplater-image-module.git src
else
	cd src
	git pull
	cd ..
fi

cd src

for tag in $(git tag)
do
	cd ..
	filename="$(pwd)""/build/docxtemplater-image-module.""$tag"".js"
	minfilename="$(pwd)""/build/docxtemplater-image-module.""$tag"".min.js"
	cd src
	# Skipping Already existing versions
	if [ -f "$filename" ] && [ -f "$minfilename" ]; then echo "Skipping $tag (file exists)" && continue; fi
	echo "processing $tag"
	git checkout "$tag"
	npm install
	gulp allCoffee
	npm test
	result=$?
	cd ..
	if [ "$result" == "0" ]; then
		browserify -r ./src/js/index.js -s ImageModule > "$filename"
		uglifyjs "$filename" > "$minfilename"
	fi
	cd src
done

cd ..

# Copy latest tag to docxtemplater-image-module-latest.{min,}.js
cp "$filename" build/docxtemplater-image-module-latest.js
cp "$minfilename" build/docxtemplater-image-module-latest.min.js