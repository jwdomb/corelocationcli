# CoreLocationCLI

CoreLocationCLI gets the physical location of your device and prints it to standard output. If you move it can also print your updated location. *Kill it with CTRL-C.*

Note for Mac users: make sure Wi-Fi is turned on. Otherwise you will see `kCLErrorDomain error 0`.

## Usage

```sh
CoreLocationCLI -h
CoreLocationCLI [--watch] [--verbose] [--format FORMAT]
CoreLocationCLI [--watch] [--verbose] --json
```

| Switch                   | Description                                            |
| ------------------------ | ------------------------------------------------------ |
| `-h, --help`             | Display this help message and exit                     |
| `-w, --watch`            | Continually print location                             |
| `-v, -verbose`           | Show debugging output                                  |
| `-f, --format FORMAT`    | Print a formatted string with the following specifiers |
| `-j, --json`             | JSON output mode                                       |

| Format                   | Description                                            |
| ------------------------ | ------------------------------------------------------ |
| `%latitude`              | Latitude (degrees north; or negative for south) |
| `%longitude`             | Longitude (degrees west; or negative for east) |
| `%altitude`              | Altitude (meters)                        |
| `%direction`             | Degrees from true north                  |
| `%speed`                 | Meters per second                        |
| `%horizontalAccuracy`    | Horizontal accuracy (meters)             |
| `%verticalAccuracy`      | Vertical accuracy (meters)               |
| `%time`                  | Time                                     |
| `%address`               | Reverse geocoded location to an address  |
| `%name`                  | Reverse geocoded place name |
| `%isoCountryCode`        | Reverse geocoded ISO country code |
| `%country`               | Reverse geocoded country name |
| `%postalCode`            | Reverse geocoded postal code |
| `%administrativeArea`    | Reverse geocoded state or province |
| `%subAdministrativeArea` | additional administrative area information |
| `%locality`              | Reverse geocoded city name |
| `%subLocality`           | additional city-level information |
| `%thoroughfare`          | Reverse geocoded street address |
| `%subThoroughfare`       | additional street-level information |
| `%region`                | Reverse geocoded geographic region |
| `%inlandWater`           | Reverse geocoded name of inland water body |
| `%ocean`                 | Reverse geocoded name of ocean|
| `%areasOfInterest`       | Reverse geocoded areas of interest (; separator) |
| `%timeZone`              | Reverse geocoded time zone |
| `%timeLocal`             | Localized time using reverse geocoded time zone |

The default format is: `%latitude %longitude`.

## Output examples

```sh
./CoreLocationCLI
```

> ```
> 50.943829 6.941043
> ```

```sh
./CoreLocationCLI --format "%latitude %longitude\n%address"
```

> ```
> 50.943829 6.941043
> Kaiser-Wilhelm-Ring 21
> 	Cologne North Rhine-Westphalia 50672
> 	Germany
> ```

```sh
./CoreLocationCLI --json
```

> ```json
> {
>     "address": "407 Keats Rd\nLower Moreland PA 19006\nUnited States",
>     "locality": "Lower Moreland",
>     "subThoroughfare": "407",
>     "time": "2019-10-03 04:10:05 +0000",
>     "areasOfInterest": null,
>     "subLocality": null,
>     "administrativeArea": "PA",
>     "country": "United States",
>     "thoroughfare": "Keats Rd",
>     "ocean": null,
>     "region": "<+40.141196,-75.034815> radius 35.91",
>     "speed": "-1",
>     "latitude": "40.141196",
>     "name": "1354 Panther Rd",
>     "altitude": "92.00",
>     "timeZone": "America/New_York",
>     "timeLocal": "2019-10-02 23:10:05 -0400",
>     "isoCountryCode": "US",
>     "longitude": "-75.034815",
>     "verticalAccuracy": "65",
>     "postalCode": "19006",
>     "inlandWater": null,
>     "direction": "-1.0",
>     "horizontalAccuracy": "65",
>     "subAdministrativeArea": "Montgomery"
> }
>  ```

## Installation

Build from the command line using the Xcode compiler with one of these commands:

```sh
xcodebuild # requires Apple Developer account
# ... or ...
swift build --disable-sandbox -c release # does not require account
```

Then run your executable from this location:

```sh
./.build/arm64-apple-macosx/release/CoreLocationCLI --help
```

## macOS Gatekeeper/Notarization

After trying to run `CoreLocationCLI` for the first time, the process will be blocked by Gatekeeper, and a system dialog will appear which includes

> "CoreLocationCLI" can't be opened because it is from an unidentified developer...

To approve the process and allow `CoreLocationCLI` to run, go to System Preferences ➡️ Security & Privacy ➡️ General, and look in the bottom right corner for a button to click.

After approving `CoreLocationCLI`, it should run successfully. For more information, see https://support.apple.com/en-us/HT202491.

## Project scope

This project exists to provide **a simple tool** for **getting a device's location**. It is expected that this will be **composed with other tools** or used directly for **testing** and **logging**.
