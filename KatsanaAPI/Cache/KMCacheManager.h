//
//  KMCacheManager.h
//  Katsana
//
//  Created by Wan Ahmad Lutfi on 16/05/2016.
//  Copyright © 2016 bijokmind. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreLocation;

@interface KMCacheManager : NSObject

@property (nonatomic, assign) CGFloat addressCacheDayDuration;
@property (nonatomic, readonly) NSString *cachePath;

+ (instancetype) sharedInstance;

- (void)cacheData:(id)data identifier:(NSString*)identifier;

- (KMUser*)lastUser;
- (NSArray <KMVehicle*> *)lastVehicles;
- (KMTravelHistory*)travelHistoryForDate:(NSDate*)date vehicleId:(NSString*)vehicleId;
- (KMImage*)imageForIdentifier:(NSString*)identifier;
- (void)addressForCoordinate:(CLLocationCoordinate2D)coord completionBlock:(void (^)(KMAddress *address))completion;
- (VehicleActivity*)latestCachedActivityObject;
- (NSArray*)activityObjects;
- (id)liveShareForUserId:(NSString*)userId deviceId:(NSString*)deviceId;

//Used to save and get again table row that expanded
- (void)setExpandedTableVehicleIdHistory:(NSString*)vehicleId date:(NSDate*)date;
- (NSDate*)expandedDateForVehicleIdHistory:(NSString*)vehicleId;

- (void)clearAllCache;
- (void)clearActivityCache;

@end
