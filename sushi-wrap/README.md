<img align="right" width="250" height="47" src="../images/Gematik_Logo_Flag_With_Background.png"/> <br/> 
  
# sushi-wrap

<details>
  <summary>Table of Contents</summary>
  <ol>
    <li><a href="#about-the-project">About The Project</a></li>
    <li><a href="#prerequisites">Prerequisites</a></li>
    <li><a href="#preliminary-note">Preliminary Note</a></li>
    <li><a href="#structure-and-functionality">Structure and Functionality</a></li>
    <li><a href="#usage">Usage</a></li>
  </ol>
</details>

## About The Project
Example wrapper script to integrate an automated package download into Sushi workflows.

## Prerequisites
The following packages are required to run the script:

- **curl** (command-line tool and library for transferring data with URLs) - [Website](https://curl.se/)
- **yq** (lightweight and portable command-line YAML processor) - [Website](https://github.com/mikefarah/yq/)
- **jq** (lightweight and flexible command-line JSON processor) - [Website](https://jqlang.github.io/jq/)

## Preliminary Note
The content offered by the ZTS is subject to download conditions, which can be viewed at [https://terminologien.bfarm.de/download-conditions.html](https://terminologien.bfarm.de/download-conditions.html). Please ensure that you accept the applicable terms and conditions before using the provided script. Technically, acceptance of the download conditions is expressed by using an access token, which is generated during the execution of the wrapper script.

## Structure and Functionality
The directory ```/BfArM-Package-Test``` contains a "normal" Sushi example project, which has been supplemented with a wrapper script (```sushi-wrap.sh```). This script works according to the following pattern:

1. Retrieve the list of packages supported by ZTS via the Catalog API
2. Compare the downloaded list with the list of accepted download conditions
3. Parse the ```sushi-config.yaml``` file using ```yq```
4. Download all dependencies provided by ZTS for which the download conditions have been accepted
5. Unpack the downloaded package versions and move the files to the FHIR home directory
6. Clean up
7. Execute ```sushi```

The wrapper script can be used in any sushi project.

## Usage
### Required Adjustments to the Wrapper Script
Before the wrapper script can be used, adjustments are required. In particular, the configuration variable ```ACCEPTED_DOWNLOAD_CONDITIONS``` must include all packages for which the user has accepted the download conditions (see above).

### Starting the Wrapper Script
The wrapper script can be started by executing ```./sushi-wrap.sh``` from within the ```/BfArM-Package-Test``` directory.