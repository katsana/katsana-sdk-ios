//
//  KMCacheManager.m
//  Katsana
//
//  Created by Wan Ahmad Lutfi on 16/05/2016.
//  Copyright © 2016 bijokmind. All rights reserved.
//

#import "KMCacheManager.h"
#import "KMTravelHistory.h"
#import "KMAddress.h"
#import "KMUser.h"

static NSString *CACHE_VERSION = @"1.02";

@interface KMCacheManager ()

@property (nonatomic, strong) NSMutableDictionary *dataDictionaries;
@property (nonatomic, strong) NSMutableArray *addresses;
//!Key is vehicle id, value is date
@property (nonatomic, strong) NSDictionary *expandedVehicleHistory;
@property (nonatomic, strong) NSMutableDictionary *activities;

@end

@implementation KMCacheManager{
    NSDate *_lastAccessTodaydate;
    NSString *_lastAccessTodayHistoryVehicleId;
    NSDate *_lastSavedCache;
    NSDate *_lastSavedAddressCache;
    NSDate *_lastSavedActivitiesCache;
}


static KMCacheManager *sharedPeerToPeer = nil;
+ (instancetype) sharedInstance {
    if (!sharedPeerToPeer) {
        sharedPeerToPeer = [[[self class] alloc] init];
    }
    return sharedPeerToPeer;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.addressCacheDayDuration = 30*3; //Keep address cache for 3 months
        NSString *versionPath = [[self cacheDirectory] stringByAppendingPathComponent:@"version.txt"];
        NSString *version = [[NSString alloc] initWithContentsOfFile:versionPath encoding:NSASCIIStringEncoding error:nil];
        if (![version isEqualToString:CACHE_VERSION]) {
            [CACHE_VERSION writeToFile:versionPath atomically:YES encoding:NSASCIIStringEncoding error:nil];
            [self clearAllCache];
            return self;
        }
        
        [CACHE_VERSION writeToFile:versionPath atomically:YES encoding:NSASCIIStringEncoding error:nil];
        NSString *path = [[self cacheDirectory] stringByAppendingPathComponent:[self cacheDataFilename]];
        NSData *data = [NSData dataWithContentsOfFile:path];
        
        @try {
            self.dataDictionaries = [FastCoder objectWithData:data];
            if ([self.dataDictionaries isKindOfClass:[NSDictionary class]]) {
                self.dataDictionaries = self.dataDictionaries.mutableCopy;
            }
            
        } @catch (NSException *exception) {
//            DDLogError(@"Error reading cached data");
        } @finally {
            
        }
        
        NSString *addressPath = [[self cacheDirectory] stringByAppendingPathComponent:[self cacheAddressDataFilename]];
        data = [NSData dataWithContentsOfFile:addressPath];
        self.addresses = [FastCoder objectWithData:data];
        
        NSString *activitiesPath = [[self cacheDirectory] stringByAppendingPathComponent:[self cacheActivitiesDataFilename]];
        data = [NSData dataWithContentsOfFile:activitiesPath];
        
        NSMutableDictionary *activitiesDicto = [FastCoder objectWithData:data];
        if ([activitiesDicto isKindOfClass:[NSDictionary class]]) {
            NSMutableDictionary *newActivitiesDicto = [NSMutableDictionary dictionary];
            [activitiesDicto enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, NSMutableArray *activities, BOOL * _Nonnull stop) {
                //Safe coding
                if (activities.count > 1) {
                    NSArray *theActivities = [activities sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"startTime" ascending:NO]]];
                    newActivitiesDicto[key] = theActivities.mutableCopy;
                }
            }];
            self.activities = newActivitiesDicto;
        }
        _cachePath = path;
        NSLog(@"cache path: %@", path);
//        DDLogInfo(@"cache path: %@", path);
        
        [self clearOldActivityCacheIfNeeded];
        
//        DDLogInfo(@"Total addresses cached: %lu", (unsigned long)self.addresses.count);
//        DDLogInfo(@"Total activities cached: %lu", (unsigned long)self.activities.count);
//        DDLogInfo(@"Total day histories cached: %lu", [self.dataDictionaries[@"KMTravelHistory"] count]);
    }
    return self;
}

- (NSMutableDictionary*)dataDictionaries{
    if (!_dataDictionaries) {
        _dataDictionaries = [[NSMutableDictionary alloc] init];
    }
    return _dataDictionaries;
}

- (NSString*)cacheDataFilename{
    return @"cacheData.dat";
}

- (NSString*)cacheAddressDataFilename{
    return @"cacheAddress.dat";
}

