//
//  RSSunAndMoonCalc.swift
//  RSSunAndMoonCalc
//
//  Created by Sebastien REMY on 23/03/2017.
//  The MIT License (MIT)
//
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.


import CoreLocation

struct RSSunAndMoonCalc {
    
    // MARK: - Constants
    
    private struct k {
        static let obliquityOfEarth = rad * 23.4397 // The obliquity of Earth
        static let rad = Double.pi / 180            // Multiplier for conversion from degrees to radians
        static let J0 = 0.0009                      // A parameter used for finding the time of a solar transit near a Julian Date.
        static let J2000: Double = 2451545          // The number of Julian days at January 1, 2000.
        static let J1970: Double = 2440588          // The number of Julian days at January 1, 1970.
        static let sunDistance = 149598000.0        // 1 AU
        
        // Time constants
        static let secondsByHour: Double = 60 * 60
        static let secondsByDay: Double = secondsByHour * 24
        
        // Various standard altitudes of the sun. Feel free to add your own times, in the same format, 
        // to this array--they'll be added to the returned dictionary.
        static let sunSignificantTimes = [
            [-0.833, "sunriseStart", "sunsetEnd"],
            [-0.3, "sunriseEnd", "sunsetStart"],
            [-6.0, "dawn", "dusk"],
            [-12.0, "nauticalDawn", "nauticalDusk"],
            [-18.0, "nightEnd", "nightStart"],
            [6.0, "goldenHourEnd", "goldenHourStart"]
        ]
        
    }
    
    
    // MARK: - Date/Time Calculations
    
    private static func daysSinceJan12000 (date: Date) -> Double {
        
        /*************************************************************
         / The number of days since the Gregorian year 2000 began.   /
         /                                                           /
         / - parameter date: A date in Unix Time.                    /
         /                                                           /
         / - returns: The number of days since the year 2000.        /
         ********************************************************** */
        
        return toJulian(date: date) - k.J2000
    }
    
    
    private static func hoursLater (date: Date, hours: Double) -> Date {
        
        /*********************************************************************************************
         / Gives a date a certain number of hours after a given date/time.                           /
         /                                                                                           /
         / - parameter date: A date.                                                                 /
         / - parameter hours: The number of hours after the given date/time that will be returned.   /
         /                                                                                           /
         / - returns: An NSDate that is the given number of hours after the given date.              /
         ****************************************************************************************** */
        
        return Date(timeIntervalSince1970: date.timeIntervalSince1970 + hours * k.secondsByHour)
    }
    
    
    private static func toJulian (date: Date) -> Double {
        
        /*****************************************************************************
         / The number of days since the beginning of the Julian Period.              /
         /                                                                           /
         / - parameter date: A Gregorian date.                                       /
         /                                                                           /
         / - returns: The number of days since the beginning of the Julian Period.   /
         ************************************************************************** */
        
        return date.timeIntervalSince1970 / k.secondsByDay - 0.5 + k.J1970
    }
    
    
    private static func fromJulian (julianDays: Double) -> Date {
        
        /*****************************************************************************************
         / The Gregorian date of a given number of Julian Days.                                  /
         /                                                                                       /
         / - parameter julianDays: A number of days since the beginning of the Julian Period.    /
         /                                                                                       /
         / - returns: A Gregorian calendar date from a number of Julian Days.                    /
         /                                                                                       /
         ************************************************************************************** */
        
        return Date(timeIntervalSince1970: (julianDays + 0.5 - k.J1970) * k.secondsByDay)
    }
    
    
    // MARK: -  Position / Trygonometry Calculations
    
