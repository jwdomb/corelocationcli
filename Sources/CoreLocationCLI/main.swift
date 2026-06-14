//
//  main.swift
//  Core Location CLI
//
//  Created by William Entriken on 2016-01-12.
//  Copyright © 2016 William Entriken. All rights reserved.
//

import Foundation
import CoreLocation
import Contacts

enum OutputFormat {
    case json
    case string(String)
}

class Delegate: NSObject, CLLocationManagerDelegate {
    let locationManager = CLLocationManager()
    let geoCoder = CLGeocoder()
    var follow = false
    var verbose = false
    var format = OutputFormat.string("%latitude %longitude")
    var timeoutTimer: Timer? = nil
    var requiresPlacemarkLookup = false
    var latestHeading: CLHeading? = nil
    
    func start() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 2.0
        locationManager.delegate = self
        if verbose {
            print("locationServicesEnabled: \(CLLocationManager.locationServicesEnabled())")
            print("significantLocationChangeMonitoringAvailable: \(CLLocationManager.significantLocationChangeMonitoringAvailable())")
            print("headingAvailable: \(CLLocationManager.headingAvailable())")
            print("regionMonitoringAvailable for CLRegion: \(CLLocationManager.isMonitoringAvailable(for: CLRegion.self))")
        }
        timeoutTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: false, block: {_ in self.timeout()})
        self.locationManager.startUpdatingLocation()
        if CLLocationManager.headingAvailable() {
            self.locationManager.startUpdatingHeading()
        }
    }

    func timeout() {
        print("Fetching location timed out. Exiting.")
        exit(1)
    }
    
    func printFormattedLocation(location: CLLocation, placemark: CLPlacemark? = nil) {
        var formattedPostalAddress: String?
        if let postalAddress = placemark?.postalAddress {
            formattedPostalAddress = CNPostalAddressFormatter.string(from: postalAddress, style: .mailingAddress)
        }

        // Attempt to infer timezone for timestamp string
        var locatedTime: String?
        if let locatedTimeZone = placemark?.timeZone {
            let time = location.timestamp
            let formatter = DateFormatter()
            formatter.timeZone = locatedTimeZone
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
            locatedTime = formatter.string(from: time)
        }
        
        var formattedParts: [String: String?] = [
            "latitude": String(format: "%0.6f", location.coordinate.latitude),
            "longitude": String(format: "%0.6f", location.coordinate.longitude),
            "altitude": String(format: "%0.2f", location.altitude),
            "course": "\(location.course)",
            "courseAccuracy": "\(location.courseAccuracy)",
            "speed": "\(Int(location.speed))",
            "speedAccuracy": "\(Int(location.speedAccuracy))",
            "horizontalAccuracy": "\(Int(location.horizontalAccuracy))",
            "verticalAccuracy": "\(Int(location.verticalAccuracy))",
            "timestamp": location.timestamp.description,
            "floor": location.floor.map { "\($0.level)" },

            // Placemark
            "name": placemark?.name,
            "isoCountryCode": placemark?.isoCountryCode,
            "country": placemark?.country,
            "postalCode": placemark?.postalCode,
            "administrativeArea": placemark?.administrativeArea,
            "subAdministrativeArea": placemark?.subAdministrativeArea,
            "locality": placemark?.locality,
            "subLocality": placemark?.subLocality,
            "thoroughfare": placemark?.thoroughfare,
            "subThoroughfare": placemark?.subThoroughfare,
            "region": placemark?.region?.identifier,
            "timeZone": placemark?.timeZone?.identifier,
            "inlandWater": placemark?.inlandWater,
            "ocean": placemark?.ocean,
            "areasOfInterest": placemark?.areasOfInterest?.joined(separator: "; "),
            "timeLocal": locatedTime,

            // Address
            "address": formattedPostalAddress
        ]
        if #available(macOS 12, *) {
            formattedParts["ellipsoidalAltitude"] = String(format: "%0.2f", location.ellipsoidalAltitude)
            formattedParts["isSimulatedBySoftware"] = location.sourceInformation.map { "\($0.isSimulatedBySoftware)" }
            formattedParts["isProducedByAccessory"] = location.sourceInformation.map { "\($0.isProducedByAccessory)" }
        }
        if let heading = latestHeading {
            formattedParts["magneticHeading"] = String(format: "%0.1f", heading.magneticHeading)
            formattedParts["trueHeading"] = String(format: "%0.1f", heading.trueHeading)
            formattedParts["headingAccuracy"] = String(format: "%0.1f", heading.headingAccuracy)
        }

        switch format {
        case .json:
            var jsonObj: [String: Any] = formattedParts.mapValues { $0.map { $0 as Any } ?? NSNull() }
            jsonObj["schemaVersion"] = 2
            var options: JSONSerialization.WritingOptions = [.sortedKeys]
            if !self.follow { options.insert(.prettyPrinted) }
            let data = try! JSONSerialization.data(withJSONObject: jsonObj, options: options)
            print(String(data: data, encoding: .utf8)!)
        case .string(let output):
            print(formattedParts.reduce(output, { partialResult, keyValuePair in
                partialResult.replacingOccurrences(of: "%\(keyValuePair.key)", with: keyValuePair.value ?? "")
            }))
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if self.verbose {
            print("Location authorization status: \(manager.authorizationStatus)")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        timeoutTimer!.invalidate()
        let location = locations.first!
        if requiresPlacemarkLookup {
            self.geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) in
                if error != nil {
                    print("Reverse geocode failed: \(error?.localizedDescription ?? "unknown error")")
                    exit(1)
                }
                let placemark = placemarks?.first
                self.printFormattedLocation(location: location, placemark: placemark)
                if !self.follow {
                    exit(0)
                }
            })
        } else {
            printFormattedLocation(location: location)
            if !self.follow {
                exit(0)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        latestHeading = newHeading
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if error._code == 1 {
            print("CoreLocationCLI: ❌ Location services are disabled or location access denied. Please visit System Preferences > Security & Privacy > Privacy > Location Services")
            exit(1)
        } 
        print("CoreLocationCLI: ❌ \(error.localizedDescription)")
        exit(1)
    }

    func help() {
        print("""
        USAGE: CoreLocationCLI --help
               CoreLocationCLI [--watch] [--verbose] [--format FORMAT]
               CoreLocationCLI [--watch] [--verbose] --json

               Displays current location using CoreLocation services

        OPTIONS:
          -h, --help                    Display this help message and exit
          -w, --watch                   Continually print location
          -v, --verbose                 Show debugging output
          -f, --format FORMAT           Print a string with these substitutions

            Location
            %latitude                   Latitude (degrees north; or negative for south)
            %longitude                  Longitude (degrees west; or negative for east)
            %altitude                   Altitude above mean sea level (meters)
            %ellipsoidalAltitude        Altitude above WGS 84 ellipsoid (meters; macOS 12+)
            %floor                      Building floor (if available)
            %horizontalAccuracy         Horizontal accuracy (meters)
            %verticalAccuracy           Vertical accuracy (meters)
            %timestamp                  Time the location was determined (UTC)
            %timeLocal                  Time the location was determined (local time zone)

            Movement
            %speed                      Speed (meters per second; negative if invalid)
            %speedAccuracy              Speed accuracy (meters per second)
            %course                     Course relative to true north (degrees; negative if invalid)
            %courseAccuracy             Course accuracy (degrees)

            Heading (if available)
            %magneticHeading            Heading relative to magnetic north (degrees)
            %trueHeading                Heading relative to true north (degrees)
            %headingAccuracy            Heading accuracy (degrees; negative if invalid)

            Source (macOS 12+)
            %isSimulatedBySoftware      Whether location was simulated by software (true/false)
            %isProducedByAccessory      Whether location came from an external accessory (true/false)

            Placemark (requires reverse geocoding)
            %address                    Full formatted postal address
            %name                       Place name
            %isoCountryCode             ISO country code
            %country                    Country name
            %postalCode                 Postal code
            %administrativeArea         State or province
            %subAdministrativeArea      Additional administrative area information
            %locality                   City name
            %subLocality                Additional city-level information
            %thoroughfare               Street address
            %subThoroughfare            Additional street-level information
            %region                     Geographic region identifier
            %timeZone                   Time zone identifier
            %inlandWater                Name of inland water body
            %ocean                      Name of ocean
            %areasOfInterest            Areas of interest (; separator)
          -j, --json                    Prints a JSON object with all information available

          Default format if not specified is: %latitude %longitude.
          Using --json with --watch produces one line of JSON per location update,
          compatible with the JSON Lines text format.
        """)
    }
}

let delegate = Delegate()
for (i, argument) in ProcessInfo().arguments.enumerated() {
    switch argument {
    case "-h", "--help":
        delegate.help()
        exit(0)
    case "-w", "--watch":
        delegate.follow = true
    case "-v", "--verbose":
        delegate.verbose = true
    case "-f", "--format":
        if ProcessInfo().arguments.count > i+1 {
            delegate.format = .string(ProcessInfo().arguments[i+1])
            let placemarkStrings = ["%address", "%name", "%isoCountryCode", "%country", "%postalCode", "%administrativeArea", "%subAdministrativeArea", "%locality", "%subLocality", "%thoroughfare", "%subThoroughfare", "%region", "%inlandWater", "%ocean", "%areasOfInterest", "%timeZone", "%timeLocal"]
            if placemarkStrings.contains(where:ProcessInfo().arguments[i+1].contains) {
                delegate.requiresPlacemarkLookup = true
            }
        }
    case "-j", "--json":
        delegate.format = .json
        delegate.requiresPlacemarkLookup = true
    default:
        break
    }
}

delegate.start()

autoreleasepool {
    RunLoop.main.run()
}
