<img align="right" width="250" height="47" src="../images/Gematik_Logo_Flag_With_Background.png"/> <br/> 
  
# curl-based Download Script

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
Example script for the automated download of FHIR packages using curl. The client script supports various application scenarios in the context of content syndication (e.g., downloading package versions tagged as "latest", downloading all package versions).

## Prerequisites
The following packages are required to run the download script:

- **curl** (command-line tool and library for transferring data with URLs) - [Website](https://curl.se/)
- **jq** (lightweight and flexible command-line JSON processor) - [Website](https://jqlang.github.io/jq/)

## Preliminary Note
The content offered by ZTS is subject to download conditions, which can be viewed at [https://terminologien.bfarm.de/download-conditions.html](https://terminologien.bfarm.de/download-conditions.html). Please ensure that you accept the applicable terms before using the provided script. Acceptance of the terms must be confirmed via the command-line parameter ```-c``` (see below).

## Usage

### Command-Line Parameters
The following command-line parameters are supported by the tool:

- ```-c``` consent to download conditions — valid values: ```true```, ```false``` — default value: ```false```
- ```-i``` packages to INCLUDE — valid values: ```ALL``` (for all available packages), ```{packagelist}``` (package names separated by ',') — e.g., ```bfarm.terminologien.icd10gm,bfarm.terminologien.ops``` — default: ```ALL```
- ```-e``` packages to EXCLUDE from download — valid values: ```{packagelist}``` (package names separated by ',') — e.g. ```bfarm.terminologien.loinc,bfarm.terminologien.ucum``` — default: (none)
- ```-l``` download only the latest version of the package — valid values: ```true```, ```false``` — default: ```true```
- ```-o``` output directory (location where downloaded packages will be stored) — e.g., ```./content``` — default: ```./packages```

### Example Usage
The provided script enables various use cases regarding the download of terminology packages:

**Download the latest version of a specific named package**

```./download.sh -c [true|false] -i bfarm.terminologien.icd10gm -l true -o ./icd10gm```

**Download ALL versions of a specific named package**

```./download.sh -c [true|false] -i bfarm.terminologien.ops -l false -o ./ops```

**Download ALL versions of ALL packages managed by ZTS**

```./download.sh -c [true|false] -i ALL -l false -o ./packages```