    private static func altitude (hourAngle: Double, latitude: Double, declination: Double) -> Double {
        
        /*****************************************************************************************************
         / Calculates the altitude of a celestial body.                                                      /
         /                                                                                                   /
         / - parameter hourAngle: An angle in radians. The hour angle indicates how far the celestial body   /
         /                        has passed beyond the celestial meridian.                                  /
         / - parameter latiude: The latitude of observation in radians.                                      /
         / - parameter declination: The declination in radians.                                              /
         /                                                                                                   /
         / - returns: The altitude above the horizon in radians.                                             /
         ************************************************************************************************** */
        
        return asin(sin(latitude) * sin(declination) + cos(latitude) * cos(declination) * cos(hourAngle))
    }
    
    
    private static func azimuth (hourAngle: Double, latitude: Double, declination: Double) -> Double {
        
        /*************************************************************************************************
         / Calculates the azimuth of a celestial body in radians, measured from South to West.           /
         /                                                                                               /
         / - parameter hourAngle: An angle in radians, measured. The hour angle indicates                /
         /                        how far the celestial body has passed beyond the celestial meridian.   /
         / - parameter latiude: The latitude of observation in radians.                                  /
         / - parameter declination: The declination in radians.                                          /
         /                                                                                               /
         / - returns: The azimuth of the body in radians, measured from South to West.                   /
         /            Note that it it standard to measure from North to East;                            /
         /            simply add/subtract .pi to the result if you need to conform.)                     /
         ********************************************************************************************** */
        
        return atan2(sin(hourAngle), cos(hourAngle) * sin(latitude) - tan(declination) * cos(latitude))
    }
    
    
    private static func declination (latitude: Double, longitude: Double) -> Double {
        
         /*******************************************************
         / Calculates declination given latitude and longitude. /
         /                                                      /
         / - parameter latitude: The latitude in radians.       /
         / - parameter longitude: The longitude in radians.     /
         /                                                      /
         / - returns: The declination in radians.               /
         ***************************************************** */
        
        return asin(sin(latitude) * cos(k.obliquityOfEarth) + cos(latitude) * sin(k.obliquityOfEarth) * sin(longitude))
    }
    
    
    private static func rightAscension (latitude: Double, longitude: Double) -> Double {
         /************************************************************
         / Calculates right ascension given latitude and longitude.  /
         /                                                           /
         / - parameter latitude: The latitude in radians.            /
         / - parameter longitude: The longitude in radians.          /
         /                                                           /
         / - returns: The right asnension in radians.                /
         ********************************************************** */
        
        return atan2(sin(longitude) * cos(k.obliquityOfEarth) - tan(latitude) * sin(k.obliquityOfEarth), cos(longitude))
    }
    

    private static func siderealTime (daysSinceJan12000: Double, longitude: Double) -> Double {
        /******************************************************************************
        / The sidereal time.                                                          /
        /                                                                             /
        / - parameter daysSinceJan12000: The number of days since January 1, 2000.    /
        / - parameter longitude: The longitude west of the prime meridian in radians. /
        /                                                                             /
        / - returns: The sidereal time in radians.                                    /
        **************************************************************************** */
        
        return k.rad * (280.16 + 360.9856235 * daysSinceJan12000) - longitude
    }
    
    
    // MARK: - Moon Private Calculations
    
    private static func moonCoordinates (daysSinceJan12000: Double) -> (declination: Double, distance: Double, rightAscension: Double) {
        
         /*******************************************************************************************
         / The geocentric ecliptic coordinates of the moon.                                         /
         /                                                                                          /
         / - parameter daysSinceJan12000: The number of days since Jan 1, 2000.                     /
         /                                                                                          /
         / - returns: The right ascension ; declination in radians ; the distance in kilometers,    /
         /            of the moon for the given date.                                               /
         ***************************************************************************************** */
        
        let eclipticLongitude = k.rad * (218.316 + 13.176396 * daysSinceJan12000)
        let meanAnomaly = k.rad * (134.963 + 13.064993 * daysSinceJan12000)
        let meanDistance = k.rad * (93.272 + 13.229350 * daysSinceJan12000)
        
        let longitude = eclipticLongitude + k.rad * 6.289 * sin(meanAnomaly)
        let latitude = k.rad * 5.128 * sin(meanDistance)
        let distance = 385001 - 20905 * cos(meanAnomaly)
        
        return (declination(latitude: latitude, longitude: longitude),
                distance,
                rightAscension(latitude: latitude, longitude: longitude))
    }
    
    
    // MARK: - Moon Public Calculations

