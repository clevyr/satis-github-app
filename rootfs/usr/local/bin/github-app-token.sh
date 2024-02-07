#!/usr/bin/env bash

set -euo pipefail

pem=$(cat "$PRIVATE_KEY") # file path of the private key as second argument

b64enc() { openssl base64 | tr -d '=' | tr '/+' '_-' | tr -d '\n'; }

# Header
header_json=$(jq -n '{"typ": "JWT", "alg": "RS256"}')
header=$(echo -n "$header_json" | b64enc)

# Payload
payload_json=$(jq -n --arg appId "$APP_ID" '{"iat": (now - 60 | floor), "exp": (now + 600 | floor), "iss": $appId}')
payload=$(echo -n "$payload_json" | b64enc)

# Signature
header_payload="$header.$payload"
signature=$(openssl dgst -sha256 -sign <(echo -n "$pem") <(echo -n "$header_payload") | b64enc)

# Create jwt
jwt="$header_payload.$signature"

token=$(curl -s -f -X POST \
  -H "Authorization: Bearer $jwt" \
  -H 'Accept: application/vnd.github+json' \
  "https://api.github.com/app/installations/$INSTALLATION_ID/access_tokens" \
  | jq -r '.token')

jq -c --arg token "$token" '.github-oauth."github.com" = $token' ${COMPOSER_AUTH_SOURCE:-/composer/auth.json} > /composer/auth.json
