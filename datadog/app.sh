#!/bin/bash

# Get environment variables
DATADOG_API_KEY="$DATADOG_API_KEY"
DATADOG_APPLICATION_KEY="$DATADOG_APPLICATION_KEY"
DATADOG_ENVIRONMENT_ID="$DATADOG_ENVIRONMENT_ID"
PORT_CLIENT_ID="$PORT_CLIENT_ID"
PORT_CLIENT_SECRET="$PORT_CLIENT_SECRET"
DATADOG_API_URL="https://api.us5.datadoghq.com/api/v1"
PORT_API_URL="https://api.getport.io/v1"
BLUEPRINT_ID="datadogSLO"

# Get Port Access Token
credentials="{\"clientId\": \"$PORT_CLIENT_ID\", \"clientSecret\": \"$PORT_CLIENT_SECRET\"}"
token_response=$(curl -X POST -H "Content-Type: application/json" -d "$credentials" "$PORT_API_URL/auth/access_token")
access_token=$(echo "$token_response" | jq -r '.accessToken')

# Create entity in Port
add_entity_to_port() {
    entity_object="$1"
    response=$(curl -X POST -H "Content-Type: application/json" -H "Authorization: Bearer $access_token" -d "$entity_object" "$PORT_API_URL/blueprints/$BLUEPRINT_ID/entities?upsert=true&merge=true")
    echo "$response"
}

# Retrieve service dependencies from Datadog using REST API
retrieve_service_dependencies() {
    env="$1"
    headers="-H 'DD-API-KEY: $DATADOG_API_KEY' -H 'DD-APPLICATION-KEY: $DATADOG_APPLICATION_KEY' -H 'Accept: application/json'"
    services_response=$(curl -H "DD-API-KEY: $DATADOG_API_KEY" -H "DD-APPLICATION-KEY: $DATADOG_APPLICATION_KEY" -H "Accept: application/json" "$DATADOG_API_URL/service_dependencies?env=$env")
    slos=$(echo "$services_response" | jq -r '.data[]')
    echo "$slos"

    for slo in $slos; do
        identifier=$(echo "$slo" | jq -r '.id')
        title=$(echo "$slo" | jq -r '.name')
        description=$(echo "$slo" | jq -r '.description')
        target=$(echo "$slo" | jq -r '.target_threshold')
        timeframe=$(echo "$slo" | jq -r '.timeframe')
        type=$(echo "$slo" | jq -r '.type')
        creator=$(echo "$slo" | jq -r '.creator.email')
        tags=$(echo "$slo" | jq -r '.tags[]')

        entity="{\"identifier\": \"$identifier\", \"title\": \"$title\", \"properties\": {\"description\": \"$description\", \"target\": \"$target\", \"timeframe\": \"$timeframe\", \"type\": \"$type\", \"creator\": \"$creator\"}, \"relations\": {\"microservice\": \"$tags\"}}"

        add_entity_to_port "$entity"
    done
}
retrieve_slos
