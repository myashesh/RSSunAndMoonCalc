//
//  ViewController.swift
//  RSSunAndMoonCalcDemo
//
//  Created by Sebastien REMY on 23/03/2017.
//  Copyright © 2017 Sebastien REMY. All rights reserved.
//

import UIKit
import RSSunAndMoonCalc
import CoreLocation

class ViewController: UIViewController {
    
    // MARK: - Constants
    
    fileprivate struct k {
        static let cellIdentifier = "cellIdentifier"
        
        // Informations
        static let dateIndex = IndexPath(row: 0, section: 0)
        static let latituteIndex = IndexPath(row: 1, section: 0)
        static let longitudeIndex = IndexPath(row: 2, section: 0)
        
        // Sun Position
        static let sunAltitudeIndex = IndexPath(row: 0, section: 1)
        static let sunAzimuthIndex = IndexPath(row: 1, section: 1)
        
        // Sun Rise and Set
        static let sunRiseIndex = IndexPath(row: 2, section: 1)
        static let sunSetIndex = IndexPath(row: 3, section: 1)
        static let solarNoonIndex = IndexPath(row: 4, section: 1)
        static let nadirIndex = IndexPath(row: 5, section: 1)
        
        // Sun Significant Date
        static let sunriseStart = IndexPath(row: 6, section: 1)
        static let sunsetEnd = IndexPath(row: 7, section: 1)
        static let sunriseEnd = IndexPath(row: 8, section: 1)
        static let sunsetStart = IndexPath(row: 9, section: 1)
        static let dawn = IndexPath(row: 10, section: 1)
        static let dusk = IndexPath(row: 11, section: 1)
        static let nauticalDawn = IndexPath(row: 12, section: 1)
        static let nauticalDusk = IndexPath(row: 13, section: 1)
        static let nightStart = IndexPath(row: 14, section: 1)
        static let nightEnd = IndexPath(row: 15, section: 1)
        static let goldenHourEnd = IndexPath(row: 16, section: 1)
        static let goldenHourStart = IndexPath(row: 17, section: 1)
        
        // Moon
        static let moonAltitudeIndex = IndexPath(row: 0, section: 2)
        static let moonAzimuthIndex = IndexPath(row: 1, section: 2)
        static let moonDistanceIndex = IndexPath(row: 2, section: 2)
        
        // Moon Phase
        static let moonFractionOfMoonIlluminatedIndex = IndexPath(row: 3, section: 2)
        static let moonPhaseIndex = IndexPath(row: 4, section: 2)
        static let moonAngleIndex = IndexPath(row: 5, section: 2)
        
        // Moon Rise and Set
        static let moonRiseIndex = IndexPath(row: 6, section: 2)
        static let moonSetIndex = IndexPath(row: 7, section: 2)
        
        
        // Sun Rise And Set
        
        // Sections
        static let sections = ["Informations", "Sun", "Moon"]
        
    }
    
    // MARK: - IBOutlets
    @IBOutlet var tableView: UITableView!
    
    // MARK: - Vars
    
    let locationManager = CLLocationManager()
    
    var currentCoordinate: CLLocationCoordinate2D? {
        didSet {
            updateData()
        }
    }
    fileprivate var informations: [[String]] = [["Date", "Latitude", "longitude"],
                                                
                                                
                                                ["Altitude", "Azimuth", "Rise", "Set", "Solar Noon", "Nadir",
                                                 "sunriseStart", "sunsetEnd", "sunriseEnd", "sunsetStart",
                                                 "dawn", "dusk", "nauticalDawn", "nauticalDusk",
                                                 "nightEnd", "nightStart", "goldenHourEnd", "goldenHourStart"],
                                                
                                                ["Altitude", "Azimuth", "Distance", "Fraction Illuminated", "Phase", "Angle", "Rise", "Set"]]
    
    
    
