//
//  Vehicle.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 26/01/2017.
//  Copyright © 2017 pixelated. All rights reserved.
//

import UIKit

public class Vehicle: NSObject {
    public var userId : String!
    public var vehicleId: String!
    public var vehicleDescription = ""
    public var vehicleNumber = ""
    public var imei : String!
    public var mode: String!
    public var todayMaxSpeed: Float = 0
    public var odometer: Double = 0
    public var subscriptionEnd: Date!
    public var websocketSupported = false
    public var imageURL: String!
    public var thumbImageURL: String!
    public var current: VehicleLocation!
    
    ///Extra data that user can save to vehicle. Should have only value with codable support.
    public var extraData: [String: Any]!
    
    private(set) public var image : UIImage!
    private(set) public var thumbImage : UIImage!
    
    private var imageBlocks = [(image: UIImage) -> Void]()
    private var thumbImageBlocks = [(image: UIImage) -> Void]()
    private var isLoadingImage = false
    private var isLoadingThumbImage = false
    
    class func fastCodingKeys() -> [Any?] {
        return ["userId", "vehicleId", "vehicleDescription", "vehicleNumber", "imei", "mode", "imageURL", "thumbImageURL", "subscriptionEnd", "websocket", "extraData"]
    }
    
    public func reload(with vehicle: Vehicle) {
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
    }
    
    func jsonPatch() -> [String: Any] {
        var dicto = [String: Any]()
        dicto["description"] = vehicleDescription
        dicto["vehicle_number"] = vehicleNumber
        return dicto
    }
    
    // MARK: Image
    
    public func updateImage(_ image: KMImage) {
        self.image = image
    }
    
    public func reloadImageInBlocks() {
        for block in imageBlocks {
            block(self.image)
        }
    }
    
    public func image(completion: @escaping (_ image: UIImage) -> Void){
        if let image = image {
            completion(image)
        }else{
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
                }, failure: { (error) in
                    KatsanaAPI.shared.log.error("Error requesting vehicle image \(self.vehicleId!)")
                    self.isLoadingImage = false
                })
            }
        }
    }
   
    public func thumbImage(completion: @escaping (_ image: UIImage) -> Void){
        if let image = thumbImage {
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
                }, failure: { (error) in
                    KatsanaAPI.shared.log.error("Error requesting vehicle thumb image vehicle id \(self.vehicleId!)")
                    self.isLoadingThumbImage = false
                })
            }
        }
    }
    
    
    
}
