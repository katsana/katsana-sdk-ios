//
//  VehicleLocation.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 26/01/2017.
//  Copyright © 2017 pixelated. All rights reserved.
//

import UIKit
import CoreLocation

public class VehicleLocation: NSObject {
    public var latitude: Double
    public var longitude: Double
    public var speed: Float = 0
    public var altitude: Double = 0
    public var course: Double = 0
    ///Distance to previous location
    public var distance: Float = 0
    
    public var state: String!
    public var voltage: String!
    public var gsm: String!
    public var ignitionState: Bool = false
    public var verticalAccuracy: Float = 0
    public var horizontalAccuracy: Float = 0
    
    public var trackedAt: Date!
    ///Extra data that user can save to vehicle location. Should have only value with codable support.
    public var extraData: [String: Any]!
    
    class func fastCodingKeys() -> [Any?] {
        return ["latitude", "longitude", "speed", "altitude", "course", "distance", "verticalAccuracy", "horizontalAccuracy", "state", "voltage", "gsm", "ignitionState", "trackedAt", "extraData"]
    }
    
    init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
    
    func coordinate() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2DMake(latitude, longitude)
    }
    
    private var _lastCoordinate: CLLocationCoordinate2D!
    private var _address: String!
    func address(completion: @escaping (String) -> Void) {
        if let _lastCoordinate = _lastCoordinate, _lastCoordinate.equal(coordinate()) {
            completion(_address)
            return
        }else{
            KatsanaAPI.shared.requestAddress(for: coordinate(), completion: { (address) in
                self._lastCoordinate = self.coordinate()
                self._address = address?.optimizedAddress()
                completion(self._address)
            })
        }
    }
    
    // MARK: Text
    
    func speedString() -> String {
        return KatsanaFormatter.speedStringFrom(knot: Double(speed))
    }
    
    // MARK: Logic
    
    ///Returns localized speed, depends on user settings at KatsanaFormatter
    func localizedSpeed() -> Float {
        return Float(KatsanaFormatter.localizedSpeed(knot: Double(speed)))
    }
    
    func exactEqualTo(_ coordinate: CLLocationCoordinate2D) -> Bool {
        if latitude == coordinate.latitude, longitude == coordinate.longitude {
            return true
        }
        return false
    }
    
    ///Returns the distance (in meters) from the receiver’s location to the specified location.
    func distanceTo(_ coordinate: CLLocationCoordinate2D) -> Float {
        let location = CLLocation(latitude: latitude, longitude: longitude)
        let otherLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let distance = location.distance(from: otherLocation)
        return Float(distance)
    }
}