- (NSString*)cacheActivitiesDataFilename{
    return @"cacheActivities.dat";
}

#pragma mark -

- (KMUser*)lastUser{
    KMUser *user = [self.dataDictionaries valueForKey:NSStringFromClass([KMUser class])];
    return user;
}

- (NSArray <KMVehicle*> *)lastVehicles{
    NSArray *vehicles = [self.dataDictionaries valueForKey:NSStringFromClass([KMVehicle class])];
    return vehicles;
}

- (KMTravelHistory*)travelHistoryForDate:(NSDate*)date vehicleId:(NSString*)vehicleId{
    //Always need load latest data if today
    NSDate *today = [NSDate date];
    if ([[NSCalendar currentCalendar] isDate:date equalToDate:today toUnitGranularity:NSCalendarUnitDay]) {
        if (![_lastAccessTodayHistoryVehicleId isEqualToString:vehicleId] || (_lastAccessTodaydate && [today timeIntervalSinceDate:_lastAccessTodaydate] > 60*4)) {
            _lastAccessTodayHistoryVehicleId = vehicleId;
            _lastAccessTodaydate = [NSDate date];
            return nil;
        }
    }
    
    NSString *classStr = NSStringFromClass([KMTravelHistory class]);
    NSMutableArray *dataArray = [self.dataDictionaries valueForKey:classStr];
    for (NSDictionary* dicto in dataArray) {
        KMTravelHistory *obj = dicto[@"data"];
        NSString *theId = dicto[@"id"];
        
        if ([[NSCalendar currentCalendar] isDate:obj.date equalToDate:date toUnitGranularity:NSCalendarUnitDay] && [theId isEqualToString:vehicleId]) {
            return obj;
        }
    }
    return nil;
}

- (void)addressForCoordinate:(CLLocationCoordinate2D)coord completionBlock:(void (^)(KMAddress *address))completion{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSMutableArray *dataArray = self.addresses.copy;
        BOOL found = NO;
        for (KMAddress *address in dataArray) {
            if (CLCOORDINATES_EQUAL2(address.coordinate, coord)) {
                if ([[NSDate date] timeIntervalSinceDate:address.updateDate] < 60*60*24*self.addressCacheDayDuration) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(address);
                    });
                    
                    found = YES;
                    break;
                }
            }
//            DLog(@"%.4f, %.4f", address.coordinate.latitude, address.coordinate.longitude);
        }
        if (!found) {
//            DLog(@"the coord: %.4f, %.4f", coord.latitude, coord.longitude);
            dispatch_sync(dispatch_get_main_queue(), ^{
                completion(nil);
            });
        }
    });
    
}

- (KMImage*)imageForIdentifier:(NSString*)identifier{
    NSString *dir = [self cacheDirectory];
    NSString *dataPath = [dir stringByAppendingPathComponent:@"/Images"];
    dataPath = [[dataPath stringByAppendingPathComponent:identifier] stringByAppendingPathExtension:@"dat"];
    NSData *data = [[NSData alloc] initWithContentsOfFile:dataPath];
    
#if TARGET_OS_IPHONE
    KMImage *image = [KMImage imageWithData:data];
    
#elif TARGET_OS_MAC
    KMImage *image = [[NSImage alloc] initWithData:data];
    
#endif
    
    return image;
}

- (VehicleActivity*)latestCachedActivityObject{
    KMUser *user = [KatsanaAPI shared].currentUser;
    NSMutableArray *activities;
    if (user.userId) {
        activities = self.activities[user.userId];
    }

    //Just return first object and assume it is latest
    VehicleActivity *act = activities.firstObject;
    return act;
}

- (NSArray*)activityObjects{
    KMUser *user = [KatsanaAPI shared].currentUser;
    NSMutableArray *activities;
    if (user.userId) {
        activities = self.activities[user.userId.copy];
        if ([activities.firstObject isKindOfClass:[NSDictionary class]]) {
            self.activities = nil;
            activities = nil;
        }
        
    }
    return activities.copy;
}


#pragma mark - Caching