    static func moonPosition(date: Date, location: CLLocationCoordinate2D) -> (altitude: Double, azimuth: Double, distance: Double) {
        
        /*********************************************************************************************
         / The moons position on a given date from a given location.                                 /
         /                                                                                           /
         / - parameter date: A date.                                                                 /
         / - parameter location: A location. Requires CLLocationCoordinate2D to reduce confusion,    /
         /                       as these are in degrees while other methods require radians.        /
         /                                                                                           /
         / - returns: The moon's altitude and azimuth in radians, and distance in kilometers.        /
         ****************************************************************************************** */
        
        let longitude = k.rad * -location.longitude
        let phi = k.rad * location.latitude
        
        let days = daysSinceJan12000(date: date)
        
        let coordinates = moonCoordinates(daysSinceJan12000: days)
        
        let hourAngle = siderealTime(daysSinceJan12000: days, longitude: longitude) - coordinates.rightAscension
        
        var moonAltitude = altitude(hourAngle: hourAngle, latitude: phi, declination: coordinates.declination)
        moonAltitude = moonAltitude + k.rad * 0.017 / tan(moonAltitude + k.rad * 10.26 / (moonAltitude + k.rad * 5.10))
        
        return (moonAltitude,
                azimuth(hourAngle: hourAngle, latitude: phi, declination: coordinates.declination),
                coordinates.distance)
    }
    

    static func moonPhase (date: Date) -> (fractionOfMoonIlluminated: Double, phase: Double, angle: Double) {
        
        /*****************************************************************************************
         / The fraction of the moon's visible surface that is illuminated, its phase,            /
         / and the midpoint angle, going east, of the illuminated limb.                          /
         /                                                                                       /
         / - parameter A: date.                                                                  /
         /                                                                                       /
         / - returns: The fraction of the moon illuminated is a number from 0 to 1,              /
         /            where 0 is a new moon and 1 is a full moon.                                /
         /            The phase is a number from 0 to 1, where 0 and 1 are a new moon,           /
         /            0.5 is a full moon, 0 - 0.5 is waxing, and 0.5 - 1.0 is waning.            /
         / The angle is the midpoint of the illuminated limb of the moon going east, in radians. /
         ************************************************************************************** */
        
        let days = daysSinceJan12000(date: date)
        let sunCoords = sunCoordinates(daysSinceJan12000: days)
        let moonCoords = moonCoordinates(daysSinceJan12000: days)
        
        // Geocentric elongation of the Moon from the Sun
        let phi = acos(sin(sunCoords.declination) * sin(moonCoords.declination) + cos(sunCoords.declination) * cos(moonCoords.declination) * cos(sunCoords.rightAscension - moonCoords.rightAscension))
        
        // Selenocentric elongation of the Earth from the Sun
        let inc = atan2(k.sunDistance * sin(phi), moonCoords.distance - k.sunDistance * cos(phi))
        
        
        let angle = atan2(cos(sunCoords.declination) * sin(sunCoords.rightAscension - moonCoords.rightAscension), sin(sunCoords.declination) * cos(moonCoords.declination) - cos(sunCoords.declination) * sin(moonCoords.declination) * cos(sunCoords.rightAscension - moonCoords.rightAscension))
        
        let fractionOfMoonIlluminated = (1 + cos(inc)) / 2
        
        let phase = 0.5 + 0.5 * inc * (angle < 0 ? -1 : 1) / Double(M_PI)
        
        return (fractionOfMoonIlluminated, phase, angle)
    }
    
    
    static func moonRiseAndSet (date: Date, location: CLLocationCoordinate2D) -> (rise: Date, set: Date) {
        
        /********************************************************************************************
         / The moon's rise and set times for a given date and location.                             /
         /                                                                                          /
         / - parameter date: A date.                                                                /
         / - parameter location: A location. Requires CLLocationCoordinate2D to reduce confusion,   /
         /                       as these are in degrees while other methods require radians.       /
         /                                                                                          /
         / - returns: The rise and set Dates of the moon, if there are any.                         /
         /            If the moon is always up for the given date: returns Date.distantFuture()     /
         /            If the moon is always down for the given date: returns Date.distantPast()     /
         /            for both rise and set.                                                        /
         ***************************************************************************************** */
        
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        var dateComponents = (calendar as NSCalendar).components([.year, .month, .day], from: date)
        dateComponents.hour = 0
        dateComponents.minute = 0
        dateComponents.second = 0
        let day = calendar.date(from: dateComponents)!
        
        let hc = 0.133 * k.rad
        var h0 = moonPosition(date: day, location: location).altitude - hc
        
        var rise : Double?
        var set : Double?
        
        var a:Double, b:Double, d:Double, h1:Double, h2:Double, roots:Int, xe:Double
        var x1 = 0.0, x2 = 0.0, ye = 0.0
        
        for i in stride(from: 1.0, to: 24.0, by: 2.0) {
            
            h1 = moonPosition(date: hoursLater(date: day, hours: i), location: location).altitude - hc
            h2 = moonPosition(date: hoursLater(date: day, hours: i + 1), location: location).altitude - hc
            
            a = (h0 + h2) / 2 - h1
            b = (h2 - h0) / 2
            xe = -b / (2 * a)
            ye = (a * xe + b) * xe + h1
            d = b * b - 4 * a * h1
            
            roots = 0
            
            if d >= 0 {
                
                let dx = sqrt(d) / (abs(a) * 2)
                x1 = xe - dx
                x2 = xe + dx
                if abs(x1) <= 1 { roots += 1 }
                if abs(x2) <= 1 { roots += 1 }
                if x1 < -1 { x1 = x2 }
            }
            
            if roots == 1 {
                
                if h0 < 0 { rise = i + x1 }
                else { set = i + x1 }
                
            } else if roots == 2 {
                
                rise = i + (ye < 0 ? x2 : x1)
                set = i + (ye < 0 ? x1 : x2)
            }
            
            if rise != nil && set != nil { break }
            
            h0 = h2
            
        }
        
        var result = (rise: day, set: day)
        
        if rise != nil { result.rise = hoursLater(date: day, hours: rise!) }
        if set != nil { result.set = hoursLater(date: day, hours: set!) }
        
        if rise == nil && set == nil {
            
            if ye > 0 {
                
                result.rise = Date.distantFuture
                result.set = Date.distantFuture
                
            } else {
                
                result.rise = Date.distantPast
                result.set = Date.distantPast
            }
        }
        
        return result
    }
    
    
    // MARK: - Sun Private Calculations
    
