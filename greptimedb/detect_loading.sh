#!/bin/bash

# URL and request body for the GraphQL query
URL="http://127.0.0.1:8686/graphql"
QUERY='{"query":"{sources(first:1){edges{node{metrics{sentEventsTotal{sentEventsTotal}}}}}}"}' 

# Function to extract the sentEventsTotal value from the response
get_total_events() {
  local response=$(curl -s "$URL" -X POST -H 'content-type: application/json' --data-raw "$QUERY")
  echo "$response" | grep -o '"sentEventsTotal":[0-9.]*' | grep -o '[0-9.]*' | head -1
}

# Get initial value
previous_total=$(get_total_events)

# Loop to continuously check for changes
while true; do
  # Get current value
  current_total=$(get_total_events)
  
  # Check if value has changed
  if [ "$current_total" != "$previous_total" ]; then
    echo "Running: $current_total"
    previous_total=$current_total
    sleep 5
  else
    break
  fi
done