- (void)cacheData:(id)data identifier:(NSString*)identifier{
    if (!data) {
        return;
    }
    
    if ([data class] == [KMAddress class]) {
        [self cacheAddress:data];
        return;
    }
    else if ([data isKindOfClass:[NSArray class]]) {
        id obj = [data firstObject];
        if ([obj class] == [VehicleActivity class]) {
            for (VehicleActivity *act in data) {
                [self cacheActivity:act identifier:identifier];
            }
            return;
        }
        else if ([obj class] == [KMVehicle class]) {
            [self.dataDictionaries setValue:data forKey:NSStringFromClass([obj class])];
            [self autoSave];
            return;
        }
    }
    else if ([data isKindOfClass:[VehicleActivity class]]) {
        [self cacheActivity:data identifier:identifier];
        return;
    }
    else if ([data isKindOfClass:[KMImage class]]){
        [self cacheImage:data withIdentifier:identifier];
        return;
    }
    else if ([data isKindOfClass:[KMUser class]]){
        [self.dataDictionaries setValue:data forKey:NSStringFromClass([data class])];
        [self autoSave];
        return;
    }
    
    BOOL dataChanged = NO;
    //Create cache array if data for given class still empty
    NSString *classStr = NSStringFromClass([data class]);
    NSMutableArray *dataArray = [self.dataDictionaries valueForKey:classStr];
    if (!dataArray){
        dataArray = [NSMutableArray array];
        if (!identifier) identifier = @"";
        NSMutableDictionary *dicto = @{@"data" : data, @"id" : identifier}.mutableCopy;
        [dataArray addObject:dicto];
        
        [self.dataDictionaries setValue:dataArray forKey:classStr];
        dataChanged = YES;
    }
    NSDictionary *needRemoveDicto;
    
    BOOL needAdd = YES;
    for (NSMutableDictionary *dicto in dataArray) {
        id obj = dicto[@"data"];
        NSString *theId = dicto[@"id"];
        
        if ([data isKindOfClass:[KMTravelHistory class]] && [obj isKindOfClass:[KMTravelHistory class]]) {
            if ([obj dateEqualToVehicleDayHistory:data] && [identifier isEqualToString:theId]) {
                
                if (![obj isEqual:data]) {
                    needRemoveDicto = dicto;
                    dataChanged = YES;
                }else{
                    needAdd = NO;
                }
                
                break;
            }
        }
        else{
            if ([identifier isEqualToString:theId]) {
                
                if (![obj isEqual:data]) {
                    needRemoveDicto = dicto;
                    dataChanged = YES;
                }else{
                    needAdd = NO;
                }
                break;
            }
        }
    }
    
    if (needRemoveDicto) {
        [dataArray removeObject:needRemoveDicto];
    }
    if (needAdd) {
        if (!identifier) identifier = @"";
        [dataArray addObject:@{@"data" : data, @"id" : identifier}];
        dataChanged = YES;
    }
    
    if (dataChanged) {
        [self autoSave];
    }
}

- (void)cacheAddress:(KMAddress*)address{
    BOOL needAdd = YES;
    if (!self.addresses) {
        self.addresses = [NSMutableArray array];
    }
    
    for (KMAddress *add in self.addresses) {
        if ([add isEqual:address]) {
            needAdd = NO;
            break;
        }
    }
    if (needAdd) {
        address.updateDate = [NSDate date];
        [self.addresses addObject:address];
        [self autoSaveAddress];
    }
}

- (void)cacheActivity:(VehicleActivity*)activity identifier:(NSString*)identifier{
    BOOL needAdd = YES;
    if (!self.activities) {
        self.activities = [NSMutableDictionary dictionary];
    }
    KMUser *user = [KatsanaAPI shared].currentUser;
    if (!user || ![identifier isEqualToString:user.userId]) {
        return;
    }
    
    NSMutableArray *activities = self.activities[user.userId.copy];
    if (!activities) {
        activities = [NSMutableArray array];
        self.activities[user.userId.copy] = activities;
    }
    
    for (VehicleActivity *act in activities) {
        if ([act.startTime isEqual:activity.startTime] && act.type == activity.type) {
            needAdd = NO;
            break;
        }
    }
    if (needAdd) {
        [activities addObject:activity];
        [self autoSaveActivities];
    }
}


- (void)cacheImage:(KMImage*)image withIdentifier:(NSString*)identifier{
    NSString *dir = [self cacheDirectory];
    NSString *dataPath = [dir stringByAppendingPathComponent:@"/Images"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath])
        [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:nil];
    
    dataPath = [[dataPath stringByAppendingPathComponent:identifier] stringByAppendingPathExtension:@"dat"];
    
#if TARGET_OS_IPHONE
    NSData *data = UIImagePNGRepresentation(image);
    
#elif TARGET_OS_MAC
    NSData *data = image.TIFFRepresentation;
#endif
    
    [data writeToFile:dataPath atomically:YES];
}


#pragma mark - Data

