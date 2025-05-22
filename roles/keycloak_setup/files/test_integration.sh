#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Function to print test results
print_result() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✓ $2${NC}"
    else
        echo -e "${RED}✗ $2${NC}"
        exit 1
    fi
}

# Function to check if a command exists
check_command() {
    if ! command -v $1 &> /dev/null; then
        echo -e "${RED}Error: $1 is required but not installed.${NC}"
        exit 1
    fi
}

# Check required commands
check_command curl
check_command jq

echo -e "${YELLOW}Starting Foreman-Keycloak integration tests...${NC}\n"

# Test 1: Keycloak Health Check
echo "Test 1: Checking Keycloak health..."
curl -s -k "${KEYCLOAK_URL}/health/ready" > /dev/null
print_result $? "Keycloak health check"

# Test 2: Keycloak Realm Configuration
echo "Test 2: Verifying Keycloak realm configuration..."
curl -s -k "${KEYCLOAK_URL}/realms/${KEYCLOAK_REALM}/.well-known/openid-configuration" | jq . > /dev/null
print_result $? "Keycloak realm configuration"

# Test 3: Foreman Client Configuration
echo "Test 3: Checking Foreman client configuration..."
CLIENT_CONFIG=$(curl -s -k "${KEYCLOAK_URL}/realms/${KEYCLOAK_REALM}/clients" \
    -H "Authorization: Bearer $(curl -s -k -X POST "${KEYCLOAK_URL}/realms/master/protocol/openid-connect/token" \
    -d "grant_type=client_credentials" \
    -d "client_id=admin-cli" \
    -d "client_secret=${KEYCLOAK_ADMIN_PASSWORD}" | jq -r '.access_token')" | jq -r ".[] | select(.clientId==\"${KEYCLOAK_CLIENT}\")")

if [ -n "$CLIENT_CONFIG" ]; then
    print_result 0 "Foreman client exists"
else
    print_result 1 "Foreman client not found"
fi

# Test 4: User Authentication
echo "Test 4: Testing user authentication..."
TOKEN=$(curl -s -k -X POST "${KEYCLOAK_URL}/realms/${KEYCLOAK_REALM}/protocol/openid-connect/token" \
    -d "grant_type=password" \
    -d "client_id=${KEYCLOAK_CLIENT}" \
    -d "username=${TEST_USER}" \
    -d "password=${TEST_PASSWORD}" | jq -r '.access_token')

if [ -n "$TOKEN" ] && [ "$TOKEN" != "null" ]; then
    print_result 0 "User authentication successful"
else
    print_result 1 "User authentication failed"
fi

# Test 5: User Role Verification
echo "Test 5: Verifying user roles..."
USER_ROLES=$(curl -s -k "${KEYCLOAK_URL}/realms/${KEYCLOAK_REALM}/protocol/openid-connect/userinfo" \
    -H "Authorization: Bearer ${TOKEN}" | jq -r '.roles[]')

if echo "$USER_ROLES" | grep -q "foreman-admin"; then
    print_result 0 "User has correct roles"
else
    print_result 1 "User role verification failed"
fi

# Test 6: Foreman SSO Endpoint
echo "Test 6: Testing Foreman SSO endpoint..."
SSO_RESPONSE=$(curl -s -k -I "${FOREMAN_URL}/users/auth/keycloak" | head -n 1)

if echo "$SSO_RESPONSE" | grep -q "302"; then
    print_result 0 "Foreman SSO endpoint is working"
else
    print_result 1 "Foreman SSO endpoint test failed"
fi

# Test 7: Session Management
echo "Test 7: Testing session management..."
SESSION_CHECK=$(curl -s -k "${KEYCLOAK_URL}/realms/${KEYCLOAK_REALM}/protocol/openid-connect/userinfo" \
    -H "Authorization: Bearer ${TOKEN}" | jq -r '.sub')

if [ -n "$SESSION_CHECK" ]; then
    print_result 0 "Session management is working"
else
    print_result 1 "Session management test failed"
fi

# Test 8: Logout Functionality
echo "Test 8: Testing logout functionality..."
LOGOUT_RESPONSE=$(curl -s -k -X POST "${KEYCLOAK_URL}/realms/${KEYCLOAK_REALM}/protocol/openid-connect/logout" \
    -H "Authorization: Bearer ${TOKEN}")

if [ $? -eq 0 ]; then
    print_result 0 "Logout functionality is working"
else
    print_result 1 "Logout test failed"
fi

echo -e "\n${GREEN}All tests completed successfully!${NC}" 