#!/bin/bash
set -e

rm -f /tmp/*.tif

mkdir -p maps


if [ -z $1 ]
	then
	echo "must have epsg as argument"
	exit
fi

for file in $(find . -name "*.tif")
do
	
	filename=$(echo $file|gawk  'BEGIN {FS="[./]"} {print $3}')
	ext=$(echo $file|gawk  'BEGIN {FS="[./]"} {print $4}')
	echo $filename.$ext
	echo $1 $2

	rm -f maps/$filename.$1.Tiled.tif

	if [ -n $2 ]
		then
		echo "foo"
		echo "source: " $2
		if [ "$1" -eq "$2" ]
			then
				echo "same"
				gdal_translate $file /tmp/$filename.$1.tif
			else		
				echo "warping "	$1 " to " $2
				gdal_translate $file /tmp/$filename.tif
				gdalwarp -s_srs EPSG:$2 -t_srs EPSG:$1 /tmp/$filename.tif /tmp/$filename.$1.tif
		fi
	else
		gdal_translate $file /tmp/$filename.$1.tif

		gdalwarp -t_srs $1 /tmp/$filename.tif /tmp/$filename.$1.tif
	fi

	gdalwarp -co TILED=YES /tmp/$filename.$1.tif maps/$filename.$1.Tiled.tif
	gdaladdo -r nearest maps/$filename.$1.Tiled.tif 2 4 8 16 32 64 128 256 512 1024
done

./convertVectors.sh $1 $2
