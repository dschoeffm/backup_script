#!/bin/bash

set -x


all_vars=$(zenity --forms \
 --add-entry="Directories to back up: (comma seperated)" \
 --add-entry="Full backups every x hours (7d=168h):" \
 --add-entry="Differential backups every x hours: " \
 --add-entry="FTP Server address: " \
 --add-entry="FTP User: " \
 --add-entry="FTP Directory: "\
 --add-password="FTP Password")

DIRS=$(echo $all_vars | cut -f 1 -d '|')
FULL_BACKUPS=$(echo $all_vars | cut -f 2 -d '|')
DIFF_BACKUPS=$(echo $all_vars | cut -f 3 -d '|')
FTP_SERVER=$(echo $all_vars | cut -f 4 -d '|')
FTP_USER=$(echo $all_vars | cut -f 5 -d '|')
FTP_DIR=$(echo $all_vars | cut -f 6 -d '|')
FTP_PW=$(echo $all_vars | cut -f 7 -d '|')

echo "DIRS=${DIRS}" >> ~/.backup_env
echo "FULL_BACKUPS=${FULL_BACKUPS}" >> ~/.backup_env
echo "DIFF_BACKUPS=${DIFF_BACKUPS}" >> ~/.backup_env
echo "FTP_SERVER=${FTP_SERVER}" >> ~/.backup_env
echo "FTP_USER=${FTP_USER}" >> ~/.backup_env
echo "FTP_DIR=${FTP_DIR}" >> ~/.backup_env
echo "FTP_PW=${FTP_PW}" >> ~/.backup_env
