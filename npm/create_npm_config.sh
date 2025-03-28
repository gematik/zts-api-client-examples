#!/bin/bash

# ====================================================================================================================================
# Configuration
# ====================================================================================================================================

# List of accepted download conditions, e.g. 'bfarm.terminologien.abc,bfarm.terminologien.xyz'
# The list of accepted download conditions can be viewed on the website (https://terminologien.bfarm.de).
ACCEPTED_DOWNLOAD_CONDITIONS=bfarm.terminologien.abc,bfarm.terminologien.xyz

# The endpoint of the token API
TOKEN_API_ENDPOINT=https://terminologien.bfarm.de/api/generate-token

# The value to be set in the User-Agent header
USER_AGENT=example-zts-client/1.0

# ====================================================================================================================================
# Generate structure for the request to TOKEN_API_ENDPOINT
# ====================================================================================================================================

# Iterate over the list of accepted download conditions as defined in the configuration
IFS=',' read -ra items <<< "$ACCEPTED_DOWNLOAD_CONDITIONS"
PACKAGE_ARRAY="["
for item in "${items[@]}"; do
  PACKAGE_ARRAY+="\"$item\","
done

# Remove the trailing comma and close the array
PACKAGE_ARRAY="${PACKAGE_ARRAY%,}]"

# Create request body for the request to the token API
REQUEST_BODY="{\"packages\":$PACKAGE_ARRAY}"

# ====================================================================================================================================
# Generate token for the download
# ====================================================================================================================================

# Accept the package's download conditions
# Important: Make sure to review the applicable download conditions in advance. This can be done via the website.
DOWNLOAD_TOKEN=$(curl --user-agent "{$USER_AGENT}" -sS -X POST -H "Content-Type: application/json" -d "$REQUEST_BODY" $TOKEN_API_ENDPOINT | jq -r '.token')
echo "Download Token: $DOWNLOAD_TOKEN"
if [[ -z "$DOWNLOAD_TOKEN" ]] || [[ "$DOWNLOAD_TOKEN" == "null" ]]; then
  echo "Error while generating Download Token. Please check the configuration for 'accepted download conditions'."
  exit 1
fi

# ====================================================================================================================================
# Create configuration file for npm
# ====================================================================================================================================

# Create the configuration file from the template
cat .npmrc.template | \
sed "s/{{DOWNLOAD_TOKEN}}/$DOWNLOAD_TOKEN/g" > .npmrc
echo "Konfigurationsdatei erstellt"