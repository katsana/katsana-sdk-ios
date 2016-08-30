//
//  KMMappingProvider.h
//  KatsanaMap
//
//  Created by Wan Ahmad Lutfi on 12/14/15.
//  Copyright © 2015 bijokmind. All rights reserved.
//

#import <Foundation/Foundation.h>
@class RKObjectMapping;

/**
 *  Provide mapping for REST to class
 */
@interface KMMappingProvider : NSObject

+ (RKObjectMapping *)userMapping;
+ (RKObjectMapping *)vehicleMapping;
+ (RKObjectMapping *)vehiclePositionMapping;
+ (RKObjectMapping *)vehicleHistoryMapping;
+ (RKObjectMapping *)addressMapping;
+ (RKObjectMapping *)notificationSettingsMapping;
+ (RKObjectMapping *)daySummaryMapping;

+ (RKObjectMapping *)vehicleRequestMapping;
+ (RKObjectMapping *)notificationSettingsRequestMapping;
+ (RKObjectMapping *)profileRequestMapping;
+ (RKObjectMapping *)avatarRequestMapping;




@end
