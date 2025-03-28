#!/bin/bash

# ====================================================================================================================================
# Configuration
# ====================================================================================================================================

# List of accepted download conditions, e.g. 'bfarm.terminologien.abc,bfarm.terminologien.xyz'
# The list of accepted download conditions can be viewed on the website (https://terminologien.bfarm.de).
ACCEPTED_DOWNLOAD_CONDITIONS=bfarm.terminologien.abc,bfarm.terminologien.xyz

# The value to be set in the User-Agent header
USER_AGENT=example-zts-client/1.0

# Endpoint addresses of the ZTS API
CATALOG_API_ENDPOINT=https://terminologien.bfarm.de/packages/catalog
PACKAGE_API_ENDPOINT=https://terminologien.bfarm.de/packages
TOKEN_API_ENDPOINT=https://terminologien.bfarm.de/api/generate-token

# Path/filenames for temporary working files
CATALOG_METADATA_FILE=catalog.json
FHIR_HOME=~/.fhir
OUTPUT_DIR=$(uuidgen)
CURRENT_DIR=$(pwd)

# This and that
DEBUG=false

# ====================================================================================================================================
# Helper functions
# ====================================================================================================================================

# Function that checks if an element is present in an array
contains_element() {
  local element="$1"
  shift
  local array=("$@")
  for e in "${array[@]}"; do
    if [[ "$e" == "$element" ]]; then
      return 0  # found
    fi
  done
  return 1  # not found
}

# ====================================================================================================================================
# Preparing the environment
# ====================================================================================================================================

# Create a (temporary) output directory
mkdir $OUTPUT_DIR

# Convert the list of accepted download conditions into an array
IFS=',' read -ra accepted_conditions_packages <<< "$ACCEPTED_DOWNLOAD_CONDITIONS"
echo "Pakete für die Downloadbedingungen akzeptiert wurden: ${accepted_conditions_packages[@]}"

# ====================================================================================================================================
# Retrieve the list of supported packages
# ====================================================================================================================================

# Request the Catalog API for a list of supported terminologies — the result will be written to a file
curl --user-agent "{$USER_AGENT}" -X GET "{$CATALOG_API_ENDPOINT}" -H "Accept: application/json" -sS -o $CATALOG_METADATA_FILE

# Convert the catalog into an array containing the names of supported packages. These are the packages available on the ZTS and can be downloaded.
available_packages=($(jq -r '.[].name' "$CATALOG_METADATA_FILE"))
if [[ "$DEBUG" == "true" ]]; then 
  echo "Auf ZTS verwaltete Pakete: ${available_packages[@]}" 
fi

# Create the intersection between the accepted packages and the packages available on the ZTS. These are the packages that can be downloaded.
downloadable_packages=()
for item in "${accepted_conditions_packages[@]}"; do
  for element in "${available_packages[@]}"; do
    if [[ "$item" == "$element" ]]; then
      downloadable_packages+=("$item")
    fi
  done
done

if [[ "$DEBUG" == "true" ]]; then 
  echo "Für den Download 'verfügbare' Pakete: ${downloadable_packages[@]}"
fi

# ====================================================================================================================================
# Process dependencies
# ====================================================================================================================================

# Extract dependencies from the configuration file and convert them into an array
dependencies=($(yq '.dependencies' sushi-config.yaml | sed 's/:.*//'))
if [[ "$DEBUG" == "true" ]]; then 
  echo "Definierte Paketabhängigkeiten: ${dependencies[@]}"
fi

# Create the intersection between the required packages and the downloadable packages
final_packages=()
for item in "${dependencies[@]}"; do
  for element in "${downloadable_packages[@]}"; do
    if [[ "$item" == "$element" ]]; then
      final_packages+=("$item")
    fi
  done
done

if [[ "$DEBUG" == "true" ]]; then 
  echo "Für den Download vorgesehene Pakete: ${final_packages[@]}"
fi

# ====================================================================================================================================
# Generate structure for the request to TOKEN_API_ENDPOINT 
# ====================================================================================================================================

# Prepare array for request body
PACKAGE_ARRAY="["
for item in "${downloadable_packages[@]}"; do
  PACKAGE_ARRAY+="\"$item\","
done

# Remove trailing comma and close the array
PACKAGE_ARRAY="${PACKAGE_ARRAY%,}]"

# Create request body for the request to the Token API
REQUEST_BODY="{\"packages\":$PACKAGE_ARRAY}"

# ====================================================================================================================================
# # Generate token for the download
# ====================================================================================================================================

# Accept the package's download conditions
# Important: Please make sure to review the applicable download conditions in advance. This can be done via the website.
DOWNLOAD_TOKEN=$(curl --user-agent "{$USER_AGENT}" -sS -X POST -H "Content-Type: application/json" -d "$REQUEST_BODY" $TOKEN_API_ENDPOINT | jq -r '.token')
if [[ "$DEBUG" == "true" ]]; then 
  echo "Download Token: $DOWNLOAD_TOKEN"
fi

# ====================================================================================================================================
# Download Packages
# ====================================================================================================================================

# Iterate over the defined package dependencies
yq '.dependencies' sushi-config.yaml | while read package_version; do
  
  # Extract package name and package version
  name=$(echo $package_version | sed 's/:.*//' | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')
  version=$(echo $package_version | sed 's/.*://' | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')

  # The package will only be downloaded if it is included in the list of downloadable packages
  if contains_element $name "${downloadable_packages[@]}"; then
    echo "Downloading $name#$version"
    curl --user-agent "{$USER_AGENT}" -sS -X GET "{$PACKAGE_API_ENDPOINT}/{$name}/{$version}" -H "Authorization: Bearer $DOWNLOAD_TOKEN" -O --remote-header-name --output-dir $OUTPUT_DIR
  else
    echo "Das Paket '$name' ist auf dem ZTS entweder nicht verfügbar oder die Downloadbedingungen wurden nicht akzeptiert."
  fi
done

# ====================================================================================================================================
# # Process downloaded packages and move them to the FHIR directory
# ====================================================================================================================================

cd $OUTPUT_DIR

for file in *.tar.gz; do

  # Extract package name and package version
  export PACKAGE_NAME=$(echo $file | sed 's/-.*//')
  export PACKAGE_VERSION=$(echo $file | sed 's/.*-\([0-9.]*\)\..*/\1/')

  # Create directory for the package
  mkdir $PACKAGE_NAME#$PACKAGE_VERSION

  # Extract the package
  tar -xzf $file -C $PACKAGE_NAME#$PACKAGE_VERSION
  
  # Delete the package file
  rm $file
  
  # Move the extracted package to the FHIR directory
  if [ -d $FHIR_HOME/packages/$PACKAGE_NAME#$PACKAGE_VERSION ]; then
    echo "Das Paket $PACKAGE_NAME#$PACKAGE_VERSION existiert bereits."
  else
    mv -f $PACKAGE_NAME#$PACKAGE_VERSION $FHIR_HOME/packages
  fi
done

# Change back to the original working directory and clean up
cd $CURRENT_DIR
rm -rf $OUTPUT_DIR
rm $CATALOG_METADATA_FILE

# ====================================================================================================================================
# Call sushi
# ====================================================================================================================================

sushi .

echo "So Long, and Thanks for All the Fsh"
