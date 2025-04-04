# Copyright [2025], gematik GmbH
 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
 
#     http://www.apache.org/licenses/LICENSE-2.0
 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
 
# *******
 
# For additional notes and disclaimer from gematik and in case of changes by gematik find details in the "Readme" file.

#!/bin/bash

# ====================================================================================================================================
# Configuration
# ====================================================================================================================================

# To use the script, you must explicitly confirm that the applicable download conditions have been accepted
# see https://terminologien.bfarm.de/download-conditions.html
ACCEPTED_DOWNLOAD_CONDITIONS=false

# Packages to be downloaded. These can be specified as a comma-separated list.  
# If the value 'ALL' is set, all available packages will be downloaded.
INCLUDE_PACKAGES=ALL

# Packages that should NOT be downloaded. These must be specified as a comma-separated list.
EXCLUDE_PACKAGES=

# Limit the download to the version marked as "latest"
LATEST_ONLY=true

# The value to be set in the User-Agent header
USER_AGENT=example-zts-client/1.0

# Endpoint addresses of the ZTS API
CATALOG_API_ENDPOINT=https://terminologien.bfarm.de/packages/catalog
PACKAGE_API_ENDPOINT=https://terminologien.bfarm.de/packages
TOKEN_API_ENDPOINT=https://terminologien.bfarm.de/api/generate-token

# Output directory where downloaded package versions will be stored
OUTPUT_DIR=./packages

# Path/filenames for temporary working files
CATALOG_METADATA_FILE=catalog.json
PACKAGE_METADATA_FILE=response.json
CURRENT_DIR=$(pwd)

# ====================================================================================================================================
# Helper functions
# ====================================================================================================================================

# Display usage instructions for the script
usage() {
  echo "$0 -c [true|false] -i [ALL|{packagelist}] -e {packageList} -l [true|false] -o [outputDir]"
  echo "Command Line Parameters:"
  echo "  -c      consent to download conditions"
  echo "           valid values: 'true', 'false'"
  echo "           default: 'false'"
  echo "  -i      packages to INCLUDE"
  echo "           valid values: 'ALL' (for all available packages), {packagelist} (package names separated by ',') - e.g. 'bfarm.terminologien.icd10gm,bfarm.terminologien.ops'"
  echo "           default: 'ALL'" 
  echo "  -e      packages to EXCLUDE from download"
  echo "           valid values: {packagelist} (package names separated by ',') - e.g. 'bfarm.terminologien.loinc,bfarm.terminologien.ucum'"
  echo "           default: "
  echo "  -l      download only latest version of the package"
  echo "           valid values: 'true', 'false'"
  echo "           default: 'true'"
  echo "  -o      output directory (location where downloaded packages will be stored) - e.g. './content'"
  echo "           default: './packages'"
  exit 1
}

# ====================================================================================================================================
# Processing of command-line parameters (including validation)
# ====================================================================================================================================

# Processing of command-line parameters
while getopts "c:i:e:l:o:" opt; do
  case $opt in
    c) ACCEPTED_DOWNLOAD_CONDITIONS="$OPTARG" ;;
    i) INCLUDE_PACKAGES="$OPTARG" ;;
		e) EXCLUDE_PACKAGES="$OPTARG" ;;
		l) LATEST_ONLY="$OPTARG" ;;
		o) OUTPUT_DIR="$OPTARG" ;;
    *) usage ;;
  esac
done

# Check if the download conditions have been accepted
if [ "$ACCEPTED_DOWNLOAD_CONDITIONS" != true ]; then
  echo "Die Downloadbedingungen müssen bestätigt werden"
  usage
fi

# Check if the INCLUDE_PACKAGE value is correct
if [[ ! "$INCLUDE_PACKAGES" =~ ^ALL$|^[a-z0-9]+(\.[a-z0-9]+)+(,[a-z0-9]+(\.[a-z0-9]+)+)*$ ]]; then
  echo "Fehler bei der Angabe der zu inkludierenden Pakete: '$INCLUDE_PACKAGES'"
  usage
fi

# Check if the EXCLUDE_PACKAGE value is correct
if [[ ! "$EXCLUDE_PACKAGES" =~ ^$|^[a-z0-9]+(\.[a-z0-9]+)+(,[a-z0-9]+(\.[a-z0-9]+)+)*$ ]]; then
  echo "Fehler bei der Angabe der zu exkludierenden Pakete: '$EXCLUDE_PACKAGES'"
  usage
