//
//  Vehicle.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 26/01/2017.
//  Copyright © 2017 pixelated. All rights reserved.
//

open class KTVehicle: Codable {
    
    enum CodingKeys: CodingKey{
        case userId
        case vehicleId
        case vehicleNumber
        case vehicleDescription
        case imei
        case mode
        case todayMaxSpeed
        case odometer
        case subscriptionEnd
        case websocketSupported
        case timezone
        case imageURL
        case thumbImageURL
        case current
        case driver
        case fuelLitre
        case fuelPercentage
        case fuelCapacity
        case fuelStatus
        case temperatureValue
        case temperatureStatus
        case videoRecording
        case requestVideoRecordingDate
        case fleetIds
        case model
        case insuredBy
        case insuredExpiry
        case manufacturer
    }
    
    static let defaultImagePath = "default.marker.jpg"
    static var handledDefaultImage = false
    static var defaultImage: KMImage!
    
    static let dateFormatter : DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    ///Owner id for this vehicle
    open var userId : String!
    open var vehicleId: String!
    open var vehicleDescription = ""
    open var vehicleNumber = ""
    ///Imei of the beacon
    open var imei : String!
    open var mode: String!
    open var todayMaxSpeed: Float = 0
    open var odometer: Double = 0
    ///Date when this vehicle subscription ended
    open var subscriptionEnd: Date!
    open var websocketSupported = false
    open var timezone: String!
    open var imageURL: String!
    open var thumbImageURL: String!
    open var current: VehicleLocation!
    open var earliestTravelDate: Date!
    
    open var driver: String!
    
    //Sensors
    open var fuelLitre: Float = -1
    open var fuelPercentage: Float = -1
    open var fuelCapacity: Float = -1
    open var fuelStatus: String!
    open var temperatureValue: Float = -1
    open var temperatureStatus: String!
    open var sensors = [Sensor]()
    
    open var videoRecording: VideoRecording!
    ///State that shows if the vehicle supports MDVR.
    open var requestVideoRecordingDate: Date!
    
    open var fleetIds = [Int]()
    
    open var manufacturer: String!
    open var model: String!
    open var insuredBy: String!
    open var insuredExpiry: Date!{
        didSet{
            if let insuredExpiry = insuredExpiry {
                let dateStr = KTVehicle.dateFormatter.string(from: insuredExpiry)
                if let insuredExpiryText = insuredExpiryText, dateStr == insuredExpiryText{
                    
                }else{
                    insuredExpiryText = dateStr
                }
            }else{
                insuredExpiryText = ""
            }
            
        }
    }
    open var insuredExpiryText: String!{
        didSet{
            if let insuredExpiryText = insuredExpiryText {
                let date = KTVehicle.dateFormatter.date(from: insuredExpiryText)
                if let insuredExpiry = insuredExpiry, date == insuredExpiry {
                    //Do nothing
                }else if date != nil{
                    insuredExpiry = date
                }
            }else{
                insuredExpiry = nil
            }
        }
    }
    
    ///Extra data that user can save to vehicle. Should have only value with codable support.
    open var extraData = [String: Any]()
    
    private(set) open var image : KMImage!
    private(set) open var thumbImage : KMImage!
    
    private var imageBlocks = [(image: KMImage) -> Void]()
    private var thumbImageBlocks = [(image: KMImage) -> Void]()
    private var isLoadingImage = false
    private var isLoadingThumbImage = false
    
    ///Reload data given new vehicle data
    open func reload(with vehicle: KTVehicle) {
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
        websocketSupported = vehicle.websocketSupported
        image = vehicle.image
        thumbImage = vehicle.thumbImage
        imei = vehicle.imei
        extraData = vehicle.extraData
        insuredExpiry = vehicle.insuredExpiry
        insuredBy = vehicle.insuredBy
        vehicleNumber = vehicle.vehicleNumber
        model = vehicle.model
        manufacturer = vehicle.manufacturer
        fuelPercentage = vehicle.fuelPercentage
        driver = vehicle.driver
        if let date = vehicle.requestVideoRecordingDate{
            self.requestVideoRecordingDate = date
        }
        if let videoRecording = vehicle.videoRecording{
            self.videoRecording = videoRecording
        }
    }
    
