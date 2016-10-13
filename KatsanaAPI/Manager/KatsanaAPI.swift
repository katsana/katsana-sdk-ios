//
//  KMKatsanaAPI.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 12/10/2016.
//  Copyright © 2016 pixelated. All rights reserved.
//

import UIKit
import Siesta
import SwiftyJSON

public class KatsanaAPI: NSObject {
    
    public static let sharedInstance = KatsanaAPI()
    public var API : Service!
    
    private(set) public var currentUser: KMUser!
    public              var currentVehicle: KMVehicle!
    private(set) public var vehicles: [KMVehicle]!
    
    private let SwiftyJSONTransformer = ResponseContentTransformer { JSON($0.content as AnyObject) }
    
    internal var authToken: String! {
        didSet {
            
            // Rerun existing configuration closure using new value
            API.invalidateConfiguration()
////            // Wipe any Siesta’s cached state if auth token changes
//            API.wipeResources()
//            configure()
        }
    }
    
    func baseURL() -> URL {
        return API.baseURL!;
    }

    override init() {
        super.init()
        setup()
    }
    
    public func setup(){
        API = Service(baseURL: "https://carbon.api.katsana.com/")
        
        configure()
//        setupTransformer()
    }
    
    func configure() {
        API.configure("**") {
            $0.headers["Accept"] = "application/json"
            $0.pipeline[.parsing].add(self.SwiftyJSONTransformer, contentTypes: ["*/json"])
            $0.headers["Authorization"] = "Bearer " + self.authToken
            
        }
    }
    
    func setupTransformer() -> Void {
        API.configureTransformer("vehicles/*") {
            KMVehicle.fromJSON($0.content)
        }
        API.configureTransformer("profile") {
            KMUser.fromJSON($0.content)
        }
//        APIManager.configureTransformer(ConfigurationPatternConvertible) { (Entity<I>) -> O? in
//
//        }
    }
    
 //   public func resourceChanged(_ resource: Siesta.Resource, event: Siesta.ResourceEvent){
        
//    }
//    public func resourceRequestProgress(for resource: Siesta.Resource, progress: Double){
//
//    }
//    public func stoppedObserving(resource: Siesta.Resource){
        
 //   }
 //   public var observerIdentity: AnyHashable{
 //       return nil;
 //   }
}
