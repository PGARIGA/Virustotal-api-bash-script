#!/bin/bash

# Set up the variables
API_KEY="YOUR_API_KEY"

# Prompt the user for the TXT file containing IP addresses
read -p "Enter the path to the TXT file containing IP addresses: " TXT_FILE

# Check if the TXT file exists
if [[ ! -f "$TXT_FILE" ]]; then
  echo "Error: File not found."
  exit 1
fi

# Read IP addresses from the TXT file
IP_ADDRESSES=()
while IFS= read -r ip_address || [[ -n "$ip_address" ]]; do
  IP_ADDRESSES+=("$ip_address")
done < "$TXT_FILE"

# Loop through the IP addresses
for ip_address in "${IP_ADDRESSES[@]}"; do
  # Set up the URL
  URL="https://www.virustotal.com/api/v3/ip_addresses/${ip_address}"

  # Send the request and store the response
  response=$(curl -s -H "x-apikey: $API_KEY" "$URL")

  # Check if the request was successful
  if [[ $(echo "$response" | jq -r '.error') == "null" ]]; then
    # Successful request
    echo "$response" > "${ip_address}_reputation.txt"
    echo "IP reputation data for $ip_address saved to ${ip_address}_reputation.txt"
  else
    # Error occurred
    error_message=$(echo "$response" | jq -r '.error.message')
    echo "Error for $ip_address: $error_message"
  fi
done
