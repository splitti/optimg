#!/bin/bash

# Optimize and compress images, create webp-image.

# Prerequirements:
# Install the packeges jpegoptim, optipng and cwebp.
# For example in debian: 
#     apt update && apt install jpegoptim optipng cwebp

# Global working Parameter
WD="/usr/local/optimg/"
WDLOGS="${WD}logs/"
SIKTIME=`date +"%Y-%m-%d_%H%M%S"`
LOG="${WDLOGS}${SIKTIME}.log"

optimize () {
        IFS=$'\n'
        JPGFILES=`find $1 -iname *.jp*g -type f -mtime -1`
        PNGFILES=`find $1 -iname *.png -type f -mtime -1`

        echo -e ">>> Optimiere JPEG <<<" >> ${LOG}
        for jpgfile in ${JPGFILES}
        do
                jpegoptim -m $4 -o --strip-all --all-progressive ${jpgfile} >> ${LOG}
                chmod 755 ${jpgfile} >> ${LOG}
                chown $2:$3 ${jpgfile} >> ${LOG}
                if [ -f "${jpgfile}.webp" ]; then
                   echo "WEBP for $jpgfile exists." >> ${LOG}
                else
                   # convert the image using cwebp and output a file with the extension replaced as .webp
                   cwebp -q $6 "$jpgfile" -o "${jpgfile}.webp" >> ${LOG}
				   chmod 755 ${jpgfile}.webp >> ${LOG}
                   chown $2:$3 ${jpgfile}.webp >> ${LOG}
                fi
                touch -d "48 hours ago" ${jpgfile} >> ${LOG}
        done

        echo -e ">>> Optimiere PNG <<<" >> ${LOG}
        for pngfile in ${PNGFILES}
        do
                optipng -v -o $5 -strip all ${pngfile} >> ${LOG}
                chmod 755 ${pngfile} >> ${LOG}
                chown $2:$3 ${pngfile} >> ${LOG}
                if [ -f "${pngfile}.webp" ]; then
                   echo "WEBP for $pngfile exists." >> ${LOG}
                else
                   # convert the image using cwebp and output a file with the extension replaced as .webp
                   cwebp -q $6 "$pngfile" -o "${pngfile}.webp" >> ${LOG}
				   chmod 755 ${pngfile}.webp >> ${LOG}
                   chown $2:$3 ${pngfile}.webp >> ${LOG}
                fi
                touch -d "48 hours ago" ${pngfile} >> ${LOG}
        done
}

WD="/usr/local/optimg"

cd ${WD}

echo -e "Start:" `date +"%Y-%m-%dr %H:%M:%S"` >> ${LOG}

# Site informations
echo -e "------------------------" >> ${LOG}
echo -e "- anydomain.de         -" >> ${LOG}
echo -e "------------------------" >> ${LOG}
IMGDIR="/var/www/anydomain.de/web/wp-content/uploads/"
USER="web1"
GROUP="client1"
# JPEG Quality in percent
JPEG_QUALITY="80"
# The  optimization  levels  2  and  higher  enable multiple IDAT compression trials; 
# the higher the level, the more trials. 7 is the max level and slow. 
PNG_QUALITY="7" 
# WEBP Quality in percent
WEBP_QUALITY="80"


optimize ${IMGDIR} ${USER} ${GROUP} ${JPEG_QUALITY} ${PNG_QUALITY} ${WEBP_QUALITY}
