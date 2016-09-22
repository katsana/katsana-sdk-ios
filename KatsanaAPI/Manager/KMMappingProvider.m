//
//  KMMappingProvider.m
//  KatsanaMap
//
//  Created by Wan Ahmad Lutfi on 12/14/15.
//  Copyright © 2015 bijokmind. All rights reserved.
//

#import "KMMappingProvider.h"
#import "KMUser.h"
#import "KMVehicle.h"
#import "KMVehiclePosition.h"
#import "KMVehicleDayHistory.h"
#import "KMViolation.h"
#import "KMAddress.h"
#import "KMTrip.h"
#import "KMNotificationSettings.h"
#import "KMNotificationSettingsObject.h"
#import <RestKit/RestKit.h>

@implementation KMMappingProvider

+ (RKObjectMapping *)userMapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[KMUser class]];
    NSDictionary *mappingDictionary = @{@"email": @"email",
                                        @"id": @"userId",
                                        @"address": @"address",
                                        @"phone_home": @"phoneHome",
                                        @"phone_mobile": @"phoneMobile",
                                        @"identification": @"identification",
                                        @"fullname": @"fullname",
                                        @"status": @"status",
                                        
                                        @"meta.emergency.fullname": @"emergencyFullName",
                                        @"meta.emergency.phone.home": @"emergencyPhoneHome",
                                        @"meta.emergency.phone.mobile": @"emergencyPhoneMobile",
                                        @"created_at": @"createdAt",
                                        @"updated_at": @"updatedAt",
                                        @"avatar.thumb" : @"avatarURLPath"
                                        };
    
    [mapping addAttributeMappingsFromDictionary:mappingDictionary];
    
    return mapping;
}


+ (RKObjectMapping *)vehicleMapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[KMVehicle class]];
    NSDictionary *mappingDictionary = @{@"user_id": @"userId",
                                        @"id": @"vehicleId",
                                        @"description": @"vehicleDescription",
                                        @"vehicle_number": @"vehicleNumber",
                                        @"imei": @"imei",
                                        @"mode": @"mode",
                                        @"avatar": @"avatarURLPath",
                                        @"marker": @"markerURLPath",
                                        @"today_max_speed": @"todayMaxSpeed",
                                        @"speed_limit" : @"speedLimit",
                                        @"odometer" : @"odometer",
                                        @"ends_at" : @"subscriptionEnd",
                                        @"meta.websocket" : @"websocket"
                                        };
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"current"
                                                                            toKeyPath:@"current"
                                                                          withMapping:[self vehiclePositionMapping]]];

    [mapping addAttributeMappingsFromDictionary:mappingDictionary];
    
    return mapping;
}

+ (RKObjectMapping *)tripMapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[KMTrip class]];
    NSDictionary *mappingDictionary = @{@"distance": @"distance",
                                        @"duration" : @"duration",
                                        @"max_speed" : @"maxSpeed",
                                        @"average_speed" : @"averageSpeed",
                                        @"idle_duration" : @"idleDuration",
                                        };
    
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"start"
                                                                            toKeyPath:@"start"
                                                                          withMapping:[self vehiclePositionMapping]]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"end"
                                                                            toKeyPath:@"end"
                                                                          withMapping:[self vehiclePositionMapping]]];
    
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"histories"
                                                                            toKeyPath:@"histories"
                                                                          withMapping:[self vehiclePositionMapping]]];
    
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"violations"
                                                                            toKeyPath:@"violations"
                                                                          withMapping:[self vehicleViolationMapping]]];
    
    [mapping addAttributeMappingsFromDictionary:mappingDictionary];
    
    return mapping;
}

+ (RKObjectMapping *)vehiclePositionMapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[KMVehiclePosition class]];
    NSDictionary *mappingDictionary = @{@"altitude": @"altitude",
                                        @"course": @"course",
                                        @"latitude": @"latitude",
                                        @"longitude": @"longitude",
                                        @"speed": @"speed",
                                        @"distance": @"distance",
                                        @"fuelPercentage": @"fuelPercentage",
                                        @"tracked_at": @"trackedAt",
                                        @"updated_at": @"updatedAt",
                                        @"created_at": @"createdAt",
                                        @"state": @"state",
                                        @"voltage": @"voltage",
                                        @"gsm": @"gsm",
                                        @"ignition" : @"ignitionState"
                                        };

    [mapping addAttributeMappingsFromDictionary:mappingDictionary];
    
    return mapping;
}

