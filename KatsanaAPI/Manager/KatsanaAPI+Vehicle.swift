//
//  KMKatsanaAPI+Vehicle.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 13/10/2016.
//  Copyright © 2016 pixelated. All rights reserved.
//

import Foundation

extension KatsanaAPI {
    
    public func requestVehicle(vehicleId: String, completion: @escaping (KMVehicle?, Error?) -> Void) -> Void {
        let vehicle = vehicleWith(vehicleId: vehicleId)
        if (vehicle != nil) {
            currentVehicle = vehicle!;
        }
        
        
        let path = "vehicles/" + vehicleId
        API.resource(path).addObserver(owner: self) {
            [weak self] resource, _ in
            let vehicle : KMVehicle? = resource.typedContent()
            self?.currentVehicle = vehicle;
        }.loadIfNeeded()
    }
    
}

//- (void)refreshToken:(void (^)(BOOL))success;
//- (void)loginWithUserName:(NSString *)email password:(NSString*)password user:(void (^)(KMUser *))success failure:(void (^)(RKObjectRequestOperation *, NSError *))failure;
//
////Profile
//- (void)saveUserProfile:(void (^)(BOOL success, NSDictionary *responseError))success;
//- (void)saveUserProfileImage:(UIImage*)image success:(void (^)(BOOL success))success;
//- (void)saveVehicleProfile:(NSString*)vehicleId success:(void (^)(BOOL success, NSDictionary *responseError))success;
//- (void)saveVehicleProfileImage:(UIImage*)image vehicleId:(NSString*)vehicleId success:(void (^)(BOOL success))success;
//
////Vehicle
//-(void)loadVehicleWithId:(NSString*)vehicleId vehicle:(void (^)(KMVehicle *))success failure:(void (^)(RKObjectRequestOperation *, NSError *))failure;
//-(void)loadVehicles:(void (^)(NSArray *))success failure:(void (^)(RKObjectRequestOperation *, NSError *))failure;
//-(void)loadVehicles:(void (^)(NSArray *))success forceLoad:(BOOL)forceLoad failure:(void (^)(RKObjectRequestOperation *, NSError *))failure;
//- (void)loadFirstVehicle:(void (^)(KMVehicle *))success failure:(void (^)(RKObjectRequestOperation *, NSError *))failure;;
