//
//  KatsanaAPI+VehicleProfile.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 17/10/2016.
//  Copyright © 2016 pixelated. All rights reserved.
//

extension KatsanaAPI {

    public func saveVehicleProfile(vehicleId: String, completion: @escaping (KMVehicle?, Error?) -> Void) -> Void {
        let vehicle = vehicleWith(vehicleId: vehicleId)
        guard vehicle != nil else {
            return
        }
        
        let path = "vehicles/" + vehicleId
        let resource = self.API.resource(path)
        
        let json = vehicle?.jsonPatchDictionary()
        resource.request(.patch, json: json!).onSuccess { (_) in
            print("success")
            }.onFailure { (error) in
                completion(nil, error)
        }
    }
    
    public func saveVehicleProfileImage(vehicleId: String, image : UIImage?, completion: @escaping (KMVehicle?, Error?) -> Void) -> Void {
        let vehicle = vehicleWith(vehicleId: vehicleId)
        guard vehicle != nil else {
            return
        }
        
        var finalImage = image! as UIImage
        if image == nil {
            finalImage = UIImage(color: UIColor.white)!
        }
        finalImage = finalImage.fixOrientation()
        
        var maxSize : CGFloat = 600
        let scale = UIScreen.main.scale
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
        vehicle?.carImage = finalImage
        let path = self.baseURL().absoluteString + "vehicles/" + vehicleId + "/avatar"
        uploadImage(image: finalImage, path: path) { (success, error) in
            if success{
                completion(vehicle, nil)
            }else{
                completion(nil, error)
            }
        }
    }
    
}