    // MARK: - View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // USE GPS
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.delegate = self
        
    }
    
    
    // MARK: - IBActions
    
    
    @IBAction func buttonUpdateTouchUp() {
        locationManager.startUpdatingLocation()
    }
    
    // MARK: - Formatters
    
    func formattedDate (_ date: Date) -> String {
        return DateFormatter.localizedString(from: date, dateStyle: .short, timeStyle: .short)
    }
    
    func formattedDecimal(_ n: Double) -> String {
        // Formatter
        let decimalFormatter = NumberFormatter()
        decimalFormatter.maximumFractionDigits = 2
        decimalFormatter.minimumIntegerDigits = 1
        
        guard let result =  decimalFormatter.string(from: NSNumber(value: n)) else { return "" }
        
        return result
    }
    
    
    // MARK: - Update Data
    
    func updateData() {
        
        // Only if there is a valid currentCoordinates
        guard let currentCoordinate = currentCoordinate else { return }
        
        let now = Date()
        
        
        // MARK: Informations
        // --------------------
        
        // Date
        informations [k.dateIndex.section] [k.dateIndex.row] = "Date : \(formattedDate(now))"
        
        // Latitute
        informations [k.latituteIndex.section] [k.latituteIndex.row] = "Latitute : \(formattedDecimal(currentCoordinate.latitude))"
        
        // Longitude
        informations [k.longitudeIndex.section] [k.longitudeIndex.row] = "Longitude : \(formattedDecimal(currentCoordinate.longitude))"
        
        
        // MARK: Moon Position
        // --------------------
        
        let moonPosition = RSSunAndMoonCalc.moonPosition(date: now, location: currentCoordinate)
        
        // Altitude
        informations [k.moonAltitudeIndex.section] [k.moonAltitudeIndex.row] = "Altitude : \(formattedDecimal(moonPosition.altitude))"
        
        // Azimuth
        informations [k.moonAzimuthIndex.section] [k.moonAzimuthIndex.row] = "Azimuth : \(formattedDecimal(moonPosition.azimuth))"
        
        // Distance
        informations [k.moonDistanceIndex.section] [k.moonDistanceIndex.row] = "Distance : \(formattedDecimal(moonPosition.distance)) km"
        
        
        
        // MARK: Moon Phase
        // -----------------
        
        let moonPhase = RSSunAndMoonCalc.moonPhase(date: now)
        
        // Fraction Of Moon Illuminated
        informations [k.moonFractionOfMoonIlluminatedIndex.section] [k.moonFractionOfMoonIlluminatedIndex.row] = "Fraction  Illuminated : \(formattedDecimal(moonPhase.fractionOfMoonIlluminated)) %"
        
        // Moon Phase
        informations [k.moonPhaseIndex.section] [k.moonPhaseIndex.row] = "Moon Phase : \(formattedDecimal(moonPhase.phase))"
        
        // Moon Angle
        informations [k.moonAngleIndex.section] [k.moonAngleIndex.row] = "Angle: \(formattedDecimal(moonPhase.angle)) rad."
        
        
        // MARK: Moon Rise and Set
        // ------------------------
        
        let moonRiseAndSet = RSSunAndMoonCalc.moonRiseAndSet(date: now, location: currentCoordinate)
        
        // Rise
        informations [k.moonRiseIndex.section] [k.moonRiseIndex.row] = "Rise: \(formattedDate(moonRiseAndSet.rise))"
        
        // Set
        informations [k.moonSetIndex.section] [k.moonSetIndex.row] = "Set: \(formattedDate(moonRiseAndSet.set))"
        
        
        // MARK: Sun Position
        // --------------------
        
        let sunPosition = RSSunAndMoonCalc.sunPosition(date: now, location: currentCoordinate)
        
        // Altitude
        informations [k.sunAltitudeIndex.section] [k.sunAltitudeIndex.row] = "Altitude: \(formattedDecimal(sunPosition.altitude)) rad."
        
        // Azimuth
        informations [k.sunAzimuthIndex.section] [k.sunAzimuthIndex.row] = "Azimuth: \(formattedDecimal(sunPosition.azimuth)) rad."
        
        
        // MARK: Sun Rise and Set
        // ------------------------
        
        let sunRiseAndSet = RSSunAndMoonCalc.sunRiseAndSet(date: now, location: currentCoordinate)
        
        // SunRise
        informations [k.sunRiseIndex.section] [k.sunRiseIndex.row] = "Rise: \(formattedDate(sunRiseAndSet.rise))"
        
        // Sun Set
        informations [k.sunSetIndex.section] [k.sunSetIndex.row] = "Set: \(formattedDate(sunRiseAndSet.set))"
        
        // Solar Noon
        informations [k.solarNoonIndex.section] [k.solarNoonIndex.row] = "Solar Noon: \(formattedDate(sunRiseAndSet.solarNoon))"
        
        // Nadir
        informations [k.nadirIndex.section] [k.nadirIndex.row] = "Nadir: \(formattedDate(sunRiseAndSet.nadir))"
        
        // MARK: Sun significant dates
        // -----------------------------
        let sunSignificantTimes = RSSunAndMoonCalc.sunSignificantTimes(date: now, location: currentCoordinate)
        
        if let d = sunSignificantTimes ["sunriseStart"] {
            informations [k.sunriseStart.section] [k.sunriseStart.row] = "Sunrise Start: \(formattedDate(d))"
        }
        
        if let d = sunSignificantTimes ["sunsetEnd"] {
            informations [k.sunsetEnd.section] [k.sunsetEnd.row] = "Sunset End: \(formattedDate(d))"
        }
        
        if let d = sunSignificantTimes ["sunriseEnd"] {
            informations [k.sunriseEnd.section] [k.sunriseEnd.row] = "Sunrise End: \(formattedDate(d))"
        }
        
        if let d = sunSignificantTimes ["sunsetStart"] {
            informations [k.sunsetStart.section] [k.sunsetStart.row] = "Sunset Start: \(formattedDate(d))"
        }
        
        if let d = sunSignificantTimes ["dawn"] {
            informations [k.dawn.section] [k.dawn.row] = "Dawn: \(formattedDate(d))"
        }
        
        if let d = sunSignificantTimes ["dusk"] {
            informations [k.dusk.section] [k.dusk.row] = "Dusk: \(formattedDate(d))"
        }
        
        if let d = sunSignificantTimes ["nauticalDawn"] {
            informations [k.nauticalDawn.section] [k.nauticalDawn.row] = "Nautical Dawn: \(formattedDate(d))"
        }
        
        if let d = sunSignificantTimes ["nauticalDusk"] {
            informations [k.nauticalDusk.section] [k.nauticalDusk.row] = "Nautical Dusk: \(formattedDate(d))"
        }
        
        if let d = sunSignificantTimes ["nightEnd"] {
            informations [k.nightEnd.section] [k.nightEnd.row] = "Night End: \(formattedDate(d))"
        }
        
        if let d = sunSignificantTimes ["nightStart"] {
            informations [k.nightStart.section] [k.nightStart.row] = "Night Start: \(formattedDate(d))"
        }
        
        if let d = sunSignificantTimes ["goldenHourEnd"] {
            informations [k.goldenHourEnd.section] [k.goldenHourEnd.row] = "Golden Hour End: \(formattedDate(d))"
        }
        
        if let d = sunSignificantTimes ["goldenHourStart"] {
            informations [k.goldenHourStart.section] [k.goldenHourStart.row] = "Golden Hour Start: \(formattedDate(d))"
        }
        
        
        // Refresh Table view
        tableView.reloadData()
    }
    
}


extension ViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return informations.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return informations[section].count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return k.sections[section]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: k.cellIdentifier,
                                                 for: indexPath)
        
        
        cell.textLabel?.text = informations[indexPath.section][indexPath.row]
        return cell
    }
    
}

// MARK: - CLLocationManagerDelegate

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let currentLocation = locations.last {
            
            // Set currentCoordinates
            currentCoordinate = currentLocation.coordinate
            
            // Stop location update (preserving battery)
            self.locationManager.stopUpdatingLocation()
        }
    }
    
}
