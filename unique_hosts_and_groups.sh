#! /bin/bash

# Script will scrape the total hosts of an AAP Instance
# Returns the number of all hosts and unique hosts.

# How to use this script:
# Either populate the environment variable:
# export AAP_URL=https://aap-mgt01.th-mgt.local, export AAP_USER=admin, export AAP_PASSWORD=secret123, export AAP_PAGE_SIZE=100
# Or script wants to interactively ask for the values.
# AAP_URL with protocol and no extra character at the end, like in the example
# AAP_PAGE_SIZE allows an value from 1 to 100

if [[ ! -v AAP_URL ]]; then
    echo "Environment variable AAP_URL is not set. Please set it now. Ex: https://aap-mgt01.th-mgt.local"
    read -r aap_url
else
    aap_url=$AAP_URL
fi

if [[ ! -v AAP_USER ]]; then
    echo "Environment variable AAP_USER is not set. Please set it now. Ex: admin"
    read -r aap_user
else
    aap_user=$AAP_USER
fi

if [[ ! -v AAP_PASSWORD ]]; then
    echo "Environment variable AAP_PASSWORD is not set. Please set it now. Ex: secret123"
    read -r aap_password
else
    aap_password=$AAP_PASSWORD
fi

if [[ ! -v AAP_PAGE_SIZE ]]; then
    echo "Environment variable AAP_PAGE_SIZE is not set. Please set it now. Ex: 100"
    read -r aap_page_size
else
    aap_page_size=$AAP_PAGE_SIZE
fi

page_count=1

JSON_RESULT=$(curl -ks -u "$aap_user:$aap_password" "$aap_url/api/controller/v2/hosts/?page_size=$aap_page_size&page=$page_count")

echo "$JSON_RESULT"| jq .results[] | jq -j '.id, " ", .name, " ", .inventory, "\n"' > "/tmp/content$page_count.txt";
echo Scraping Page: $page_count...

while [ -n "$page_count" ]; do
    if echo "$JSON_RESULT" | jq --exit-status '.next' >/dev/null; then 
    page_count=$((page_count + 1))
    echo Scraping Page: $page_count...
    JSON_RESULT=$(curl -ks -u "$aap_user:$aap_password" "$aap_url/api/controller/v2/hosts/?page_size=$aap_page_size&page=$page_count")
    echo "$JSON_RESULT"| jq .results[] | jq -j '.id, " ", .name, " ", .inventory, "\n"' > "/tmp/content$page_count.txt";
    else
    unset page_count
    fi
done

cat /tmp/content*.txt > /tmp/out.txt
rm -f /tmp/content*.txt

echo ""
echo ""
echo Total Hosts: "$(cat /tmp/out.txt | sort | wc -l)"
echo Unique Hosts: "$(cat /tmp/out.txt | sort | uniq | wc -l)"
rm -f /tmp/out.txt

file="out.txt"
while IFS= read -r line
do
    HOST_ID=$(echo "$line" | awk '{ print $1 }')
    HOST_NAME=$(echo "$line" | awk '{ print $2 }') 
    INVENTORY_ID=$(echo "$line" | awk '{ print $3 }')
    echo $HOST_NAME
    curl -ks -u "$aap_user:$aap_password" "$aap_url/api/controller/v2/inventories/$INVENTORY_ID/variable_data";
    curl -ks -u "$aap_user:$aap_password" "$aap_url/api/controller/v2/hosts/$HOST_ID/variable_data"
    for i in $(curl -ks -u "$aap_user:$aap_password" $aap_url/api/controller/v2/hosts/$HOST_ID/all_groups | jq .results[].id); do curl -ks -u "$aap_user:$aap_password" $aap_url/api/controller/v2/groups/$i/variable_data;done
    echo ""

done <"$file"