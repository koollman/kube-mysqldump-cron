#!/bin/bash

set -e
set -o pipefail

AWS_BUCKET=${AWS_BUCKET:-${MYSQL_ENV_AWS_BUCKET}}
AWS_BUCKET_PREFIX=${AWS_BUCKET_PREFIX:-${MYSQL_ENV_AWS_BUCKET_PREFIX}}
DB_USER=${DB_USER:-${MYSQL_ENV_DB_USER}}
DB_PASS=${DB_PASS:-${MYSQL_ENV_DB_PASS}}
DB_NAME=${DB_NAME:-${MYSQL_ENV_DB_NAME}}
DB_HOST=${DB_HOST:-${MYSQL_ENV_DB_HOST}}
ALL_DATABASES=${ALL_DATABASES}
IGNORE_DATABASE=${IGNORE_DATABASE}


if [ "${AWS_BUCKET}" == "" ]; then
  echo "Missing AWS_BUCKET env variable"
  exit 1
fi

if [ "${AWS_BUCKET_PREFIX}" == "" ]; then
  echo "Missing AWS_BUCKET_PREFIX env variable"
  exit 1
fi

if [[ ${DB_USER} == "" ]]; then
	echo "Missing DB_USER env variable"
	exit 1
fi
if [[ ${DB_PASS} == "" ]]; then
	echo "Missing DB_PASS env variable"
	exit 1
fi
if [[ ${DB_HOST} == "" ]]; then
	echo "Missing DB_HOST env variable"
	exit 1
fi

if [[ ${ALL_DATABASES} == "" ]]; then
	if [[ ${DB_NAME} == "" ]]; then
		echo "Missing DB_NAME env variable"
		exit 1
	fi
	mysqldump --user="${DB_USER}" --password="${DB_PASS}" --host="${DB_HOST}" "$@" "${DB_NAME}" | gzip | aws s3 cp - s3://$AWS_BUCKET/$AWS_BUCKET_PREFIX/$(date +"%Y")/$(date +"%m")/$(date +"%d")/"${DB_NAME}".sql.gz
else
	databases=`mysql --user="${DB_USER}" --password="${DB_PASS}" --host="${DB_HOST}" -e "SHOW DATABASES;" | tr -d "| " | grep -v Database`
for db in $databases; do
    if [[ "$db" != "information_schema" ]] && [[ "$db" != "performance_schema" ]] && [[ "$db" != "mysql" ]] && [[ "$db" != _* ]] && [[ "$db" != "$IGNORE_DATABASE" ]]; then
        echo "Dumping database: $db"
        mysqldump --user="${DB_USER}" --password="${DB_PASS}" --host="${DB_HOST}" --databases $db | gzip | aws s3 cp - s3://$AWS_BUCKET/$AWS_BUCKET_PREFIX/$(date +"%Y")/$(date +"%m")/$(date +"%d")/$db.sql.gz
    fi
done
fi