    ///Reload video recording data given the vehicle data
    open func reloadVideoRecordingData(with vehicle: KTVehicle) {
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
    
    open func availableSensorTitles() -> [String] {
        var titles = [String]()
        for sensor in sensors{
            if sensor.sensorType == .door{
                titles.append("door")
            }
            else if sensor.sensorType == .arm{
                titles.append("arm")
            }
        }
        if fuelPercentage > -1{
            titles.append("fuel")
        }
        if temperatureValue > -1{
            titles.append("temperature")
        }
        return titles
    }
    
    open func availableSensorValues() -> [String] {
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
        if fuelPercentage > -1{
            values.append(String(format: "%.0f%%", fuelPercentage))
        }
        if temperatureValue > -1{
            values.append(String(format: "%.1f°C", temperatureValue))
        }
        return values
    }
    
//    license_plate: (string, optional) - License Plate
//    description: (string, optional) - Description
//    manufacturer: (string, optional) - KTVehicle Manufacturer
//    model: (string, optional) - KTVehicle Model
//    insured_by: (string, optional) - Insured By
//    insured_expiry: (date, optional) - Insured Expiry Date
    
    
    
    // MARK: Image
    
    open func updateImage(_ image: KMImage) {
        self.image = image
    }
    
    open func reloadImageInBlocks() {
        for block in imageBlocks {
            block(self.image)
        }
    }
    
    open func image(completion: @escaping (_ image: KMImage) -> Void){
        guard imageURL != nil else {
            completion(KTVehicle.emptyImage())
            return
        }
        if KatsanaAPI.shared.vehicleIdWithEmptyImages.contains(vehicleId) {
            completion(KTVehicle.emptyImage())
            return
        }
        
        
        if let image = image {
            completion(image)
        }
        else if let path = NSURL(string: imageURL)?.lastPathComponent, let image = KTCacheManager.shared.image(for: path){
            self.image = image
            completion(image)
        }
        else{
            if isLoadingImage {
                imageBlocks.append(completion)
            }else{
                isLoadingImage = true
                ImageRequest.shared.requestImage(path: imageURL, completion: { (image) in
                    self.image = image
                    self.isLoadingImage = false
                    for block in self.imageBlocks{
                        block(image!)
                    }
                    completion(image!)
                }, failure: { (error) in
                    if let error = error as NSError?{
                        if error.code == 404{ //If not found just set the url as nil
                            self.imageURL = nil
                            self.thumbImageURL = nil
                            KatsanaAPI.shared.vehicleIdWithEmptyImages.append(self.vehicleId)
                        }
                    }
                    KatsanaAPI.shared.log.error("Error requesting vehicle image \(self.vehicleId!)")
                    self.isLoadingImage = false
                    completion(KTVehicle.emptyImage())
                })
            }
        }
    }
    
    static var isLoadingDefaultImage = false
    static private var _emptyImage: KMImage!
    static public func emptyImage() -> KMImage{
        if let image = _emptyImage {
            return image
        }
        let image = KMImage(color: KMColor(red: 238/255, green: 238/255, blue: 238/255, alpha: 1))
        _emptyImage = image
        return image!
    }
   
    open func thumbImage(completion: @escaping (_ image: KMImage) -> Void){
        guard thumbImageURL != nil else {
            completion(KTVehicle.emptyImage())
            return
        }
        if KatsanaAPI.shared.vehicleIdWithEmptyImages.contains(vehicleId) {
            if let image = KTVehicle.defaultImage{
                completion(image)
            }else{
                completion(KTVehicle.emptyImage())
            }
            
            return
        }
        
        if thumbImageURL == nil{
            completion(KTVehicle.emptyImage())
        }
        
        if let image = thumbImage {
            completion(image)
        }
        else if let path = NSURL(string: thumbImageURL)?.lastPathComponent, let image = KTCacheManager.shared.image(for: path){
            completion(image)
        }else{
            if isLoadingThumbImage {
                thumbImageBlocks.append(completion)
            }else{
                if self.thumbImageURL.hasSuffix("default.marker.jpg"){
                    completion(KTVehicle.emptyImage())
                    return
                }
                
                isLoadingThumbImage = true
                ImageRequest.shared.requestImage(path: thumbImageURL, completion: { (image) in
                    if self.thumbImageURL.hasSuffix("default.marker.jpg"){
                        KTVehicle.handledDefaultImage = true
                        KTVehicle.defaultImage = image
                        KTVehicle.isLoadingDefaultImage = true
                    }
                    
                    self.thumbImage = image
                    self.isLoadingThumbImage = false
                    for block in self.thumbImageBlocks{
                        block(image!)
                    }
                    completion(image!)
                }, failure: { (error) in
                    if self.thumbImageURL.hasSuffix("default.marker.jpg"){
                        KTVehicle.handledDefaultImage = true
                        KTVehicle.defaultImage = KTVehicle.emptyImage()
                    }
                    
                    if let error = error as NSError?{
                        if error.code == 404{ //If not found just set the url as nil
                            self.thumbImageURL = nil
                            self.imageURL = nil
                            KatsanaAPI.shared.vehicleIdWithEmptyImages.append(self.vehicleId)
                        }
                    }
                    
//                    KatsanaAPI.shared.log.error("Error requesting vehicle thumb image vehicle id \(self.vehicleId!)")
                    self.isLoadingThumbImage = false
                    completion(KTVehicle.emptyImage())
                })
            }
        }
    }
    
    open func date(from string: String) -> Date! {
        return KTVehicle.dateFormatter.date(from: string)
    }
    
}

extension KTVehicle: Equatable{
    public static func == (lhs: KTVehicle, rhs: KTVehicle) -> Bool {
        return lhs.imei == rhs.imei
    }
}
