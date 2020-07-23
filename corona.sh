#!/bin/bash
SORT_BY="county"
if [ -n "$1" ]; then
  if [[ $1 =~ ^county|infected|population|percentage$ ]]; then 
    SORT_BY="$1"
  fi
fi
SORT_ORDER="reverse"
if [ $SORT_BY = "county" ]; then
  SORT_ORDER="."
fi


# Get population of california by county (json)
POPULATION_URL=https://www.california-demographics.com/counties_by_population
POPULATION=$(curl -s $POPULATION_URL | tr '\n' ' ' | sed -e 's/\s\s*/ /g' | sed -e 's/.*th>//g' | sed -e 's/<td colspan.*//'g | sed -e 's/<tr>/\n/g' | sed -e 's/.*demographics">/"/g' | sed -e 's/<\/a.*<td>\ /":/g' | sed -e 's/\ <\/td.*//g' | sed -e 's/,//g' | sed -e 's/<\/tr>//g' | tr '\n' ',' | sed -e 's/^\s*,//g' | sed -e 's/,\s*$//g' | sed -e 's/\ County//g' | sed -e 's/\(.*\)/{\1}/g' | jq --slurp -c '.[]')


# Get total infection from yesterday
DATA_SOURCE=926fd08f-cc91-4828-af38-bd45de97f8c3
TARGET_DATE=$(date +"%Y-%m-%d" --date="-2 days")
TARGET_URL=https://data.ca.gov/api/3/action/datastore_search?resource_id=$DATA_SOURCE\&filters=%7B%22date%22:%22$TARGET_DATE%22%7D
data=$(curl -s $TARGET_URL  | jq -c '.result.records[]')
tmp_data=''
while IFS= read -r county; do
  this_totalcountconfirmed=$(echo $county | jq -r '.totalcountconfirmed')
  this_county=$(echo $county | jq -r '.county')
  if [[ -z $(echo "$POPULATION" | grep "$this_county") ]]; then
    continue
  fi
  this_population=$(echo "$POPULATION" | jq --raw-output '.["'"$this_county"'"]')
  printf -v this_tmp_percentage "%03d" $(($this_totalcountconfirmed*10000/$this_population))
  this_percentage=$(echo "$this_tmp_percentage" | sed -e 's/\(.\)\(.\)\(.\)/\1.\2\3\%/g' | sed -e 's/00\./0./g')
  tmp_data=',{"county":"'$this_county'","infected":'$this_totalcountconfirmed',"population":'$this_population',"percentage":"'$this_percentage'"}'$tmp_data
done <<< "$data"
better_data=$(echo "$tmp_data" | sed -e 's/^,//g' | sed -e 's/^\(.*\)$/[\1]/g' | jq -c '. | sort_by(.'$SORT_BY') | '$SORT_ORDER'[]')
echo "Californians coronavirus infected by county: $TARGET_DATE (sort: $SORT_BY)"
echo "╭─────────────────┬────────────┬─────────────┬──────────────╮"
echo "│     County      │  Infected  │  Population │   %Infected  │"
echo "├─────────────────┼────────────┼─────────────┼──────────────┤"
while IFS= read -r county; do
  this_county=$(echo $county | jq -r '.county')
  this_infected=$(echo $county | jq -r '.infected')
  this_population=$(echo $county | jq -r '.population')
  this_percentage=$(echo $county | jq -r '.percentage')
  printf "│ % 15s │ %10d │ %11d │ %12s │\n" "$this_county" $this_infected $this_population $this_percentage
done <<< "$better_data"
echo "╰─────────────────┴────────────┴─────────────┴──────────────╯"
