#!/bin/bash

# Get environment variables
DATADOG_API_KEY=$DATADOG_API_KEY
DATADOG_APPLICATION_KEY=$DATADOG_APPLICATION_KEY
PORT_CLIENT_ID=$PORT_CLIENT_ID
PORT_CLIENT_SECRET=$PORT_CLIENT_SECRET
DATADOG_API_URL="https://api.us5.datadoghq.com/api/v1"
PORT_API_URL="https://api.getport.io/v1"
BLUEPRINT_ID="datadogSLO"

# Get Port Access Token
TOKEN_RESPONSE=$(curl -X POST -H "Content-Type: application/json" -d '{"clientId": "'"$PORT_CLIENT_ID"'", "clientSecret": "'"$PORT_CLIENT_SECRET"'"}' "$PORT_API_URL/auth/access_token")
ACCESS_TOKEN=$(echo "$TOKEN_RESPONSE" | jq -r '.accessToken')

# Define headers
HEADERS="Authorization: Bearer $ACCESS_TOKEN"

add_entity_to_port() {
    ENTITY_OBJECT=$1

    # Create entity in Port catalog
    RESPONSE=$(curl -X POST -H "Content-Type: application/json" -H "$HEADERS" -d "$ENTITY_OBJECT" "$PORT_API_URL/blueprints/$BLUEPRINT_ID/entities?upsert=true&merge=true")
    echo "$RESPONSE"
}

retrieve_slos() {
    # Retrieve SLOs from Datadog
    SERVICES_RESPONSE=$(curl -s -X GET -H "DD-API-KEY: $DATADOG_API_KEY" -H "DD-APPLICATION-KEY: $DATADOG_APPLICATION_KEY" -H "Accept: application/json" "$DATADOG_API_URL/slo")
    SLOS=$(echo "$SERVICES_RESPONSE" | jq -c '.data[]')
    echo "$SLOS"

    for SLO in $SLOS; do
        echo "$SLO"
        IDENTIFIER=$(echo "$SLO" | jq -r '.id')
        TITLE=$(echo "$SLO" | jq -r '.name')
        DESCRIPTION=$(echo "$SLO" | jq -r '.description')
        TARGET=$(echo "$SLO" | jq -r '.target_threshold')
        TIMEFRAME=$(echo "$SLO" | jq -r '.timeframe')
        TYPE=$(echo "$SLO" | jq -r '.type')
        CREATOR=$(echo "$SLO" | jq -r '.creator.email')
        MICROSERVICE=$(echo "$SLO" | jq -r '.tags[]')

        ENTITY='{
            "identifier": "'"$IDENTIFIER"'",
            "title": "'"$TITLE"'",
            "properties": {
                "description": "'"$DESCRIPTION"'",
                "target": "'"$TARGET"'",
                "timeframe": "'"$TIMEFRAME"'",
                "type": "'"$TYPE"'",
                "creator": "'"$CREATOR"'"
            },
            "relations": {
                "microservice": "'"$MICROSERVICE"'"
            }
        }'

        add_entity_to_port "$ENTITY"
    done
}

retrieve_slos