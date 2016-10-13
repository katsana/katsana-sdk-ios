//
//  KMKatsanaAPI+Login.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 12/10/2016.
//  Copyright © 2016 pixelated. All rights reserved.
//

import Foundation
import SwiftyJSON
import Siesta

extension KatsanaAPI {
    
    public func login(email: String, password: String, completion: (_ user: String) -> Void) -> Void {

        let path = self.baseURL().absoluteString + "auth"
        var request = URLRequest(url: URL(string: path)!)
        request.httpMethod = "POST"
        let postString = "email=" + email + "&password=" + password;
        request.httpBody = postString.data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(error)")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
            }
            
            let json = JSON(data: data)
            let token = json["token"].string
            if token != nil {
                
                //Set token
                if (Thread.isMainThread) {
                    self.authToken = token
                    self.API.resource("profile").addObserver(owner: self) {
                        [weak self] resource, _ in
                        
                        let user : KMUser = resource.typedContent()!
                        print(user)
                    }
                }else{
                    DispatchQueue.main.async {
                        self.authToken = token
                        self.API.resource("profile").load().onSuccess({data in
                            
                            
                            print("sdf")
                        })
                        
                        
//                        addObserver(owner: self) {
//                            [weak self] resource, event in
//                            let test = resource.jsonArray
//                            let test2 = resource.jsonDict
//                            let test3 = resource.text
//                            let latest = resource.latestData
////                            let user : KMUser? = resource.typedContent()!
//                            
//                            print(resource.latestError)
//                            print(test)
//                            
//                            
//                        }
                        
                    }
                }
            }
        }
        task.resume()
    }
    
    public func test() {
        let resource = API.resource("vehicles").load();
//        let test = resource.jsonArray
//        let test2 = resource.jsonDict
//        let test3 = resource.text
        print(resource)
    }
    
    func resourceChanged(resource: Resource, event: ResourceEvent) {
        let test = resource.jsonArray
        let test2 = resource.jsonDict
        let test3 = resource.text
        //                            let user : KMUser? = resource.typedContent()!
        print(resource.latestError)
        print(test)
    }

}





//- (void) loadAuthenticatedUser:(void (^)(KMUser *))success failure:(void (^)(RKObjectRequestOperation *, NSError *))failure {
//    __weak typeof(self) weakSelf = self;
//    [self getObjectsAtPath:@"profile" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
//        if (success) {
//            KMUser *currentUser = (KMUser *)[mappingResult.array firstObject];
//            success(currentUser);
//            weakSelf.currentUser = currentUser;
//        }
//    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
//        if (failure) {
//            failure(operation, error);
//            DDLogError(@"Error getting user profile: %@", error.localizedDescription);
//        }
//    }];
//}
