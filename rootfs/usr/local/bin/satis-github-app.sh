#!/usr/bin/env bash

set -euo pipefail

echo Generating JWT >&2

pem=$(cat "$PRIVATE_KEY") # file path of the private key as second argument

b64enc() { openssl base64 | tr -d '=' | tr '/+' '_-' | tr -d '\n'; }

# Header
header_json=$(jq -n '{"typ": "JWT", "alg": "RS256"}')
header=$(echo -n "$header_json" | b64enc)

# Payload
payload_json=$(jq -n --arg appId "$APP_ID" '{"iat": (now - 60 | floor), "exp": (now + 60 | floor), "iss": $appId}')
payload=$(echo -n "$payload_json" | b64enc)

# Signature
header_payload="$header.$payload"
signature=$(openssl dgst -sha256 -sign <(echo -n "$pem") <(echo -n "$header_payload") | b64enc)

# Create jwt
jwt="$header_payload.$signature"

echo Creating access token >&2
token=$(curl -s -f -X POST \
  -H "Authorization: Bearer $jwt" \
  -H 'Accept: application/vnd.github+json' \
  "https://api.github.com/app/installations/$INSTALLATION_ID/access_tokens" \
  | jq -r '.token')

echo Configuring Composer to use token >&2
COMPOSER_AUTH=$(jq -c --arg token "$token" '."github-oauth"."github.com" = $token' /composer/auth.json)
export COMPOSER_AUTH

echo Running Satis >&2
satis "$@"

echo Revoking token >&2
curl -s -f -X DELETE \
  -H "Authorization: Bearer $token" \
  -H 'Accept: application/vnd.github+json' \
  -H 'X-GitHub-Api-Version: 2022-11-28' \
  https://api.github.com/installation/token