fi

# Check if the LATEST_ONLY value is correct


# ====================================================================================================================================
# Preparing the environment
# ====================================================================================================================================

# Create a (temporary) output directory
mkdir -p $OUTPUT_DIR

# ====================================================================================================================================
# Retrieving the list of supported packages
# ====================================================================================================================================

# Request the Catalog API for a list of supported terminologies — the result will be written to a file
echo "Downloading ZTS-Gesamtkatalog"
curl --user-agent "{$USER_AGENT}" -X GET "{$CATALOG_API_ENDPOINT}" -H "Accept: application/json" -sS -o $CATALOG_METADATA_FILE

# Iterate over all entries in the catalog
jq -r '.[].name' $CATALOG_METADATA_FILE | while read name; do
  
  # Only if the INCLUDE and EXCLUDE criteria are met, content will be downloaded
  if [[ "$INCLUDE_PACKAGES" == *"$name"* || "$INCLUDE_PACKAGES" == "ALL" ]] && [[ ! "$EXCLUDE_PACKAGES" == *"$name"* ]]; then

	  # Download package metadata
	  curl --user-agent "{$USER_AGENT}" -sS -X GET "{$PACKAGE_API_ENDPOINT}/{$name}" -H "Accept: application/json" -o $PACKAGE_METADATA_FILE

	  # Accept the package's download conditions
      # Important: Please make sure to review the applicable download conditions in advance. This can be done via the website.
	  DOWNLOAD_TOKEN=$(curl --user-agent "{$USER_AGENT}" -sS -X POST -H "Content-Type: application/json" -d "{\"packages\":[\"$name\"]}" $TOKEN_API_ENDPOINT | jq -r '.token')
	  
	  if [[ "$LATEST_ONLY" == true ]]; then
	  	# We only download the version of the package marked as 'latest'

	  	# Extract the latest version from the file using "jq"
	  	PACKAGE_VERSION_LATEST=$(jq -r '."dist-tags".latest' $PACKAGE_METADATA_FILE)

		# Change to the output directory
	  	cd $OUTPUT_DIR

	  	# Calculate the expected filename
	  	EXPECTED_FILE_NAME="$name-$PACKAGE_VERSION_LATEST.tar.gz"
	  
	  	# Package versions are only downloaded if they do not already exist
	  	if [ -f $EXPECTED_FILE_NAME ]; then
	    	echo "$EXPECTED_FILE_NAME existiert bereits. Es wird kein erneuter Download dieser Paketversion durchgeführt."
	  	else
	    	# Download the latest package version (and take the filename from the Content-Disposition header)
	    	echo "Downloading $name#$PACKAGE_VERSION_LATEST"
	    	curl --user-agent "{$USER_AGENT}" -X GET "{$PACKAGE_API_ENDPOINT}/{$name}/{$PACKAGE_VERSION_LATEST}" -H "Authorization: Bearer $DOWNLOAD_TOKEN" -sS -O --remote-header-name
	  	fi

		# Change back to the original working directory  	
	  	cd $CURRENT_DIR

	  else
	  	# We download all available versions of the package
	  	jq -r '.versions | keys[]' $PACKAGE_METADATA_FILE | while read version; do

	  		# Change to the output directory
	  		cd $OUTPUT_DIR

	  		# Calculate the expected filename
	  		EXPECTED_FILE_NAME="$name-$version.tar.gz"

	  		# Package versions are only downloaded if they do not already exist
	  		if [ -f $EXPECTED_FILE_NAME ]; then
	    		echo "$EXPECTED_FILE_NAME existiert bereits. Es wird kein erneuter Download dieser Paketversion durchgeführt."
		  	else
		    	# Download the package version (and take the filename from the Content-Disposition header)
		    	echo "Downloading $name#$version"
		    	curl --user-agent "{$USER_AGENT}" -X GET "{$PACKAGE_API_ENDPOINT}/{$name}/{$version}" -H "Authorization: Bearer $DOWNLOAD_TOKEN" -sS -O --remote-header-name
		  	fi
	
			# Change back to the original working directory  	  	
		  	cd $CURRENT_DIR

	  	done
	  fi 
	  
	  # Delete the downloaded metadata of the package
	  rm $PACKAGE_METADATA_FILE

  fi
done

# Delete the downloaded metadata of the package
rm $CATALOG_METADATA_FILE