    private static func approximateTransit (julianCycleNumber: Double, longitude: Double, targetHourAngle: Double) -> Double {
        
        /************************************************************************************************
         / The approximate solar transit, the time at which it passes through the celestial meridian.   /
         /                                                                                              /
         / - parameter julianCycleNumber: The Julian cycle number.                                      /
         / - parameter longitude: The longitude in radians.                                             /
         / - parameter targetHourAngle: The target hour angle.                                          /
         /                                                                                              /
         / - returns: The approximate solar transit.                                                    /
         ********************************************************************************************* */
        
        return k.J0 + julianCycleNumber + (targetHourAngle + longitude) / (2 * .pi)
    }
    
    
    private static func eclipticLongitude (meanAnomaly: Double) -> Double {
        
        /********************************************************************************************
         / The ecliptic longitude: the position along the ecliptic relative to the vernal equinox.  /
         /                                                                                          /
         / - parameter meanAnomaly: The mean anomaly: the positon a planet/satellite                /
         /                          would have relative to its perihelion                           /
         /                          if the orbit of the planet were a circle.                       /
         /                                                                                          /
         / - returns: The ecliptic longitude in radians.                                            /
         ***************************************************************************************** */
        
        // Equation of Center
        let center = k.rad * (1.9148 * sin(meanAnomaly) + 0.02 * sin(2 * meanAnomaly) + 0.0003 * sin(3 * meanAnomaly))
        
        // Perihelion of Earth
        let perihelion = k.rad * 102.9372
        
        return meanAnomaly + center + perihelion + .pi
    }
    
    
    private static func hourAngle (altitude: Double, latitude: Double, declination: Double) -> Double {
        
        /***************************************************************************************
         / The hour angle: The difference in right ascension between a body and the meridian of /
         /                 right ascension that is due south at that time.                      /
         /                                                                                      /
         / - parameter altitude: The altitude of the body.                                      /
         / - parameter latitude: The latitude of the body.                                      /
         / - paremeter declination: The declination.                                            /
         /                                                                                      /
         / - returns: The hour angle in radians.                                                /
         ************************************************************************************* */
        
        return acos((sin(altitude) - sin(latitude) * sin(declination)) / (cos(latitude) * cos(declination)))
    }
    
    
    private static func julianCycle (daysSinceJan12000: Double, longitude: Double) -> Double {
        
        /***************************************************************************
         / The Julian cycle number. (See http:aa.quae.nl/en/reken/zonpositie.html ) /
         /                                                                          /
         / - parameter daysSinceJan12000: The number of days since January 1, 2000. /
         / - parameter longitude: The longitude in radians.                         /
         /                                                                          /
         / - returns: The Julian cycle number.                                      /
         ************************************************************************* */
        
        return round(daysSinceJan12000 - k.J0 - longitude / (2 * .pi))
    }
    

