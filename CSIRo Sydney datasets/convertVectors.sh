#!/bin/bash

rm maps/*.sqlite

if [ -z $1 ]
	then
	echo "must have epsg as argument"
	exit
fi



for file in $(find . -name "*.shp")
do
	filename=$(echo $file|gawk  'BEGIN {FS="[./]"} {print $3}')
	ext=$(echo $file|gawk  'BEGIN {FS="[./]"} {print $4}')
	echo $filename . $ext
	echo $1 $2

	foo=""

	if [ -n $2 ]
		then
		foo="-s_srs EPSG:"$2
	fi

	rm -rf /tmp/$filename
	ogr2ogr $foo -t_srs EPSG:$1 /tmp/$filename $file

	spatialite_tool -i -shp /tmp/$filename/$filename -d maps/vectors.sqlite -t $filename -g Geometry -c utf-8 -s $1

	sqlite3 maps/vectors.sqlite "select createSpatialIndex('"$filename"', 'Geometry');"

done