- (void)setExpandedTableVehicleIdHistory:(NSString*)vehicleId date:(NSDate*)date{
    if (!vehicleId) {
        self.expandedVehicleHistory = nil;
        return;
    }
    self.expandedVehicleHistory  = @{vehicleId : date};
}

- (NSDate*)expandedDateForVehicleIdHistory:(NSString*)vehicleId{
    __block NSDate *date;
    [self.expandedVehicleHistory enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([key isEqualToString:vehicleId]) {
            date = obj;
            *stop = YES;
        }
    }];
    return date;
}

//!Auto save cache every 20 seconds
- (void)autoSave{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    if (_lastSavedCache && [[NSDate date] timeIntervalSinceDate:_lastSavedCache] < 5) {
        [self performSelector:@selector(autoSave) withObject:nil afterDelay:3];
        return;
    }
    
    _lastSavedCache = [NSDate date];

    NSData *data = [FastCoder dataWithRootObject:self.dataDictionaries];
    NSString *path = [[self cacheDirectory] stringByAppendingPathComponent:[self cacheDataFilename]];
    [data writeToFile:path atomically:YES];
}

- (void)autoSaveAddress{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    if (_lastSavedAddressCache && [[NSDate date] timeIntervalSinceDate:_lastSavedAddressCache] < 3) {
        [self performSelector:@selector(autoSaveAddress) withObject:nil afterDelay:1];
        return;
    }
    
    _lastSavedAddressCache = [NSDate date];
    NSData *data = [FastCoder dataWithRootObject:self.addresses];
    NSString *path = [[self cacheDirectory] stringByAppendingPathComponent:[self cacheAddressDataFilename]];
    [data writeToFile:path atomically:YES];
}

- (void)autoSaveActivities{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    if (_lastSavedActivitiesCache && [[NSDate date] timeIntervalSinceDate:_lastSavedActivitiesCache] < 5) {
        [self performSelector:@selector(autoSaveActivities) withObject:nil afterDelay:1];
        return;
    }
    
    _lastSavedActivitiesCache = [NSDate date];
    NSData *data = [FastCoder dataWithRootObject:self.activities];
    NSString *path = [[self cacheDirectory] stringByAppendingPathComponent:[self cacheActivitiesDataFilename]];
    [data writeToFile:path atomically:YES];
}

- (NSString*)cacheDirectory{
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:[[NSBundle mainBundle] bundleIdentifier]];
    return path;
}

#pragma mark - Clear

- (void)clearAllCache{
    NSString *addressCachePath = [[self cacheDirectory] stringByAppendingPathComponent:[self cacheAddressDataFilename]];
    NSString *dataCachePath = [[self cacheDirectory] stringByAppendingPathComponent:[self cacheDataFilename]];
    NSString *activityCachePath = [[self cacheDirectory] stringByAppendingPathComponent:[self cacheActivitiesDataFilename]];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:addressCachePath error:nil];
    [fileManager removeItemAtPath:dataCachePath error:nil];
    [fileManager removeItemAtPath:activityCachePath error:nil];
}

- (void)clearActivityCache{
    NSString *activityCachePath = [[self cacheDirectory] stringByAppendingPathComponent:[self cacheActivitiesDataFilename]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:activityCachePath error:nil];
    [self.activities removeAllObjects];
}

- (void)clearOldActivityCacheIfNeeded{
    NSDate *lastPurgeDate = [[NSUserDefaults standardUserDefaults] valueForKey:@"lastPurgeActivityDate"];
    if (lastPurgeDate) {
        if ([[NSDate date] timeIntervalSinceDate:lastPurgeDate] > 60*60*24* 7) { //Purge data each 7 days
            NSDate *purgeDate = [[NSDate date] dateByAddingTimeInterval: -60*60*24*7]; //Need purge date more than 7 days old
            
            [self.activities enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                NSMutableArray *activities = obj;
                __block NSInteger purgeIndex = NSNotFound;
                [activities enumerateObjectsUsingBlock:^(VehicleActivity *act, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([act.startTime timeIntervalSinceDate:purgeDate] < 0) {
                        purgeIndex = idx;
                        *stop = YES;
                    }
                }];
                if (purgeIndex != NSNotFound) {
                    [activities removeObjectsInRange:NSMakeRange(purgeIndex, activities.count-purgeIndex)];
                }
            }];
            [[NSUserDefaults standardUserDefaults] setValue:[NSDate date] forKey:@"lastPurgeActivityDate"];
            [self autoSaveActivities];
        }
    }else{
        [[NSUserDefaults standardUserDefaults] setValue:[NSDate date] forKey:@"lastPurgeActivityDate"];
    }
}

@end
