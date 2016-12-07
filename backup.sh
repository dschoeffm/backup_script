#!/bin/bash
check_time=1480148880

set -x

BACKUP_TMP=${HOME}/.backup_tmp
SUFFIX=

recursivterm() {
	local top=$(pwd)
	for d in *
	do
		# If directory -> enter recursively
		if [ -d "$d" ]
		then
			cd "$d"
			recursivterm
			cd $top
		fi

		# If regular file -> check for mod time
		if [ -f "$d" ]
		then
			time=$(ls -l --time-style=+%s $d)
			time=$(echo $time | perl -ne'/\S+ \S+ \S+ \S+ \S+ (\S+)/ && print($1)')

			if [ "$time" -gt "$check_time" ]
			then
				# `pwd` has leading /
				mkdir -p ${BACKUP_TMP}/data`pwd`
				cp $d ${BACKUP_TMP}/data`pwd`/$d
			fi
		fi

	done
}

diff_backup() {
	top=$(pwd)
	for var in $(echo $DIRS | sed "s/,/ /g")
	do
		if [ -e $var ]
		then
			cd $var
			recursivterm
			cd $top
		fi
	done
}

full_backup() {
	for var in $(echo $DIRS | sed "s/,/ /g")
	do
		if [ -e $var ]
		then
			cp -a $var ${BACKUP_TMP}/data
		fi
	done
}

. ~/.backup_env
. ~/.backup_last

if [ -z "$LAST_FULL" ]
then
	LAST_FULL=0
fi
if [ -z "$LAST_DIFF" ]
then
	LAST_DIFF=0
fi

NOW=$(date +%s)
$FULL_BACKUPS_SEC=$(echo "$FULL_BACKUPS * 60" | bc --)
$DIFF_BACKUPS_SEC=$(echo "$DIFF_BACKUPS * 60" | bc --)

if [ $(($LAST_FULL+$FULL_BACKUPS_SEC)) > $NOW ]
then
	$LAST_DIFF=$NOW
	$LAST_FULL=$NOW
	SUFFIX=full
	full_backup
elif [ $(($LAST_DIFF+$DIFF_BACKUPS_SEC)) > $NOW ]
	$LAST_DIFF=$NOW
	SUFFIX=diff
	diff_backup
else
	exit 0
fi

echo "LAST_FULL=${LAST_FULL}" > ~/.backup_last
echo "LAST_DIFF=${LAST_DIFF}" >> ~/.backup_last

TAR_FILE=${BACKUP_TMP}/`date +%Y-%m-%d`-${SUFFIX}.tar
tar -cf ${TAR_FILE} ${BACKUP_TMP}/data
gzip ${TAR_FILE}
sha1sum ${TAR_FILE}.gz > ${TAR_FILE}.gz.sha1sum

# Upload files to the FTP Server
ftp -n -v $FTP_SERVER << EOT
ascii
user $FTP_USER $FTP_PW
prompt
cd $FTP_DIR
put ${TAR_FILE}.gz
put ${TAR_FILE}.gz.sha1sum
bye
EOT
