#!/bin/bash

## Var declarations
ASN=?
## Your telegram bot information
bot_key=?
chatid=?

# Files
file_base="new_prefixes.txt"
file_back="old_prefixes.txt"


## Defining time interval to check
interval_time=8
end_time=$(date -u +"%Y-%m-%dT%H:%M")
start_time=$(date -u -d "$interval hours ago" +"%Y-%m-%dT%H:%M")

## Obtaining information through RIPE
echo "[?] Checking prefixes AS$ASN..."

content_api=$(curl -s "https://stat.ripe.net/data/announced-prefixes/data.json?resource=AS$ASN&starttime=$start_time&endtime=$end_time")

## checking that there is content in the response
if [ -z "$content_api" ]
then
	echo "[-] There is no data in answer"
	exit 1
fi

## checking that there is errors in the response
response_state=$(echo "$content_api" | jq -r '.status')

if [ "$response_state" == "error" ]
then
	error_status=$(echo "$content_api" | jq -r '.status_code')
	error_msg=$(echo "$content_api" | jq -r '.messages[][]' 2>/dev/null)

	echo "[!] Error. Status: $error_status"
	echo "[!] Message: $error_msg"
	exit 1
fi

## extract prefixes from content response and save into file
prefixes_asn=$(echo "$content_api" | jq -r  '.data.prefixes[].prefix' | tr ' ' '\n' | sort )

echo "$prefixes_asn" > $file_base

echo "Prefixes obtained and saved in $file_base"

## conditional to compare files
if cmp -s "$file_base" "$file_back"; then
	# if there is no changes
	message="[=] There is no changes on prefixes announcements."
	echo $message
else
	# Changes detected
	# echo "[!] Changes detected"
	# Check difference with diff
	message=$(diff "$file_back" "$file_base" | grep -E '^[<>]' | sed 's/^< /[-] /;s/^> /[+] /')
	message_2="[!] Changes detected on prefixes announcements. $message"

	echo $message_2

	curl -s "https://api.telegram.org/$bot_key/sendMessage?chat_id=$chatid" --data-urlencode "text=$message_2"
	echo "[!] Notification sended"
	cp "$file_base" "$file_back"
fi
