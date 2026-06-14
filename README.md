# CoreLocationCLI

CoreLocationCLI gets the physical location of your device and prints it to standard output. If you move it can also print your updated location. *Kill it with CTRL-C.*

This is a personal fork of [fulldecent/corelocationcli](https://github.com/fulldecent/corelocationcli) with additional features. See the git history and LICENSE for details on what changed.

Note for Mac users: make sure Wi-Fi is turned on. Otherwise you will see `kCLErrorDomain error 0`.

## Usage

```sh
CoreLocationCLI --help
CoreLocationCLI --version
CoreLocationCLI [--watch] [--verbose] [--format FORMAT]
CoreLocationCLI [--watch] [--verbose] --json
```

| Switch                   | Description                                            |
| ------------------------ | ------------------------------------------------------ |
| `-h, --help`             | Display this help message and exit                     |
| `--version`              | Display the program version                            |
| `-w, --watch`            | Continually print location                             |
| `-v, --verbose`          | Show debugging output                                  |
| `-f, --format FORMAT`    | Print a formatted string with the following specifiers |
| `-j, --json`             | JSON output mode                                       |

**Location**

| Format                   | Description                                            |
| ------------------------ | ------------------------------------------------------ |
| `%latitude`              | Latitude (degrees north; or negative for south)        |
| `%longitude`             | Longitude (degrees west; or negative for east)         |
| `%altitude`              | Altitude above mean sea level (meters)                 |
| `%ellipsoidalAltitude`   | Altitude above WGS 84 ellipsoid (meters; macOS 12+)    |
| `%floor`                 | Building floor (if available)                          |
| `%horizontalAccuracy`    | Horizontal accuracy (meters)                           |
| `%verticalAccuracy`      | Vertical accuracy (meters)                             |
| `%timestamp`             | Time the location was determined (UTC)                 |
| `%timeLocal`             | Time the location was determined (local time zone)     |

**Movement**

| Format                   | Description                                            |
| ------------------------ | ------------------------------------------------------ |
| `%speed`                 | Speed (meters per second; negative if invalid)         |
| `%speedAccuracy`         | Speed accuracy (meters per second)                     |
| `%course`                | Course relative to true north (degrees; negative if invalid) |
| `%courseAccuracy`        | Course accuracy (degrees)                              |

**Heading** (if available)

| Format                   | Description                                            |
| ------------------------ | ------------------------------------------------------ |
| `%magneticHeading`       | Heading relative to magnetic north (degrees)           |
| `%trueHeading`           | Heading relative to true north (degrees)               |
| `%headingAccuracy`       | Heading accuracy (degrees; negative if invalid)        |

**Source** (macOS 12+)

| Format                     | Description                                          |
| -------------------------- | ---------------------------------------------------- |
| `%isSimulatedBySoftware`   | Whether location was simulated by software (true/false) |
| `%isProducedByAccessory`   | Whether location came from an external accessory (true/false) |

**Placemark** (requires reverse geocoding)

| Format                   | Description                                            |
| ------------------------ | ------------------------------------------------------ |
| `%address`               | Full formatted postal address                          |
| `%name`                  | Place name                                             |
| `%isoCountryCode`        | ISO country code                                       |
| `%country`               | Country name                                           |
| `%postalCode`            | Postal code                                            |
| `%administrativeArea`    | State or province                                      |
| `%subAdministrativeArea` | Additional administrative area information             |
| `%locality`              | City name                                              |
| `%subLocality`           | Additional city-level information                      |
| `%thoroughfare`          | Street address                                         |
| `%subThoroughfare`       | Additional street-level information                    |
| `%region`                | Geographic region identifier                           |
| `%timeZone`              | Time zone identifier                                   |
| `%inlandWater`           | Name of inland water body                              |
| `%ocean`                 | Name of ocean                                          |
| `%areasOfInterest`       | Areas of interest (; separator)                        |

## Schema versioning

The JSON output includes a `schemaVersion` integer field. If you are parsing JSON output, check this field to detect breaking changes.

**Version 2** (current) introduced the following breaking changes from version 1:

- `direction` was renamed to `course`
- `time` was renamed to `timestamp`

## Output examples

```sh
./CoreLocationCLI
```

> ```text
> 50.943829 6.941043
> ```

```sh
./CoreLocationCLI --format "%latitude %longitude\n%address"
```

> ```text
> 50.943829 6.941043
> Kaiser-Wilhelm-Ring 21
>  Cologne North Rhine-Westphalia 50672
>  Germany
> ```

```sh
./CoreLocationCLI --json
```

> ```json
> {
>     "address": "407 Keats Rd\nLower Moreland PA 19006\nUnited States",
>     "administrativeArea": "PA",
>     "altitude": "92.00",
>     "areasOfInterest": null,
>     "country": "United States",
>     "course": "-1.0",
>     "courseAccuracy": "-1.0",
>     "ellipsoidalAltitude": "88.35",
>     "floor": null,
>     "headingAccuracy": "10.0",
>     "horizontalAccuracy": "65",
>     "inlandWater": null,
>     "isoCountryCode": "US",
>     "isProducedByAccessory": "false",
>     "isSimulatedBySoftware": "false",
>     "latitude": "40.141196",
>     "locality": "Lower Moreland",
>     "longitude": "-75.034815",
>     "magneticHeading": "224.3",
>     "name": "1354 Panther Rd",
>     "ocean": null,
>     "postalCode": "19006",
>     "region": "<+40.141196,-75.034815> radius 35.91",
>     "schemaVersion": 2,
>     "speed": "-1",
>     "speedAccuracy": "-1",
>     "subAdministrativeArea": "Montgomery",
>     "subLocality": null,
>     "subThoroughfare": "407",
>     "thoroughfare": "Keats Rd",
>     "timeLocal": "2019-10-02 23:10:05 -0400",
>     "timeZone": "America/New_York",
>     "timestamp": "2019-10-03 04:10:05 +0000",
>     "trueHeading": "221.8",
>     "verticalAccuracy": "65"
> }
> ```

## Installation

This fork must be built from source. Update the signing identity in `scripts/build.sh` then:

```sh
swift build -c release
scripts/build.sh
```

The binary will be at `.build/release/CoreLocationCLI`.

## macOS Gatekeeper/notarization

After trying to run `CoreLocationCLI` for the first time, the process will be blocked by Gatekeeper, and a system dialog will appear which includes

> "CoreLocationCLI" can't be opened because it is from an unidentified developer...

To approve the process and allow `CoreLocationCLI` to run, go to System Settings ➡️ Privacy & Security ➡️ Security, and look in the bottom right corner for a button to click.

After approving `CoreLocationCLI`, it should run successfully. For more information, see <https://support.apple.com/en-us/HT202491>.

## Project scope

This project exists to provide **a simple tool** for **getting a device's location**. It is expected that this will be **composed with other tools** or used directly for **testing** and **logging**.

## Contributing

This is a personal fork and pull requests are not accepted. You are welcome to [open an issue](https://github.com/jwdomb/corelocationcli/issues). For the upstream project, visit [fulldecent/corelocationcli](https://github.com/fulldecent/corelocationcli).
