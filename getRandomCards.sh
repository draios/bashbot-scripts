#!/bin/bash

if [ -z "$1" ]; then
  echo "Missing questions file"
  exit 1
fi
QUESTIONS_FILE="$1"

if [ -z "$2" ]; then
  echo "Missing answers file"
  exit 1
fi
ANSWERS_FILE="$2"

RANDOM_QUESTION=$(cat $QUESTIONS_FILE | shuf -n 1)
NUMBER_OF_ANSWERS=$(echo $RANDOM_QUESTION | grep -o "_" | wc -l | awk '{print $1}')
echo "Q ==> $RANDOM_QUESTION"

if [ "$NUMBER_OF_ANSWERS" -gt 1 ]; then
  counter=1
  while [ $counter -le "$NUMBER_OF_ANSWERS" ]; do
    echo "A ==> $(cat $ANSWERS_FILE | shuf -n 1)"
    ((counter++))
  done
else
  echo "A ==> $(cat $ANSWERS_FILE | shuf -n 1)"
fi