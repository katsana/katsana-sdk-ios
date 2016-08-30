//
//  KMNotificationSettingsObject.h
//  Katsana
//
//  Created by Wan Ahmad Lutfi on 23/06/2016.
//  Copyright © 2016 bijokmind. All rights reserved.
//

#import <Foundation/Foundation.h>
@class KMVehicle;

@interface KMNotificationSettingsObject : NSObject

@property (nonatomic, weak) KMVehicle *vehicle;

@property (nonatomic, strong) NSString *vehicleId;
@property (nonatomic, assign) BOOL enabled;

//Boolean need to set whether settings need to be updated on the server
@property (nonatomic, assign) BOOL needUpdate;
////!Last enabled status. Used to see if need to update firebase push settings
//@property (nonatomic, assign) BOOL lastEnabledStatus;

@end
