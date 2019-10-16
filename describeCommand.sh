#!/bin/bash

if [ -z $1 ]; then
  echo "Missing config file"
  exit 1
fi
CONFIG_FILE=$1

if [ -z $2 ]; then
  echo "Missing command to describe"
  exit 1
fi
TRIGGER=$2

if [ -f $CONFIG_FILE ]; then
  echo "$(cat $CONFIG_FILE | jq -r --arg TRIGGER "${TRIGGER}" '.tools[] | select(.trigger == $TRIGGER)')"
else
  echo "File not found..."
fi