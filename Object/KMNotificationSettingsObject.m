//
//  KMNotificationSettingsObject.m
//  Katsana
//
//  Created by Wan Ahmad Lutfi on 23/06/2016.
//  Copyright © 2016 bijokmind. All rights reserved.
//

#import "KMNotificationSettingsObject.h"

@interface KMNotificationSettingsObject ()

@property (nonatomic, strong) id theVehicleId;
@property (nonatomic, strong) id theEnabled;

@end

@implementation KMNotificationSettingsObject

+ (NSArray*)fastCodingKeys{
    return @[@"vehicleId", @"enabled", @"needUpdate"];
}

- (void)setNeedUpdate:(BOOL)needUpdate{
    _needUpdate = needUpdate;
}

- (void)setTheVehicleId:(id)theVehicleId{
    _theVehicleId = theVehicleId;
//    DLog(@"%@", theVehicleId);
}

@end
