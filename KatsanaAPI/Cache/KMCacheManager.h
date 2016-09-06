//
//  KMCacheManager.h
//  Katsana
//
//  Created by Wan Ahmad Lutfi on 16/05/2016.
//  Copyright © 2016 bijokmind. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreLocation;

@class KMVehicleDayHistory;
@class KMActivityObject;

@interface KMCacheManager : NSObject

@property (nonatomic, assign) CGFloat addressCacheDayDuration;

+ (instancetype) sharedInstance;

- (void)cacheData:(id)data identifier:(NSString*)identifier;

- (KMVehicleDayHistory*)vehicleDayHistoryForDate:(NSDate*)date vehicleId:(NSString*)vehicleId;
- (UIImage*)imageForIdentifier:(NSString*)identifier;
- (void)addressForCoordinate:(CLLocationCoordinate2D)coord completionBlock:(void (^)(KMAddress *address))completion;
- (KMActivityObject*)latestCachedActivityObject;
- (NSArray*)activityObjects;

//Used to save and get again table row that expanded
- (void)setExpandedTableVehicleIdHistory:(NSString*)vehicleId date:(NSDate*)date;
- (NSDate*)expandedDateForVehicleIdHistory:(NSString*)vehicleId;

- (void)clearAllCache;
- (void)clearActivityCache;

- (void)clearCacheIfNeededForCurrentUser;

@end
