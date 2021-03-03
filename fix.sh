#!/bin/sh
[ -e "$1" ] || echo "File '$1' not found"
[ -e "$1" ] || exit 42
# input and output can't be the same
newfile="$2"
if [ -z "${newfile}" ];then
    newfile=$(basename "$1" .gb).padded.gb
fi
newfile2="$(basename "${newfile}" .gb).fixedheader.gb"
# pad the file fully with 0xFF
dd if=/dev/zero ibs=1 count=336 | tr "\000" "\377" > "${newfile}.tmp"
# overwrite with ROM
dd if="$1" of="${newfile}.tmp" conv=notrunc
cp "${newfile}.tmp" "${newfile2}.tmp"
# fix logo and header
#rgbfix -p 0xFF -f lh "${newfile}.tmp"
# disables gbc - not possible
rgbfix -p 0xFF -f lh -c "${newfile2}.tmp"
# rgbfix grew it, shrink it again
#dd if="${newfile}.tmp" of="${newfile}" bs=1 count=336
cp "${newfile}.tmp" "${newfile}"
#dd if="${newfile2}.tmp" of="${newfile2}" bs=1 count=336
cp "${newfile2}.tmp" "${newfile2}"
# dd if="/dev/random" of="${file}" bs=1 count=80 seek=$((256-80)) conv=notrunc

echo "Fixed file stored in '${newfile}'"
echo "Fixed file stored in '${newfile2}'"