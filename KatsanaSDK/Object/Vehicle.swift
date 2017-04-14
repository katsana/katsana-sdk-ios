//
//  Vehicle.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 26/01/2017.
//  Copyright © 2017 pixelated. All rights reserved.
//

open class Vehicle: NSObject {
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
    
    ///Extra data that user can save to vehicle. Should have only value with codable support.
    open var extraData = [String: Any]()
    
    private(set) open var image : KMImage!
    private(set) open var thumbImage : KMImage!
    
    private var imageBlocks = [(image: KMImage) -> Void]()
    private var thumbImageBlocks = [(image: KMImage) -> Void]()
    private var isLoadingImage = false
    private var isLoadingThumbImage = false
    
    override open class func fastCodingKeys() -> [Any]? {
        return ["userId", "vehicleId", "vehicleDescription", "vehicleNumber", "imei", "mode", "imageURL", "thumbImageURL", "subscriptionEnd", "websocketSupported", "extraData", "timezone"]
    }
    
    ///Reload data given new vehicle data
    open func reload(with vehicle: Vehicle) {
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
    }
    
    func jsonPatch() -> [String: Any] {
        var dicto = [String: Any]()
        dicto["description"] = vehicleDescription
        dicto["vehicle_number"] = vehicleNumber
        return dicto
    }
    
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
            return
        }
        
        if let image = image {
            completion(image)
        }
        else if let path = NSURL(string: imageURL)?.lastPathComponent, let image = CacheManager.shared.image(for: path){
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
                    KatsanaAPI.shared.log.error("Error requesting vehicle image \(self.vehicleId!)")
                    self.isLoadingImage = false
                })
            }
        }
    }
   
    open func thumbImage(completion: @escaping (_ image: KMImage) -> Void){
        guard thumbImageURL != nil else {
            return
        }
        
        if let image = thumbImage {
            completion(image)
        }
        else if let path = NSURL(string: thumbImageURL)?.lastPathComponent, let image = CacheManager.shared.image(for: path){
            completion(image)
        }else{
            if isLoadingThumbImage {
                thumbImageBlocks.append(completion)
            }else{
                isLoadingThumbImage = true
                ImageRequest.shared.requestImage(path: thumbImageURL, completion: { (image) in
                    self.thumbImage = image
                    self.isLoadingThumbImage = false
                    for block in self.thumbImageBlocks{
                        block(image!)
                    }
                    completion(image!)
                }, failure: { (error) in
                    KatsanaAPI.shared.log.error("Error requesting vehicle thumb image vehicle id \(self.vehicleId!)")
                    self.isLoadingThumbImage = false
                })
            }
        }
    }
    
    
    
}
