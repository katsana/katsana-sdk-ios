//
//  KatsanaAPI+VehicleProfile.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 17/10/2016.
//  Copyright © 2016 pixelated. All rights reserved.
//

import Siesta

extension KatsanaAPI {

    /// Save vehicle profile data
    ///
    /// 
    public func saveVehicleProfile(vehicleId: String, completion: @escaping (_ vehicle: Vehicle?) -> Void, failure: @escaping (_ error: RequestError?) -> Void = {_ in }) -> Void {
        let vehicle = vehicleWith(vehicleId: vehicleId)
        guard vehicle != nil else {
            return
        }

        let path = "vehicles/" + vehicleId
        let resource = self.API.resource(path)
        
        let json = vehicle?.jsonPatch()
        resource.request(.patch, json: json!).onSuccess { entity in
            completion(vehicle)
        }.onFailure { (error) in
            failure(error)
            self.log.error("Error save vehicle profile \(vehicleId), \(error)")
        }
    }
    
    /// Save vehicle profile image. Function requestAllVehicles must be called first and the vehicle must be in the vehicle list
    ///
    /// - parameter vehicleId:  vehicle id
    /// - parameter image:      image to save
    /// - parameter completion: return vehicle
    public func saveVehicleProfileImage(vehicleId: String, image : KMImage?, completion: @escaping (_ vehicle: Vehicle?) -> Void, failure: @escaping (_ error: Error?) -> Void = {_ in }) -> Void {
        let vehicle = vehicleWith(vehicleId: vehicleId)
        guard vehicle != nil else {
            return
        }
        
        var finalImage : KMImage!
        if image == nil {
            finalImage = KMImage(color: KMColor.white)!
        }else{
            finalImage = image
        }
        finalImage = finalImage.fixOrientation()
        
        var maxSize : CGFloat = 600
        #if os(iOS)
            let scale = UIScreen.main.scale
        #elseif os(OSX)
            let scale = (NSScreen.main()?.backingScaleFactor)! as CGFloat
        #endif
        if scale > 1 {maxSize /= scale}
        
        if ((finalImage.size.width) > maxSize || (finalImage.size.height) > maxSize) {
            let factor = finalImage.size.width/finalImage.size.height;
            if (factor > 1) {
                finalImage = finalImage.scale(to: CGSize(width: maxSize, height: maxSize / factor))
            }else{
                finalImage = finalImage.scale(to: CGSize(width: maxSize * factor, height: maxSize))
            }
        }
        
        //Just put it although still not saved
        vehicle?.updateImage(finalImage)
        let path = self.baseURL().absoluteString + "vehicles/" + vehicleId + "/avatar"
        uploadImage(image: finalImage, path: path) { (success, error) in
            if success{
                completion(vehicle)
            }else{
                self.log.error("Error save vehicle profile image \(vehicleId), \(String(describing: error))")
                failure(error)
            }
        }
    }
    
}