    private static func julianSet (altitude: Double, declination: Double, latitude: Double, longitude: Double, julianCycleNumber: Double, meanAnomaly: Double, meanLongitude: Double) -> Double {
        
        /********************************************************************
         / The Julian time of the sunset.                                   /
         /                                                                  /
         / - parameter altitude: The altitude of the sun in radians.        /
         / - parameter declination: The declination of the sun in radians.  /
         / - parameter latitude: The latitude in radians.                   /
         / - parameter longitude: The longitude in radians.                 /
         / - parameter julianCycleNumber: The Julian cycle number.          /
         / - parameter meanAnomaly: The mean anomaly.                       /
         / - parameter meanLongitude: The mean longitude.                   /
         /                                                                  /
         / - returns: The Julian time of the sunset.                        /
         ***************************************************************** */
        
        let hrAngle = hourAngle(altitude: altitude, latitude: latitude, declination: declination)
        let approxTransit = approximateTransit(julianCycleNumber: julianCycleNumber, longitude: longitude, targetHourAngle: hrAngle)
        
        return julianSolarTransit(approximateTransit: approxTransit, longitude: meanLongitude, meanAnomaly: meanAnomaly)
    }
    

    private static func julianSolarTransit (approximateTransit: Double, longitude: Double, meanAnomaly: Double) -> Double {
        
        /********************************************************************
         / The Julian date of the solar transit.                            /
         /                                                                  /
         / - parameter approximateTransit: The approximate solar transit.   /
         / - parameter meanLongitude: The mean longitude in radians.        /
         / - parameter meanAnomaly: The mean anomaly in radians.            /
         /                                                                  /
         / - returns: The Julian date of the solar transit.                 /
         ***************************************************************** */
        
        return k.J2000 + approximateTransit + 0.0053 * sin(meanAnomaly) - 0.0069 * sin(2 * longitude)
    }
    
    
    private static func solarMeanAnomaly (daysSinceJan12000: Double) -> Double {
        
        /****************************************************************************
         / The solar mean anomaly.                                                  /
         /                                                                          /
         / - parameter daysSinceJan12000: The number of days since January 1, 2000. /
         / - returns: The solar mean anomaly in radians.                            /
         /                                                                          /
         ************************************************************************* */
        
        return k.rad * (357.5291 + 0.98560028 * daysSinceJan12000)
    }
    
    
    private static func sunCoordinates (daysSinceJan12000: Double) -> (declination: Double, rightAscension: Double) {
        
        /****************************************************************************
         / The sun's right ascension and declination on a given day.                /
         /                                                                          /
         / - parameter daysSinceJan12000: The number of days since January 1, 2000. /
         /                                                                          /
         / - returns: The sun's right ascension and declination in radians.         /
         ************************************************************************* */
        
        let solarMA = solarMeanAnomaly(daysSinceJan12000: daysSinceJan12000)
        let eLongitude = eclipticLongitude(meanAnomaly: solarMA)
        
        return (declination(latitude: 0, longitude: eLongitude), rightAscension(latitude: 0, longitude: eLongitude))
        
    }
    

    // MARK: - Sun Public Calculations
    
    static func sunPosition (date: Date, location: CLLocationCoordinate2D) -> (altitude: Double, azimuth: Double) {
    
        /************************************************************************************
         / The sun's position on a given date from a given location.                        /
         /                                                                                  /
         / - parameter date: A date.                                                        /
         / - parameter A: location. Requires CLLocationCoordinate2D to reduce confusion,    /
         /                as these are in degrees while other methods require radians.      /
         /                                                                                  /
         / - returns: The sun's azimuth and altitude in radians.                            /
         /            Note: simply add/subtract .pi to the result if you need to conform.   /
         ********************************************************************************* */
        
        let longitude = k.rad * -location.longitude
        let latitude = k.rad * location.latitude
        let days = daysSinceJan12000(date: date)
        
        let coordinates = sunCoordinates(daysSinceJan12000: days)
        let hourAngle = siderealTime(daysSinceJan12000: days, longitude: longitude) - coordinates.rightAscension
        
        return (altitude(hourAngle: hourAngle, latitude: latitude, declination: coordinates.declination),
                azimuth(hourAngle: hourAngle, latitude: latitude, declination: coordinates.declination))
    }
    