+ (RKObjectMapping *)vehicleViolationMapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[KMViolation class]];
    NSDictionary *mappingDictionary = @{@"id": @"violationId",
                                        @"policy_id": @"policyId",
                                        @"policy_type": @"policyType",
                                        @"description": @"message",
                                        @"address": @"address",
                                        @"distance": @"distance",
                                        @"duration": @"duration",
                                        @"latitude": @"latitude",
                                        @"longitude": @"longitude",
                                        @"start_time": @"startTime",
                                        @"end_time": @"endTime",
                                        @"start_position": @"startPosition",
                                        @"end_position": @"endPosition",
                                        @"max_speed" : @"maxSpeed",
                                        @"average_speed" : @"averageSpeed",
                                        @"idle_duration" : @"idleDuration"
                                        };
    
    [mapping addAttributeMappingsFromDictionary:mappingDictionary];
    
    return mapping;
}

+ (RKObjectMapping *)vehicleHistoryMapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[KMVehicleDayHistory class]];
    NSDictionary *mappingDictionary = @{
                                        @"summary.max_speed": @"maxSpeed",
                                        @"summary.distance": @"distance",
                                        @"summary.violation": @"violationCount",
                                        @"duration.from": @"historyDate"
                                        };
    
    [mapping addAttributeMappingsFromDictionary:mappingDictionary];
    
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"trips"
                                                                                     toKeyPath:@"trips"
                                                                                   withMapping:[self tripMapping]]];
    
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"violations"
                                                                            toKeyPath:@"violations"
                                                                          withMapping:[self vehicleViolationMapping]]];
    return mapping;
}

+ (RKObjectMapping *)daySummaryMapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[KMVehicleDayHistory class]];
    NSDictionary *mappingDictionary = @{
                                        @"date": @"historyDate",
                                        @"distance": @"distance",
                                        @"violation": @"violationCount",
                                        @"duration": @"duration",
                                        @"max_speed" : @"maxSpeed",
                                        @"trip" : @"tripCount",
                                        @"idle_duration": @"idleDuration",
                                        };
    
    [mapping addAttributeMappingsFromDictionary:mappingDictionary];
    return mapping;
}


+ (RKObjectMapping *)addressMapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[KMAddress class]];
    NSDictionary *mappingDictionary = @{@"latitude": @"latitude",
                                        @"longitude": @"longitude",
                                        @"street_number": @"streetNumber",
                                        @"street_name": @"streetName",
                                        @"locality": @"locality",
                                        @"sublocality": @"sublocality",
                                        @"postcode": @"postcode",
                                        @"country": @"country",
                                        @"address": @"address"
                                        };
    
    [mapping addAttributeMappingsFromDictionary:mappingDictionary];
    
    return mapping;
}


+ (RKObjectMapping *)notificationSettingsMapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[KMNotificationSettings class]];
    NSDictionary *mappingDictionary = @{@"lockdown": @"theLockdown",
                                        @"harsh-accelerate": @"theHarshAccelerate",
                                        @"harsh-brake": @"theHarshBrake",
                                        @"harsh-corner": @"theHarshCorner",
                                        };
    [mapping addAttributeMappingsFromDictionary:mappingDictionary];
    return mapping;
}



+ (RKObjectMapping *)notificationSettingsRequestMapping {
    
    RKObjectMapping *mapping = [RKObjectMapping requestMapping];
    NSDictionary *mappingDictionary = @{
                                        @"device_id": @"device_id",
                                        @"enabled": @"enabled",
                                        };
    

    [mapping addAttributeMappingsFromDictionary:mappingDictionary];
    
    return mapping;
}

+ (RKObjectMapping *)profileRequestMapping {
    
    RKObjectMapping *mapping = [RKObjectMapping requestMapping];
    NSDictionary *mappingDictionary = @{@"address": @"address",
                                        @"phone_home": @"phoneHome",
                                        @"phone_mobile": @"phoneMobile",
                                        @"fullname": @"fullname",
                                        @"meta.emergency.fullname": @"emergencyFullName",
                                        @"meta.emergency.phone.home": @"emergencyPhoneHome",
                                        @"meta.emergency.phone.mobile": @"emergencyPhoneMobile",
                                        };
    
    
    [mapping addAttributeMappingsFromDictionary:mappingDictionary];

    return mapping;
}

+ (RKObjectMapping *)avatarRequestMapping {
    
    RKObjectMapping *mapping = [RKObjectMapping requestMapping];
    NSDictionary *mappingDictionary = @{@"file": @"file"
                                        };
    
    [mapping addAttributeMappingsFromDictionary:mappingDictionary];
    
    return mapping;
}


+ (RKObjectMapping *)vehicleRequestMapping {
    RKObjectMapping *mapping = [RKObjectMapping requestMapping];
    NSDictionary *mappingDictionary = @{
                                        @"description": @"vehicleDescription",
                                        @"vehicle_number": @"vehicleNumber",
                                        };

    [mapping addAttributeMappingsFromDictionary:mappingDictionary];
    
    return mapping;
}

@end
