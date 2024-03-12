#!/bin/bash

# To use this script without human interaction it is necessary to define environmental variables
# for the tenant name as well as an API token, otherwise this script will ask for them

# Check and if necessary take in the required information to query the API
if [[ -z "${TENANT}" ]]; then
    echo "What is your tenant subdomain? Ex. [MY-ORGANIZATION].console.ves.volterra.io " \
    & read TENANT
fi

URL=https://$TENANT.console.ves.volterra.io/api/web/namespaces

echo $URL

if [[ -z "${APITOKEN}" ]]; then
    echo "You do not have an API Token defined as an environment variable. Please provide the API Token from the F5 Distributed Cloud Console. See https://docs.cloud.f5.com/docs-v2/administration/how-tos/user-mgmt/Credentials for more information. " \
    & read APITOKEN
fi

touch namespaces.json

echo "Querying the F5 Distributed Cloud API for the necessary information, this can take some time depending on the number of configuration objects, please wait... "

curl -s --location "$URL" --header "Authorization: APIToken $APITOKEN" > namespaces.json

# Use jq to parse the namespaces.JSON file and store them in the name_values variable
json=$(cat namespaces.json)
name_values=$(echo "$json" | jq -r '.items[].name')

# Create an empty array to store the substrings
declare -a substrings

# Use a for loop to iterate through each string in names_array, and store the substring in substrings array
for name in ${name_values[@]}; do
  # Define the desired substring pattern and use bash parameter expansion to extract it from the current name string
  substring=${name}
  # Add the extracted substring to the substrings array
  substrings+=($substring)
done

# Uncomment below to print the contents of the substrings array to screen for testing

#i=0
#for i in "${!substrings[@]}"; do
#  echo "Index: ${i}, Value: ${substrings[$i]}"
#done

# Now to iterate through each namespace to generate a list of http-LB configs

declare -a namespace_urls


base_uri="https://$TENANT.console.ves.volterra.io/api/config/namespaces/"
suffix_uri=/http_loadbalancers
for index in ${!substrings[@]}; do
  #substring=${substrings[$index]}
  namespace_uri_segment="${substrings[$index]}" 
  #echo $namespace_uri_segment
  final_uri="${base_uri}${namespace_uri_segment}${suffix_uri}"
  curl -s --location "$final_uri" --header "Authorization: APIToken $APITOKEN" >> lb-config.json
done

jq -r '.items[] | select((.name | length) > 0 and (.labels | length) > 0) | {name, labels}' < lb-config.json > api-spec-present.json




# housekeeping
rm namespaces.json lb-config.json

### What remains is to convert the api-spec-present.json file into a api-validation-report.csv file for general consumption