    static func sunRiseAndSet (date: Date, location: CLLocationCoordinate2D) -> (rise: Date, set: Date, solarNoon: Date, nadir: Date) {

        /******************************************************************************************
         / The sun's times of rise and set for a given date and location.                         /
         /                                                                                        /
         / - parameter date: A date.                                                              /
         / - parameter location: A location.                                                      /
         /                                                                                        /
         / - returns: The sun's rise, set, solar noon, and nadir for the given date and location. /
         *************************************************************************************** */
        
        // Standard altitude of the end of sunrise and start of sunset
        let sunRiseEndSetStartAltitude = -0.3
        
        let longitude = k.rad * -location.longitude
        let latitude = k.rad * location.latitude
        
        let days = daysSinceJan12000(date: date)
        let julCycle = julianCycle(daysSinceJan12000: days, longitude: longitude)
        let approxTransit = approximateTransit(julianCycleNumber: julCycle, longitude: longitude, targetHourAngle: 0)
        
        let meanAnomaly = solarMeanAnomaly(daysSinceJan12000: days)
        let eclipLongitude = eclipticLongitude(meanAnomaly: meanAnomaly)
        let declinatn = declination(latitude: 0, longitude: eclipLongitude)
        
        let julianNoon = julianSolarTransit(approximateTransit: approxTransit, longitude: eclipLongitude, meanAnomaly: meanAnomaly)
        
        let solarNoon = fromJulian(julianDays: julianNoon)
        let nadir = fromJulian(julianDays: julianNoon - 0.5)
        var result = (rise: date, set: date, solarNoon: solarNoon, nadir: nadir)
        
        var julinSet:Double, julianRise:Double
        
        julinSet = julianSet(altitude: k.rad * sunRiseEndSetStartAltitude,
                             declination: declinatn,
                             latitude: latitude,
                             longitude: longitude,
                             julianCycleNumber: julCycle,
                             meanAnomaly: meanAnomaly,
                             meanLongitude: eclipLongitude)
        
        julianRise = julianNoon - (julinSet - julianNoon)
        
        result.rise = fromJulian(julianDays: julianRise)
        result.set = fromJulian(julianDays: julinSet)
        
        return result
    }
    

    static func sunSignificantTimes (date: Date, location: CLLocationCoordinate2D) -> [String: Date] {
        
        /************************************************************************************
         / Various significant times related to the sun's altitude.                         /
         /                                                                                  /
         / - parameter date: A date.                                                        /
         / - parameter location: A location.                                                /
         /                                                                                  /
         / - returns: The method returns a dictionary of significant times during the day.  /
         /           The time are accessed via a String and given as an Date.               /
         ********************************************************************************* */
        
        let longitude = k.rad * -location.longitude
        let latitude = k.rad * location.latitude
        
        let days = daysSinceJan12000(date: date)
        let julCycle = julianCycle(daysSinceJan12000: days, longitude: longitude)
        let approxTransit = approximateTransit(julianCycleNumber: julCycle, longitude: longitude, targetHourAngle: 0)
        
        let meanAnomaly = solarMeanAnomaly(daysSinceJan12000: days)
        let eclipLongitude = eclipticLongitude(meanAnomaly: meanAnomaly)
        let declinatn = declination(latitude: 0, longitude: eclipLongitude)
        
        let julianNoon = julianSolarTransit(approximateTransit: approxTransit, longitude: eclipLongitude, meanAnomaly: meanAnomaly)
        
        var result = [String: Date]()
        
        var julianEnd=0.0, julianStart:Double
        
        for i in 0...k.sunSignificantTimes.count - 1 {
            
            let time = k.sunSignificantTimes[i]
            
            if let altitude = time[0] as? Double {
                julianEnd = julianSet(altitude: k.rad * altitude,
                                      declination: declinatn,
                                      latitude: latitude,
                                      longitude: longitude,
                                      julianCycleNumber: julCycle,
                                      meanAnomaly: meanAnomaly,
                                      meanLongitude: eclipLongitude)
            }
            
            julianStart = julianNoon - (julianEnd - julianNoon)
            
            if let earlierTime = time[1] as? String {
                result[earlierTime] = fromJulian(julianDays: julianStart)
            }
            if let laterTime = time[2] as? String {
                result[laterTime] = fromJulian(julianDays: julianEnd)
            }
        }
        
        return result
    }
}
