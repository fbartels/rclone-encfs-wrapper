#!/usr/bin/env bash

function finish {
	# unmount the encfs dir on exit
	mountpoint -q $DATAENCRYPTED && fusermount -u $DATAENCRYPTED && sleep 3
	rmdir $DATAENCRYPTED
}
trap finish INT TERM EXIT

if [ ! "$(which encfs)" ]; then
	echo "encfs is not installed"
	exit 1
fi
if [ ! "$(which rclone)" ]; then
	echo "rclone is not installed"
	echo "http://rclone.org/install/"
	exit 1
fi

if [ -e config ]; then
	source config
else
	echo "you have to create a config file first"
	exit 1
fi

export DATAENCRYPTED=$(mktemp -d)

create_encfs(){
	encfs --standard --reverse --extpass="cat $ENCFS_PASSWORD" $SOURCECLEARTEXT $DATAENCRYPTED

	# waiting for mount to settle
	sleep 3
	fusermount -u $DATAENCRYPTED

	echo "moving xml"
	mv $SOURCECLEARTEXT/.encfs6.xml $ENCFS_CONFIG
}

if [ ! -e $ENCFS_PASSWORD ]; then
	echo "generating encfs password"
	PASSWORD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 100 | head -n 1)
	echo $PASSWORD > $ENCFS_PASSWORD
fi

if [ ! -e $ENCFS_CONFIG ]; then
	echo "no encfs config xml found. Assuming new setup and creating new mount."
	create_encfs
fi

echo "mounting reverse encfs dir"
ENCFS6_CONFIG=$ENCFS_CONFIG encfs --reverse --extpass="cat $ENCFS_PASSWORD" $SOURCECLEARTEXT $DATAENCRYPTED

rclone mkdir "$RCLONE_REMOTE":/"$RCLONE_PATH"
if [ $? -ne 0 ]; then
	echo "Could not check the remote path. Did you configure the correct 'remote' in rclone?"
	exit 1
fi

# TODO implement exclude list
#EXCLUDES="test.sql text.sql"
#EXCLUDES_ENCRYPTED=$(ENCFS6_CONFIG=$ENCFS_CONFIG encfsctl encode --extpass="cat $ENCFS_PASSWORD" $SOURCECLEARTEXT $EXCLUDES)

rclone --verbose --transfers=1 copy $DATAENCRYPTED "$RCLONE_REMOTE":/"$RCLONE_PATH"
