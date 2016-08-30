//
//  KMNotificationSettings.h
//  Katsana
//
//  Created by Wan Ahmad Lutfi on 23/06/2016.
//  Copyright © 2016 bijokmind. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KMNotificationSettingsObject.h"

@interface KMNotificationSettings : NSObject

@property (nonatomic, strong) NSArray *lockdown;
@property (nonatomic, strong) NSArray *harshAccelerate;
@property (nonatomic, strong) NSArray *harshBrake;
@property (nonatomic, strong) NSArray *harshCorner;

//!Server dictionary representation for given keypath, currently not used.
- (id)patchValueForKeypath:(NSString*)keypath;
//!Check if need update all items in respective key and return bool value need to passed to server if update needed;
- (BOOL)needUpdateAllForKeypath:(NSString*)keypath boolValue:(BOOL*)boolValue;
//!Set whether a key need update all devices at server
- (void)setNeedUpdateForAllForKeypath:(NSString*)keypath boolValue:(BOOL)boolValue;

@end