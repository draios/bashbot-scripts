# bashbot-scripts

This repo is to hold generic, sharable scripts that can be used in bashbot.

### describeCommand.sh
```
# ./describeCommand.sh [config-file-location] [command]

./describeCommand.sh ../../config.json help

# Sample Output:
# {
#   "name": "BashBot Help",
#   "description": "Show this message",
#   "help": "bashbot help",
#   "trigger": "help",
#   "location": "./",
#   "setup": "echo \"BashBot is a white-listed command injection tool for slack... written in go. Add this bot to the channel that you wish to carry out commands, and type \\`bashbot help\\` to see this message.\nRun \\`bashbot <command> help\\` to see whitelist of parameters.\nPossible \\`<commands>\\`:\"",
#   "command": "echo \"\\`\\`\\`\" && cat config.json | jq -r -c '.tools[] | \"\\(.help) - \\(.description)\"' && echo \"\\`\\`\\`\"",
#   "parameters": [],
#   "log": false,
#   "ephemeral": false,
#   "response": "text",
#   "permissions": [
#     "all"
#   ]
# }

```


### getBasicInfo.sh
```
# Assumes env vars are set:
# TRIGGERED_USER_NAME, TRIGGERED_USER_ID,
# TRIGGERED_CHANNEL_NAME, TRIGGERED_CHANNEL_ID

./getBasicInfo.sh

# Note: user/channel ids come from env vars bashbot sets each command
# Sample Output:
#        Date: Tue Oct  8 08:15:30 PDT 2019
#      uptime:  8:15  up 6 days, 16:34, 13 users, load averages: 2.27 1.89 1.81
#    User[id]: []
# Channel[id]: []
```

### getRandomCards.sh
```
# Assumes two text files. One of questions, and another of answers:

./getRandomCards.sh ../against-humanity/questions.txt ../against-humanity/answers.txt

# Q ==> Tonights main event, _ vs. _.
# A ==> Explosive decompression.
# A ==> The chronic.
```


### giphy.sh
```
# Assumes GIPHY_API_KEY env var is set
# no spaces in search query. separate with plus symbol.
# randomness int[1-100]
# ./giphy.sh [search-query] [1-100]

./giphy.sh slap-trout 10
# Sample Output:
# https://media0.giphy.com/media/[REDACTED]
```

