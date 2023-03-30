//
//  Vehicle.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 26/01/2017.
//  Copyright © 2017 pixelated. All rights reserved.
//
import Foundation

public struct TemperatureSensor: Codable, Equatable{
    public let value: Float
    public let status: String?
}

public struct FuelSensor: Codable, Equatable{
    public let litre: Float
    public let percentage: Float
    public let capacity: Float
    public let status: String?
}

public class KTVehicle: Codable {
    
    static let defaultImagePath = "default.marker.jpg"
    static var defaultImage: KMImage!
    
    static let dateFormatter : DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    public let vehicleId: Int
    ///Owner id for this vehicle
    public let userId : Int?
    ///Imei of the beacon
    public let imei : String
    public let fleetIds: [Int]
    public let features: [String]?
    public let websocketSupported: Bool
    
    public var temperatureSensor: TemperatureSensor?
    public var fuelSensor: FuelSensor?
    public var sensors: [Sensor]?
    
    public var vehicleDescription: String
    public var vehicleNumber: String
    
    public var mode: String!
    public var todayMaxSpeed: Float
    public var odometer: Double
    ///Date when this vehicle subscription ended
    public var subscriptionEnd: Date?
    public var timezone: String?
    public var imageURL: String?
    public var thumbImageURL: String?
    public var current: VehicleLocation?
    public var earliestTravelDate: Date?
    
    public var driver: String?

    public var videoRecording: VideoRecording?
    ///State that shows if the vehicle supports MDVR.
    public var requestVideoRecordingDate: Date?
    
    public var manufacturer: String?
    public var model: String?
    public var insuredBy: String?
    public var insuredExpiry: Date?
    
    public init(vehicleId: Int, userId: Int?, imei: String, fleetIds: [Int] = [], features: [String]? = nil, websocketSupported: Bool = false) {
        self.vehicleId = vehicleId
        self.userId = userId
        self.imei = imei
        self.fleetIds = fleetIds
        self.features = features
        self.websocketSupported = websocketSupported
        self.vehicleNumber = ""
        self.vehicleDescription = ""
        self.todayMaxSpeed = 0
        self.odometer = 0
    }
    
    ///Reload data given new vehicle data
    public func reload(with vehicle: KTVehicle) {
        guard userId == vehicle.userId, vehicleId == vehicle.vehicleId else {
            return
        }
        
        vehicleDescription = vehicle.vehicleDescription
        mode = vehicle.mode
        current = vehicle.current
        imageURL = vehicle.imageURL
        thumbImageURL = vehicle.thumbImageURL
        todayMaxSpeed = vehicle.todayMaxSpeed
        odometer = vehicle.odometer
        subscriptionEnd = vehicle.subscriptionEnd
        insuredExpiry = vehicle.insuredExpiry
        insuredBy = vehicle.insuredBy
        vehicleNumber = vehicle.vehicleNumber
        model = vehicle.model
        manufacturer = vehicle.manufacturer
        fuelSensor = vehicle.fuelSensor
        temperatureSensor = vehicle.temperatureSensor
        sensors = vehicle.sensors
        driver = vehicle.driver
        if let date = vehicle.requestVideoRecordingDate{
            self.requestVideoRecordingDate = date
        }
        if let videoRecording = vehicle.videoRecording{
            self.videoRecording = videoRecording
        }
    }
    
    ///Reload video recording data given the vehicle data
    public func reloadVideoRecordingData(with vehicle: KTVehicle) {
        guard userId == vehicle.userId, vehicleId == vehicle.vehicleId else {
            return
        }
        if let date = vehicle.requestVideoRecordingDate{
            self.requestVideoRecordingDate = date
        }
        if let videoRecording = vehicle.videoRecording{
            self.videoRecording = videoRecording
        }
    }
    
    func jsonPatch() -> [String: Any] {
        var dicto = [String: Any]()
        dicto["description"] = vehicleDescription
        dicto["vehicle_number"] = vehicleNumber        
        return dicto
    }
    
    // MARK: Image
    
    public func updateImage(_ image: KMImage) {
//        self.image = image
    }
    
    public func date(from string: String) -> Date! {
        return KTVehicle.dateFormatter.date(from: string)
    }
    
}

extension KTVehicle{
    public func availableSensorTitles() -> [String] {
        guard let sensors else {return []}
        
        var titles = [String]()
        for sensor in sensors{
            if sensor.sensorType == .door{
                titles.append("door")
            }
            else if sensor.sensorType == .arm{
                titles.append("arm")
            }
        }
        if fuelSensor != nil{
            titles.append("fuel")
        }
        if temperatureSensor != nil{
            titles.append("temperature")
        }
        return titles
    }
    
    public func availableSensorValues() -> [String] {
        guard let sensors else {return []}
        
        var values = [String]()
        for sensor in sensors{
            if sensor.sensorType == .door{
                if sensor.event == "open"{
                    values.append("Open")
                }else{
                    values.append("Closed")
                }
            }
            else if sensor.sensorType == .arm{
                if sensor.event == "active"{
                    values.append("On")
                }else{
                    values.append("Off")
                }
            }
        }
        if let fuelSensor{
            values.append(String(format: "%.0f%%", fuelSensor.percentage))
        }
        if let temperatureSensor{
            values.append(String(format: "%.1f°C", temperatureSensor.value))
        }
        return values
    }
}

extension KTVehicle: CustomDebugStringConvertible {

    public var debugDescription: String {
        return "KTVehicle(imei: \(imei), vehicleId: \(vehicleId), userId: \(String(describing: userId))"
    }
}

extension KTVehicle: Equatable{
    public static func == (lhs: KTVehicle, rhs: KTVehicle) -> Bool {
        if lhs.imei == rhs.imei, lhs.vehicleId == rhs.vehicleId, lhs.userId == rhs.userId{
            return true
        }
        return false
    }
}
