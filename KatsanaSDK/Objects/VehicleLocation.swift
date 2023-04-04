//
//  VehicleLocation.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 26/01/2017.
//  Copyright © 2017 pixelated. All rights reserved.
//

import CoreLocation

open class VehicleLocation: Codable, Equatable{
    public static func == (lhs: VehicleLocation, rhs: VehicleLocation) -> Bool {
        if lhs.latitude == rhs.latitude, lhs.longitude == rhs.longitude, lhs.speed == rhs.speed{
            return true
        }
        return false
    }
    
    enum CodingKeys: CodingKey{
        case latitude
        case longitude
        case speed
        case altitude
        case course
        case magneticHeading
        case magneticHeadingAccuracy
        case distance
        case state
        case voltage
        case gsm
        case ignitionState
        case verticalAccuracy
        case horizontalAccuracy
        case trackedAt
    }
    
    open var latitude: Double
    open var longitude: Double
    open var speed: Float = 0
    open var altitude: Double = 0
    open var course: Double = 0
    open var magneticHeading: Float = -1
    open var magneticHeadingAccuracy: Float = 0
    ///Distance to previous location
    open var distance: Float = 0
    
    open var state: String!
    open var voltage: String!
    open var gsm: String!
    open var ignitionState: Bool = false
    open var verticalAccuracy: Float = 0
    open var horizontalAccuracy: Float = 0
    
    private(set) open var address: String?
    private(set) open var addressObject: KTAddress?
    
    public let trackedAt: Date
    ///Extra data that user can save to vehicle location. Should have only value with codable support.
    open var extraData = [String: Any]()
    
    public init(latitude: Double, longitude: Double, trackedAt: Date) {
        self.latitude = latitude
        self.longitude = longitude
        self.trackedAt = trackedAt
    }
    
    open func coordinate() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2DMake(latitude, longitude)
    }
    
    private var _lastCoordinate: CLLocationCoordinate2D!
    //Get address for current location
    open func address(completion: @escaping (String?) -> Void) {
        if let _lastCoordinate = _lastCoordinate, _lastCoordinate.equal(coordinate()) {
            completion(address)
            return
        }else{
            KatsanaAPI.shared.requestAddress(for: coordinate(), completion: { (address) in
                self._lastCoordinate = self.coordinate()
                self.address = address?.optimizedAddress()
                self.addressObject = address
                completion(self.address)
            })
        }
    }
    
    //Get address for current location
    open func addressObject(completion: @escaping (KTAddress?) -> Void) {
        if let _lastCoordinate = _lastCoordinate, _lastCoordinate.equal(coordinate()), let addressObject = addressObject, addressObject.pointOfInterest().count > 0 {
            completion(addressObject)
            return
        }else{
            KatsanaAPI.shared.requestAddress(for: coordinate(), completion: { (address) in
                self._lastCoordinate = self.coordinate()
                self.address = address?.optimizedAddress()
                self.addressObject = address
                completion(self.addressObject)
            })
        }
    }
    
    
    //Get address for current location
    open func fullAddress(completion: @escaping (String?) -> Void) {
        if let addressObject = addressObject, addressObject.coordinate().equal(coordinate()){
            completion(addressObject.fullAddress())
        }else{
            KatsanaAPI.shared.requestAddress(for: coordinate(), completion: { (address) in
                let fullAddress = address?.fullAddress()
                self.addressObject = address
                completion(fullAddress)
            })
        }
    }
    
    // MARK: Text
    
    open func speedString() -> String {
        return KatsanaFormatter.speedStringFrom(knot: Double(speed))
    }
    
    // MARK: Logic
    
    ///Returns localized speed, depends on user settings at KatsanaFormatter
    open func localizedSpeed() -> Float {
        return Float(KatsanaFormatter.localizedSpeed(knot: Double(speed)))
    }
    
    ///Check if location equal to other location. Small distance between coordinates still considered as equal
    open func locationEqualTo(location: VehicleLocation) -> Bool {
        let coord = coordinate()
        let otherCoord = location.coordinate()
        return coord.equal(otherCoord)
    }
    
    ///Check if location equal to other location. Check exact coordinates values between locations
    open func locationExactEqualTo(location: VehicleLocation) -> Bool {
        let coordinate = location.coordinate()
        if latitude == coordinate.latitude, longitude == coordinate.longitude {
            return true
        }
        return false
    }
    
    open func locationEqualTo(coordinate: CLLocationCoordinate2D) -> Bool {
        return coordinate.equal(self.coordinate())
    }
    
    open func locationExactEqualTo(coordinate: CLLocationCoordinate2D) -> Bool {
        if latitude == coordinate.latitude, longitude == coordinate.longitude {
            return true
        }
        return false
    }
    
    ///Returns the distance (in meters) from the receiver’s location to the specified location.
    open func distanceTo(location: VehicleLocation) -> Float {
        return distanceTo(coordinate: location.coordinate())
    }
    
    ///Returns the distance (in meters) from the receiver’s location to the specified location.
    open func distanceTo(coordinate: CLLocationCoordinate2D) -> Float {
        let location = CLLocation(latitude: latitude, longitude: longitude)
        let otherLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let distance = location.distance(from: otherLocation)
        return Float(distance)
    }
    
    func localizedTrackedAt() -> Date! {
        guard trackedAt != nil else {
            return nil
        }
        
        let timezoneOffset = NSTimeZone.system.secondsFromGMT(for: trackedAt)
        let date = trackedAt.addingTimeInterval(TimeInterval(timezoneOffset))
        return date
    }
}


