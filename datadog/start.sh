#!/bin/bash

PORT_CLIENT_ID="$PORT_CLIENT_ID"
PORT_CLIENT_SECRET="$PORT_CLIENT_SECRET"
DATADOG_API_KEY="$DATADOG_API_KEY"
DATADOG_APPLICATION_KEY="$DATADOG_APPLICATION_KEY"
DATADOG_API_URL="$DATADOG_API_URL"
PORT_API_URL="https://api.getport.io/v1"
BLUEPRINT_ID="datadogSLO"

# Get Port Access Token
credentials="{\"clientId\": \"$PORT_CLIENT_ID\", \"clientSecret\": \"$PORT_CLIENT_SECRET\"}"
token_response=$(curl -X POST -H "Content-Type: application/json" -d "$credentials" "$PORT_API_URL/auth/access_token")
access_token=$(echo "$token_response" | jq -r '.accessToken')

# Create entity in Port
add_entity_to_port() {
    entity_object="$1"
    response=$(curl -X POST -H "Content-Type: application/json" -H "Authorization: Bearer $access_token" -d "$entity_object" "$PORT_API_URL/blueprints/$BLUEPRINT_ID/entities?upsert=true&merge=true&create_missing_related_entities=true")
    echo "$response"
}

# Retrieve SLO from Datadog using REST API
retrieve_slos() {
    services_response=$(curl -s -H "DD-API-KEY: $DATADOG_API_KEY" -H "DD-APPLICATION-KEY: $DATADOG_APPLICATION_KEY" -H "Accept: application/json" "$DATADOG_API_URL/api/v1/slo")
    slos=$(echo "$services_response" | jq -c '.data[]')

    # Escape control characters in the JSON data
    json_data_escaped=$(echo "$slos" | sed 's/[\x00-\x1F\x7F]//g')

    # Iterate over each object in the JSON array
    echo "$json_data_escaped" | while IFS='' read -r slo; do
        identifier=$(echo "$slo" | jq -r '.id')
        title=$(echo "$slo" | jq -r '.name')
        description=$(echo "$slo" | jq -r '.description')
        target=$(echo "$slo" | jq -r '.thresholds[0].target')
        timeframe=$(echo "$slo" | jq -r '.timeframe')
        type=$(echo "$slo" | jq -r '.type')
        creator=$(echo "$slo" | jq -r '.creator.email')
        microservice=$(echo "$slo" | jq -r '.tags')

        entity="{\"identifier\":\"$identifier\",\"title\":\"$title\",\"properties\":{\"description\":\"$description\",\"target\":\"$threshold_target\",\"timeframe\":\"$timeframe\",\"type\":\"$type\",\"creator\":\"$creator\"},\"relations\":{\"microservice\":"$microservice"}}"
        add_entity_to_port "$entity"
    done
}

retrieve_slos