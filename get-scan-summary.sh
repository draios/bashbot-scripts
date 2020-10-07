#!/bin/bash

# usage example: ./get-scan-summary.sh quay.io/sysdig/cassandra:2.1.21.16
urlencode() {
    # urlencode <string>
    old_lc_collate=$LC_COLLATE
    LC_COLLATE=C
    local length="${#1}"
    for (( i = 0; i < length; i++ )); do
        local c="${1:$i:1}"
        case $c in
            [a-zA-Z0-9.~_-]) printf '%s' "$c" ;;
            *) printf '%%%02X' "'$c" ;;
        esac
    done
    LC_COLLATE=$old_lc_collate
}

urldecode() {
    # urldecode <string>
    local url_encoded="${1//+/ }"
    printf '%b' "${url_encoded//%/\\x}"
}
listify() {
  echo "$1" | grep $2 | awk '{print $1}' | sort | uniq | sed -e 's/^\(.*\)$/"\1"/g' | tr '\n' ',' | sed -e 's/,$//g'
}
listCount() {
  tmp=$(echo "$1" | grep $2 | awk '{print $1}' | sort | uniq | sed '/^$/d' | wc -l)
  pad="     "
  echo "$(printf "%s %s" "$tmp" "${pad:${#tmp}}")"
}
if [[ -z "$SDC_URL" ]]; then
  echo "Missing SDC_URL env var"
  exit 1
fi
if [[ -z "$SDC_SECURE_TOKEN" ]]; then
  echo "Missing SDC_SECURE_TOKEN env var"
  exit 1
fi
if [[ -z "$1" ]]; then
  echo "Must pass container url as first argument"
  exit 1
fi
outputas="$2"
if [[ -z "$2" ]]; then
  outputas=slack
fi
# Does container scan already exist? 
if [[ -n "$(sdc-cli scanning image list | awk '{print $1}' | grep -E '^'"$1"'$')" ]]; then
  # Were there any vulnerabilities?
  vulnsCount=$(sdc-cli scanning image vuln $1 | awk '{print $1}' | tail +2 | sort | uniq | wc -l)
  encodedContainerSource=$(urlencode $1)
  evaluation=$(sdc-cli scanning image evaluation $1)
  sha=$(echo "$evaluation" | grep imageDigest | awk '{print $2}')
  containerPassFail=$(echo "$evaluation" | grep status | awk '{print $2}')
  reportUrl=$(echo "$SDC_URL/secure/#/scanning/scan-results/$encodedContainerSource/$sha/summaries")
  if [[ -n "$(echo $containerPassFail | grep pass)" ]]; then
    passFail="<$reportUrl|:white_check_mark: PASSED - $1 (report)>"
  else
    passFail="<$reportUrl|:octagonal_sign: FAILED - $1 (report)>"
  fi
  asof=$(echo "$evaluation" | grep last_evaluation | awk '{print $2}')
  vulnsOS=$(sdc-cli scanning image vuln $1 os | tail +2)
  vulnsNonOS=$(sdc-cli scanning image vuln $1 non-os | tail +2)
  if [[ "$outputas" == "json" ]]; then
    echo '{"name":"'$1'","sha":"'$sha'","status":"'$containerPassFail'","asOf":"'$asof'","url":"'$reportUrl'","os_vulnerabilities":{"Critical":['$(listify "$vulnsOS" Critical)'],"High":['$(listify "$vulnsOS" High)'],"Medium":['$(listify "$vulnsOS" Medium)'],"Low":['$(listify "$vulnsOS" Low)'],"Negligible":['$(listify "$vulnsOS" Negligible)'],"Unknown":['$(listify "$vulnsOS" Unknown)']},"non_os_vulnerabilities":{"Critical":['$(listify "$vulnsNonOS" Critical)'],"High":['$(listify "$vulnsNonOS" High)'],"Medium":['$(listify "$vulnsNonOS" Medium)'],"Low":['$(listify "$vulnsNonOS" Low)'],"Negligible":['$(listify "$vulnsNonOS" Negligible)'],"Unknown":['$(listify "$vulnsNonOS" Unknown)']}}'
  else
    if [[ "$outputas" == "slack" ]]; then
        echo "$passFail"
        echo "\`\`\`"
        echo "$1"
    else
        echo "$reportUrl"
        echo "$containerPassFail - $1"
    fi
    echo "$vulnsCount vulnerabilities as of $asof"
    # if [ $vulnsCount -gt 0 ]; then
      echo "╭────────────┬────────┬────────╮"
      echo "│ Severity   │ OS     │ Non-OS │"
      echo "├────────────┼────────┼────────┤"
      echo '│ Critical   │ '"$(listCount "$vulnsOS" Critical)"' │ '"$(listCount "$vulnsNonOS" Critical)"' │'
      echo '│ High       │ '"$(listCount "$vulnsOS" High)"' │ '"$(listCount "$vulnsNonOS" High)"' │'
      echo '│ Medium     │ '"$(listCount "$vulnsOS" Medium)"' │ '"$(listCount "$vulnsNonOS" Medium)"' │'
      echo '│ Low        │ '"$(listCount "$vulnsOS" Low)"' │ '"$(listCount "$vulnsNonOS" Low)"' │'
      echo '│ Negligible │ '"$(listCount "$vulnsOS" Negligible)"' │ '"$(listCount "$vulnsNonOS" Negligible)"' │'
      echo '│ Unknown    │ '"$(listCount "$vulnsOS" Unknown)"' │ '"$(listCount "$vulnsNonOS" Unknown)"' │'
      echo "╰────────────┴────────┴────────╯"
    # fi
    if [[ "$outputas" == "slack" ]]; then
        echo "\`\`\`"
    fi
  fi
else
  echo "This container was not found in $SDC_URL"
fi
