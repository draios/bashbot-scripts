#!/bin/bash

IFS='' read -r -d '' banner <<"EOF"
---------------------------------------------------------------
 _____               _        ___              _           _   
/  __ \             | |      / _ \            (_)         | |  
| /  \/ __ _ _ __ __| |___  / /_\ \ __ _  __ _ _ _ __  ___| |_ 
| |    / _` | '__/ _` / __| |  _  |/ _` |/ _` | | '_ \/ __| __|
| \__/\ (_| | | | (_| \__ \ | | | | (_| | (_| | | | | \__ \ |_ 
 \____/\__,_|_|  \__,_|___/ \_| |_/\__, |\__,_|_|_| |_|___/\__|
                                    __/ |                      
                                   |___/                       
        _   _                             _ _                  
       | | | |                           (_) |                 
       | |_| |_   _ _ __ ___   __ _ _ __  _| |_ _   _          
       |  _  | | | | '_ ` _ \ / _` | '_ \| | __| | | |         
       | | | | |_| | | | | | | (_| | | | | | |_| |_| |         
       \_| |_/\__,_|_| |_| |_|\__,_|_| |_|_|\__|\__, |         
                                                 __/ |         
                                                |___/          
---------------------------------------------------------------
EOF

IFS='' read -r -d '' help <<"EOF"
Usage: ./cardsAgasintHumanity.sh [arguments]
    --action               [random,question,answer]
    --questions-file       [path-to-questions-file]
    --answers-file         [path-to-answers-file]

EOF
help="$banner\n$help"

PROJECT_ROOT=$(pwd)

while [[ $# -gt 0 ]] && [[ "$1" == "--"* ]]; do
  opt="$1";
  shift;
  case "$opt" in
      "--" ) break 2;;
      "--action" )
         ACTION="$1"; shift;;
      "--questions-file" )
         QUESTIONS_FILE="$1"; shift;;
      "--answers-file" )
         ANSWERS_FILE="$1"; shift;;
      *) echo >&2 "Invalid option: $@"; exit 1;;
  esac
done


NUMBER_OF_ANSWERS=1
if [[ "$ACTION" != "answer" ]]; then
  [[ ! -f "$QUESTIONS_FILE" ]] && echo "questions file not found" && exit 1;
  RANDOM_QUESTION=$(cat $QUESTIONS_FILE | shuf -n 1)
  NUMBER_OF_ANSWERS=$(echo $RANDOM_QUESTION | grep -oE "__*\ " | wc -l | awk '{print $1}')
  echo "$RANDOM_QUESTION"
fi

if [[ "$ACTION" != "question" ]]; then
  [[ ! -f "$ANSWERS_FILE" ]] && echo "answers file not found" && exit 1;
  if [ "$NUMBER_OF_ANSWERS" -gt 1 ]; then
    counter=1
    while [ $counter -le "$NUMBER_OF_ANSWERS" ]; do
      echo "${counter}> $(cat $ANSWERS_FILE | shuf -n 1)"
      ((counter++))
    done
  else
    echo "> $(cat $ANSWERS_FILE | shuf -n 1)"
  fi
fi