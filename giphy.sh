#!/bin/bash

if [ -z "$GIPHY_API_KEY" ]; then
  echo "Missing GIPHY_API_KEY environment variable."
  exit 1
fi

if [ -z $1 ]; then
  echo "Missing query string"
  exit 1
fi
QUERY_STRING=$1

if [ -z $2 ]; then
  curl -s "http://api.giphy.com/v1/gifs/search?q=$QUERY_STRING&limit=1&api_key=$GIPHY_API_KEY" | jq -r '.data[0].images.original.url'
else
  RANDOMNESS=$2
  curl -s "http://api.giphy.com/v1/gifs/search?q=$QUERY_STRING&limit=$RANDOMNESS&api_key=$GIPHY_API_KEY" | jq -r '.data['$(((RANDOM%$RANDOMNESS)))'].images.original.url'
fi
