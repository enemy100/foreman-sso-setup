#!/bin/bash

# Script to configure Keycloak via direct API calls
# Must be run on the same server as Keycloak

# Parameters (replace with actual values)
ADMIN_USER=$1
ADMIN_PASSWORD=$2
KEYCLOAK_URL="http://localhost:8080"
REALM_NAME=$3
CLIENT_ID=$4
REDIRECT_URI=$5

echo "Starting Keycloak configuration with:"
echo "Admin: $ADMIN_USER"
echo "Realm: $REALM_NAME"
echo "Client: $CLIENT_ID"
echo "Redirect URI: $REDIRECT_URI"

# Get admin token
echo "Obtaining admin token..."
TOKEN_RESPONSE=$(curl -s -X POST "$KEYCLOAK_URL/realms/master/protocol/openid-connect/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=$ADMIN_USER" \
  -d "password=$ADMIN_PASSWORD" \
  -d "grant_type=password" \
  -d "client_id=admin-cli")

# Extract token
TOKEN=$(echo $TOKEN_RESPONSE | grep -o '"access_token":"[^"]*' | sed 's/"access_token":"//')

if [ -z "$TOKEN" ]; then
  echo "Failed to get token. Response: $TOKEN_RESPONSE"
  
  # Try alternative method - direct login
  echo "Trying direct login with admin-cli..."
  TOKEN=$(curl -s -X POST "$KEYCLOAK_URL/realms/master/protocol/openid-connect/token" \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -d "client_id=admin-cli" \
    -d "username=$ADMIN_USER" \
    -d "password=$ADMIN_PASSWORD" \
    -d "grant_type=password" | grep -o '"access_token":"[^"]*' | sed 's/"access_token":"//')
  
  if [ -z "$TOKEN" ]; then
    echo "Failed to authenticate with alternative method."
    
    # Last resort - try to create admin user using kc.sh
    echo "Creating admin user directly..."
    /opt/keycloak/bin/kc.sh build --db=dev-file
    /opt/keycloak/bin/kc.sh show-config
    
    # Stop and restart Keycloak to apply changes
    systemctl stop keycloak
    systemctl start keycloak
    sleep 10
    
    # Try authentication again
    TOKEN=$(curl -s -X POST "$KEYCLOAK_URL/realms/master/protocol/openid-connect/token" \
      -H "Content-Type: application/x-www-form-urlencoded" \
      -d "client_id=admin-cli" \
      -d "username=$ADMIN_USER" \
      -d "password=$ADMIN_PASSWORD" \
      -d "grant_type=password" | grep -o '"access_token":"[^"]*' | sed 's/"access_token":"//')
      
    if [ -z "$TOKEN" ]; then
      echo "All authentication attempts failed. Exiting."
      exit 1
    fi
  fi
fi

echo "Successfully obtained token."

# Create realm
echo "Creating realm $REALM_NAME..."
REALM_RESPONSE=$(curl -s -X POST "$KEYCLOAK_URL/admin/realms" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"realm\":\"$REALM_NAME\",\"enabled\":true,\"displayName\":\"Foreman SSO Realm\"}")

if [ -n "$REALM_RESPONSE" ]; then
  echo "Realm creation response: $REALM_RESPONSE"
else
  echo "Realm created successfully."
fi

# Create client
echo "Creating client $CLIENT_ID..."
CLIENT_RESPONSE=$(curl -s -X POST "$KEYCLOAK_URL/admin/realms/$REALM_NAME/clients" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"clientId\":\"$CLIENT_ID\",\"enabled\":true,\"redirectUris\":[\"$REDIRECT_URI\"],\"webOrigins\":[\"+\"],\"standardFlowEnabled\":true,\"directAccessGrantsEnabled\":true,\"protocol\":\"openid-connect\"}")

if [ -n "$CLIENT_RESPONSE" ]; then
  echo "Client creation response: $CLIENT_RESPONSE"
else
  echo "Client created successfully."
fi

echo "Keycloak configuration completed." 