#!/bin/bash

IFS='' read -r -d '' banner <<"EOF"
---------------------------------------------------------------
banner 
---------------------------------------------------------------
EOF

IFS='' read -r -d '' help <<"EOF"
Usage: ./slackApi.sh [arguments]
    --slack-base     [slack-api-base-url]
    --slack-token    [slack-api-key]
    --endpoint       [slack-endpoint]

EOF
help="$banner\n$help"
PROJECT_ROOT=$(pwd)
[ ! -f "$PROJECT_ROOT/slackApiFunctions.sh" ] && echo "Missing slackApiFunctions.sh file" && exit 1
source "$PROJECT_ROOT/slackApiFunctions.sh"

VERBOSE=0
SLACK_API_BASE=https://slack.com/api
OUTPUT=raw

while [[ $# -gt 0 ]] && [[ "$1" == "--"* ]]; do
  opt="$1";
  shift;
  case "$opt" in
      "--" ) break 2;;
      "--slack-base" )
         SLACK_API_BASE="$1"; shift;;
      "--slack-token" )
         SLACK_TOKEN="$1"; shift;;
      "--endpoint" )
         ENDPOINT="$1"; shift;;
      "--output" )
         OUTPUT="$1"; shift;;
      "--user-id" )
         USER_ID="$1"; shift;;
      "--verbose" )
         VERBOSE=1
         ;;
      *) echo >&2 "Invalid option: $@"; exit 1;;
  esac
done


[ -z "$SLACK_TOKEN" ] && echo "must define/export slack token" && exit 1
[ -z "$SLACK_API_BASE" ] && echo "must define slack base url" && exit 1
[ -z "$ENDPOINT" ] && echo "must define endpoint" && exit 1

case "$ENDPOINT" in
  "users.list" )
    slack_users_list $SLACK_API_BASE $SLACK_TOKEN $ENDPOINT $VERBOSE $OUTPUT
    ;;
  "users.info" )
    slack_users_info $SLACK_API_BASE $SLACK_TOKEN $ENDPOINT $USER_ID $VERBOSE $OUTPUT
    ;;
  *) echo >&2 "endpoint not found: $@"; exit 1;;
esac


