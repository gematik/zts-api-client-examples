<img align="right" width="250" height="47" src="../images/Gematik_Logo_Flag_With_Background.png"/> <br/> 
  
# npm

<details>
  <summary>Table of Contents</summary>
  <ol>
    <li><a href="#about-the-project">About The Project</a></li>
    <li><a href="#prerequisites">Prerequisites</a></li>
    <li><a href="#preliminary-note">Preliminary Note</a></li>
    <li><a href="#usage">Usage</a></li>
  </ol>
</details>

## About The Project
Example configuration/instructions for using npm to download and extract FHIR packages.

## Prerequisites
The following packages are required to run the script:

- **npm** (node package manager) - [Website](https://www.npmjs.com/)
- **curl** (command-line tool and library for transferring data with URLs) - [Website](https://curl.se/)
- **jq** (lightweight and flexible command-line JSON processor) - [Website](https://jqlang.github.io/jq/)

## Preliminary Note
The content offered by ZTS is subject to download conditions, which can be viewed at [https://terminologien.bfarm.de/download-conditions.html](https://terminologien.bfarm.de/download-conditions.html). Please ensure that you accept the applicable terms before using the provided script. Technically, acceptance of the download conditions is expressed by using an access token, which can be stored in the NPM configuration file `.npmrc`.

## Usage
### Creating the ```npm``` Configuration
To use ```npm```, a suitable configuration file must be created, which includes, among other things, the credentials required for accessing the registry (in the form of a download token). Creating a configuration file can be done easily with the provided script ```create_npm_config.sh```.

Before running the script, adjustments are required. The configuration variable ```ACCEPTED_DOWNLOAD_CONDITIONS``` must list all packages for which the user has accepted the download conditions (see above).

The script can be started using ```./create_npm_config.sh```. A download token will then be generated for the listed packages and combined with a template file (```.npmrc.template```).

### Downloading Packages via ```npm```
The download of a specific package (e.g., ICD-10-GM in its current version) can be initiated using the following command:

```npm --registry https://terminologien.bfarm.de/packages install bfarm.terminologien.icd10gm --userconfig ./.npmrc --prefix ./.packages```

As a result, a directory named ```.packages``` will be created, where the unpacked FHIR package in its 'latest' version can be found.
