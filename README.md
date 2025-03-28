<img align="right" width="250" height="47" src="images/Gematik_Logo_Flag_With_Background.png"/> <br/> 
  
# zts-api-client-examples

<details>
  <summary>Table of Contents</summary>
  <ol>
    <li><a href="#about-the-project">About The Project</a></li>
    <li><a href="#getting-started">Getting Started</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
  </ol>
</details>

## About The Project
This repository offers a collection of example clients and configurations that showcase the automated downloading of FHIR packages via the API provided by [BfArM](https://www.bfarm.de)/[gematik](https://www.gematik.de), within the framework of the [ZTS (Zentraler Terminologieserver)](https://terminologien.bfarm.de).

### Release Notes
See [ReleaseNotes.md](./ReleaseNotes.md) for all information regarding the (newest) releases.

## Getting Started
The following example clients/configurations are currently provided:

- **[curl](./curl/)** — Example script for the automated download of FHIR packages using curl. The client supports various application scenarios in the context of content syndication (e.g., downloading package versions tagged as "latest", downloading all package versions).
- **[npm](./npm/)** — Example configuration/instructions for using npm to download and extract FHIR packages.
- **[sushi-wrap](./sushi-wrap/)** — Example wrapper script to integrate an automated package download into Sushi workflows.

For more in-depth documentation, please refer to the referenced README files of the individual tools.

## License
See [LICENSE](./LICENSE) for all information regarding licensing.

## Contact
We take open source license compliance very seriously. We are always striving to achieve compliance at all times and to improve our processes. 
This software is currently being tested to ensure its technical quality and legal compliance. Your feedback is highly valued. 
If you find any issues or have any suggestions or comments, or if you see any other ways in which we can improve, please reach out to: [https://terminologien.bfarm.de/kontakt.html](https://terminologien.bfarm.de/kontakt.html)
 
