//
//  KMUserManager.m
//  KatsanaMap
//
//  Created by Wan Ahmad Lutfi on 12/14/15.
//  Copyright © 2015 bijokmind. All rights reserved.
//

#import "KMUserManager.h"
#import "KMUser.h"
#import "KMVehicle.h"
#import "KMVehicleDayHistory.h"
#import "KMMappingProvider.h"
#import "KMAddress.h"
//#import "NSDate+Compare.h"
#import "KMNotificationSettings.h"
#import "KMNotificationSettingsObject.h"
#import "KMAvatar.h"
#import "UIImage+Extension.h"
#import "KMObjectManager.h"
#import "KMObjectManager.h"

@interface KMUserManager ()

@property (nonatomic, strong) KMObjectManager *manager;

- (NSURL*)baseURL;

@end

@implementation KMUserManager{
    NSDate *_lastLoadAllVehiclesDate;
    NSArray *_lastVehicleIds;
    NSArray *_lastVehicleImeis;
}

#pragma mark - Getter

static KMUserManager *sharedPeerToPeer = nil;
+ (instancetype) sharedInstance {
    if (!sharedPeerToPeer) {
        sharedPeerToPeer = [[[self class] alloc] init];
    }
    return sharedPeerToPeer;
}

- (NSURL*)baseURL{
    return self.manager.baseURL;
}

#pragma mark - Setter

- (void)setVehicle:(KMVehicle *)vehicle{
    _vehicle = vehicle;
    [[NSUserDefaults standardUserDefaults] setObject:vehicle.vehicleId forKey:@"lastVehicleId"];
    
}

- (void)setVehicles:(NSArray *)vehicles{
    _lastVehicleIds = [_vehicles valueForKey:@"vehicleId"];
    _lastVehicleImeis = [_vehicles valueForKey:@"imei"];
    _vehicles = vehicles;
}

- (NSString*)lastVehicleId{
    NSString *vehicleId = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastVehicleId"];
    return vehicleId;
}

- (NSArray*)lastVehicleIds{
    return _lastVehicleIds;
}

- (NSArray*)lastVehicleImeis{
    return _lastVehicleImeis;
}

- (void)setCurrentUser:(KMUser *)currentUser{
    _currentUser = currentUser;
}

#pragma mark - Getter

- (KMVehicle*)vehicleWithVehicleId:(NSString*)vehicleId{
    for (KMVehicle *vehicle in self.vehicles) {
        if ([vehicle.vehicleId isEqualToString:vehicleId]) {
            return vehicle;
        }
    }
    return nil;
}

#pragma mark User

- (void)refreshToken:(void (^)(BOOL))success{
    NSString *string = [NSString stringWithFormat:@"%@auth/refresh?token=%@", self.baseURL.path, self.token];
    NSURL *url = [NSURL URLWithString:string];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    RKHTTPRequestOperation *operation = [[RKHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFRKHTTPRequestOperation *operation, id responseObject) {
        
        NSError *errorJson=nil;
        NSDictionary* responseDict = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:&errorJson];
        if (responseDict[@"token"]) {
            _token = responseDict[@"token"];
            [self.manager.HTTPClient setDefaultHeader:@"Authorization" value:[@"Bearer " stringByAppendingString:responseDict[@"token"]]];
            _lastUpdateToken = [NSDate date];
            if (success) success(YES);
        }else{
            if (success) success(NO);
        }
    } failure:^(AFRKHTTPRequestOperation *operation, NSError *error) {
        if (success) success(NO);
    }];
    
    [operation start];
    
    [self performSelector:@selector(refreshToken:) withObject:nil afterDelay:60*58];
}

- (void) loadAuthenticatedUser:(void (^)(KMUser *))success failure:(void (^)(NSError * error))failure {
    __weak typeof(self) weakSelf = self;
    [self.manager getObjectsAtPath:@"profile" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        if (success) {
            KMUser *currentUser = (KMUser *)[mappingResult.array firstObject];
            success(currentUser);
            weakSelf.currentUser = currentUser;
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(error);
            DDLogError(@"Error getting user profile: %@", error.localizedDescription);
        }
    }];
}

-(void)loginWithUserName:(NSString *)email password:(NSString*)password user:(void (^)(KMUser *user))success failure:(void (^)(NSError *error))failure{
    __weak typeof(self) weakSelf = self;
    KMObjectManager *manager = self.manager;
    
//    BOOL devMode = [[NSUserDefaults standardUserDefaults] boolForKey:@"devMode"];
//    if (devMode || [email.lowercaseString containsString:@"lutfime_2000"]) {
//        [[FIRAnalyticsConfiguration sharedInstance] setAnalyticsCollectionEnabled:NO];
//    }else{
//        [[FIRAnalyticsConfiguration sharedInstance] setAnalyticsCollectionEnabled:YES];
//    }
    
    NSDictionary *params = @{@"email" : email, @"password" : password};
    AFRKHTTPClient *theclient = [RKObjectManager sharedManager].HTTPClient;
    theclient.parameterEncoding = AFRKJSONParameterEncoding;
    NSMutableURLRequest *request = [theclient requestWithMethod:@"POST"
                                                           path:[self.baseURL.path stringByAppendingString:@"auth"]
                                                     parameters:params];
    RKHTTPRequestOperation *oper = [[RKHTTPRequestOperation alloc] initWithRequest:request];
    [oper setCompletionBlockWithSuccess:^(AFRKHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
        NSString *token = json[@"token"];
        if (token) {
            _token = token;
            _lastUpdateToken = [NSDate date];
            [manager.HTTPClient setDefaultHeader:@"Authorization" value:[@"Bearer " stringByAppendingString:token]];
            [weakSelf loadAuthenticatedUser:^(KMUser *user) {
                weakSelf.currentUser = user;
                success(user);
            } failure:^(NSError *error) {
                failure(error);
                NSLog(@"%@", error);
            }];
        }else{
            NSMutableDictionary* details = [NSMutableDictionary dictionary];
            if (json[@"error"]) {
                [details setValue:json[@"error"] forKey:NSLocalizedDescriptionKey];
            }
            NSError *error = [NSError errorWithDomain:@"KMKatsanaDomain" code:101 userInfo:details];
            failure(error);
        }
    } failure:^(AFRKHTTPRequestOperation *operation, NSError *error) {
        failure(error);
        DDLogError(@"%@", error.localizedDescription);
    }];
    [oper start];
}

- (void) loadFirebaseUserToken:(void (^)(NSString *token))success failure:(void (^)(NSError *error))failure {
    [self.manager getObjectsAtPath:@"firebase/token" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        if (success) {
            NSError *error;
            id response = operation.HTTPRequestOperation.responseData;
            if (response) {
                NSDictionary* json = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableLeaves error:&error];
                NSString *token = json[@"token"];
                success(token);
            }else{
                failure(nil);
                DDLogError(@"Error loading firebase token: %@", @"No response data");
            }
            
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        id response = operation.HTTPRequestOperation.responseData;
        NSString *token;
        if (response) {
            NSDictionary* json = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableLeaves error:&error];
            token = json[@"token"];
        }
        if (token) {
            success(token);
        }else{
            if (failure) {
                DDLogError(@"Error loading firebase token: %@", error.localizedDescription);
                failure(error);
            }
        }
    }];
}

- (void)saveUserProfile:(void (^)(BOOL success, NSDictionary *responseError))success {
    KMUser *user = self.currentUser;
    
    [self.manager patchObject:user path:@"profile" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        KMUser *updatedUser = (KMUser *)[mappingResult.array firstObject];
        
        success(updatedUser, nil);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        
        NSData *data = operation.HTTPRequestOperation.responseData ;
        if (data) {
            NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
            if (json[@"id"]) {
                //If inside json has id, means that it has been saved succesfully
                success(self.currentUser, nil);
            }else{
                success(NO, json);
                DDLogError(@"Error saving user profile: %@", error.localizedDescription);
            }
        }else{
            success(NO, nil);
            DDLogError(@"Error saving user profile: %@", error.localizedDescription);
        }
    }];
}

- (void)saveUserProfileImage:(UIImage*)image success:(void (^)(BOOL success))success{
    if (!image) {
        image = [UIImage imageWithColor:[UIColor whiteColor]];
    }
    image = [image fixOrientation];
    
    CGFloat maxSize = 600;
    CGFloat scale = [[UIScreen mainScreen] scale];
    if (scale > 1) maxSize /= scale;
    
    if (image.size.width > maxSize || image.size.height > maxSize) {
        CGFloat factor = image.size.width/image.size.height;
        if (factor > 1) {
            image = [image scaleToSize:CGSizeMake(maxSize, maxSize / factor)];
        }else{
            image = [image scaleToSize:CGSizeMake(maxSize * factor, maxSize)];
        }
    }
    
    //Just put it although still not saved
    
    self.currentUser.avatarImage = image;
    
    __weak typeof(self) weakSelf = self;
    
    KMAvatar *avatar = [[KMAvatar alloc] init];
    avatar.file = image;
    NSMutableURLRequest *request = [self.manager multipartFormRequestWithObject:avatar method:RKRequestMethodPOST path:@"profile/avatar" parameters:nil constructingBodyWithBlock:^(id<AFRKMultipartFormData> formData) {
        [formData appendPartWithFileData:UIImageJPEGRepresentation(image, 0.8)
                                    name:@"file"
                                fileName:@"avatar.png"
                                mimeType:@"image/jpeg"];
    }];
    
    RKObjectRequestOperation *operation = [self.manager objectRequestOperationWithRequest:request success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        success(YES);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSData *data = operation.HTTPRequestOperation.responseData ;
        if (data) {
            NSDictionary* json = [NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData options:NSJSONReadingMutableLeaves error:&error];
            if (json[@"thumb"]) {
                weakSelf.currentUser.avatarURLPath = json[@"thumb"];
                [[KMCacheManager sharedInstance] cacheData:UIImagePNGRepresentation(image) identifier:weakSelf.currentUser.avatarURLPath.lastPathComponent];
                success(YES);
                DDLogInfo(@"Success save profile image");
            }else{
                success(NO);
            }
        }else{
            success(NO);
        }
    }];
    [self.manager enqueueObjectRequestOperation:operation];
}

- (void)saveVehicleProfile:(NSString*)vehicleId success:(void (^)(BOOL success, NSDictionary *responseError))success {
    KMVehicle *vehicle = [self vehicleWithVehicleId:vehicleId];
    if (!vehicleId) {
        success(NO, nil);
        return;
    }
    
    NSString *path = [NSString stringWithFormat:@"vehicles/%@", vehicleId];
    [self.manager patchObject:vehicle path:path parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        KMVehicle *updatedVehicle = (KMVehicle *)[mappingResult.array firstObject];
        
        success(updatedVehicle, nil);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        
        NSData *data = operation.HTTPRequestOperation.responseData ;
        if (data) {
            NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
            if (json[@"device"]) {
                //If inside json has id, means that it has been saved succesfully
                success(vehicle, nil);
            }else{
                success(NO, json);
                DDLogError(@"Error saving vehicle profile: %@", error.localizedDescription);
            }
        }else{
            success(NO, nil);
            DDLogError(@"Error saving vehicle profile: %@", error.localizedDescription);
        }
    }];
}

- (void)saveVehicleProfileImage:(UIImage*)image vehicleId:(NSString*)vehicleId success:(void (^)(BOOL success))success{
    if (!image) {
        image = [UIImage imageWithColor:[UIColor whiteColor]];
    }
    
    CGFloat maxSize = 600;
    CGFloat scale = [[UIScreen mainScreen] scale];
    if (scale > 1) maxSize /= scale;
    
    if (image.size.width > maxSize || image.size.height > maxSize) {
        CGFloat factor = image.size.width/image.size.height;
        if (factor > 1) {
            image = [image scaleToSize:CGSizeMake(maxSize, maxSize / factor)];
        }else{
            image = [image scaleToSize:CGSizeMake(maxSize * factor, maxSize)];
        }
    }
    
    //Just put it although still not saved
    KMVehicle *vehicle = [self vehicleWithVehicleId:vehicleId];
    vehicle.carImage = image;
    
    __weak typeof(self) weakSelf = self;
    
    KMAvatar *avatar = [[KMAvatar alloc] init];
    avatar.file = image;
    NSString *path = [NSString stringWithFormat:@"vehicles/%@/avatar", vehicleId];
    NSMutableURLRequest *request = [self.manager multipartFormRequestWithObject:avatar method:RKRequestMethodPOST path:path parameters:nil constructingBodyWithBlock:^(id<AFRKMultipartFormData> formData) {
        [formData appendPartWithFileData:UIImageJPEGRepresentation(image, 0.8)
                                    name:@"file"
                                fileName:@"avatar.png"
                                mimeType:@"image/jpeg"];
    }];
    
    RKObjectRequestOperation *operation = [self.manager objectRequestOperationWithRequest:request success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        success(YES);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSData *data = operation.HTTPRequestOperation.responseData ;
        if (data) {
            NSDictionary* json = [NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData options:NSJSONReadingMutableLeaves error:&error];
            if (json[@"thumb"]) {
                weakSelf.currentUser.avatarURLPath = json[@"thumb"];
                [[KMCacheManager sharedInstance] cacheData:UIImagePNGRepresentation(image) identifier:weakSelf.currentUser.avatarURLPath.lastPathComponent];
                success(YES);
                DDLogInfo(@"Success save vehicle image");
            }else{
                success(NO);
            }
        }else{
            success(NO);
        }
    }];
    [self.manager enqueueObjectRequestOperation:operation];
}


#pragma mark Vehicle

- (void)loadVehicleWithId:(NSString*)vehicleId vehicle:(void (^)(KMVehicle *))success failure:(void (^)(NSError * error))failure {
    //No need to load again if using websocket
    KMVehicle *vehicle = [self vehicleWithVehicleId:vehicleId];
    if (vehicle && vehicle.websocket) {
        self.vehicle = vehicle;
        success(vehicle);
        return;
    }
    
    NSString *path = [NSString stringWithFormat:@"vehicles/%@", vehicleId];
    __weak typeof(self) weakSelf = self;
    [self.manager getObjectsAtPath:path parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        if (success) {
            KMVehicle *vehicle = (KMVehicle *)[mappingResult.array firstObject];
            weakSelf.vehicle = vehicle;
            success(vehicle);
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        if (failure) {
//            NSDictionary* json = [NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData options:NSJSONReadingMutableLeaves error:&error];
            failure(error);
        }
        DDLogError(@"Error loading vehicle id %@", vehicleId);
        
    }];
}

-(void)loadVehicleLocationWithId:(NSString*)vehicleId vehicle:(void (^)(KMVehiclePosition *))success failure:(void (^)(NSError * error))failure{
    if (!self.token || !vehicleId) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    NSString *path = [NSString stringWithFormat:@"vehicles/%@/location", vehicleId];
    [self.manager getObjectsAtPath:path parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        if (success) {
            KMVehiclePosition *pos = (KMVehiclePosition *)[mappingResult.array firstObject];
            weakSelf.lastVehiclePosition = pos;
//            DLog(@"%.10f", pos.coordinate.latitude);
            success(pos);
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

-(void)loadAllVehicleLocations:(void (^)(NSArray *))success failure:(void (^)(NSError * error))failure{
    if (!self.token) {
        return;
    }

    __block NSInteger count = 0;
    for (KMVehicle *vehicle in self.vehicles) {
        [self loadVehicleLocationWithId:vehicle.vehicleId vehicle:^(KMVehiclePosition *pos) {
            vehicle.current = pos;
            count ++;

            if (count == self.vehicles.count) {
                success(self.vehicles);
            }
        } failure:^(NSError *error) {
            failure(error);
        }];
    }
}

-(void)loadVehicles:(void (^)(NSArray *))success failure:(void (^)(NSError * error))failure{
    [self loadVehicles:success forceLoad:NO failure:failure];
}

-(void)loadVehicles:(void (^)(NSArray *))success forceLoad:(BOOL)forceLoad failure:(void (^)(NSError * error))failure{
    if (!forceLoad && self.vehicles.count > 0 && [[NSDate date] timeIntervalSinceDate:_lastLoadAllVehiclesDate] < 60*60) {
        success(self.vehicles);
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [self.manager getObjectsAtPath:@"vehicles" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        if (success) {
            
            NSArray *vehicles = mappingResult.array;
            weakSelf.vehicles = vehicles;
            success(vehicles);
            
            _lastLoadAllVehiclesDate = [NSDate date];
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (void)loadFirstVehicle:(void (^)(KMVehicle *))success failure:(void (^)(NSError * error))failure{
    __weak typeof(self) weakSelf = self;
    
    [self loadVehicles:^(NSArray *vehicles) {
        KMVehicle *firstVehicle = vehicles.firstObject;
        weakSelf.vehicle = firstVehicle;
        weakSelf.vehicles = vehicles;
        
        success(firstVehicle);
        
    } failure:^(NSError *error) {
        failure(error);
    }];
}


#pragma mark  Trip

-(void)loadVehicleHistoryWithId:(NSString*)vehicleId date:(NSDate*)date vehicle:(void (^)(KMVehicleDayHistory *))success failure:(void (^)(NSError * error))failure{
    [self loadVehicleHistoryWithId:vehicleId date:date forceLoad:NO UTCDate:NO vehicle:^(KMVehicleDayHistory *dayHistory) {
        success(dayHistory);
    } failure:^(NSError *error) {
        failure(error);
    }];
}

-(void)loadVehicleHistoryWithId:(NSString*)vehicleId date:(NSDate*)date forceLoad:(BOOL)forceLoad UTCDate:(BOOL)useUTCDate vehicle:(void (^)(KMVehicleDayHistory *))success failure:(void (^)(NSError * error))failure{
    
    if (useUTCDate) {
        NSTimeInterval timeZoneOffset = [[NSTimeZone systemTimeZone] secondsFromGMTForDate:date];
        date = [date dateByAddingTimeInterval:timeZoneOffset];
    }
    
    //If force load need always to load from server
    if (!forceLoad) {
        KMVehicleDayHistory *history = [[KMCacheManager sharedInstance] vehicleDayHistoryForDate:date vehicleId:vehicleId];
        if (history && history.needLoadTripHistory == NO) {
            history.owner = [self vehicleWithVehicleId:vehicleId];
            success(history);
            return;
        }
    }

    NSDateComponents *theDateComps = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:date];
    NSString *dateStr = [NSString stringWithFormat:@"%lu/%lu/%lu", (long)theDateComps.year, (long)theDateComps.month, (long)theDateComps.day];
    
    NSString *path = [NSString stringWithFormat:@"vehicles/%@/travels/%@", vehicleId, dateStr];
    [self.manager getObjectsAtPath:path parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        if (success) {
            KMVehicleDayHistory *history = (KMVehicleDayHistory *)[mappingResult.array firstObject];
            history.historyDate = date;
            history.owner = [self vehicleWithVehicleId:vehicleId];
            [[KMCacheManager sharedInstance] cacheData:history identifier:vehicleId];
            
            success(history);
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(error);
            DDLogWarn(@"Error getting vehicle history %@: %@", dateStr, error.localizedDescription);
        }
    }];
}

- (void)loadTripSummaryTodayForVehicleId:(NSString*)vehicleId success:(void (^)(KMVehicleDayHistory *dayHistory))success{
    NSString *path = [NSString stringWithFormat:@"vehicles/%@/summaries/today", vehicleId];
    [self.manager getObjectsAtPath:path parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        if (success) {
            KMVehicleDayHistory *history = (KMVehicleDayHistory *)mappingResult.array.firstObject;
            success(history);
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        DDLogWarn(@"Error getting today summary : %@", error.localizedDescription);
        success(nil);
    }];
}

-(void)loadVehicleHistoriesWithId:(NSString*)vehicleId fromDate:(NSDate*)fromDate toDate:(NSDate*)toDate histories:(void (^)(NSArray *histories))success failure:(void (^)(NSError *error))failure{
    
    if ([toDate timeIntervalSinceDate:[NSDate date]] > 0 && [fromDate timeIntervalSinceDate:[NSDate date]] > 0) {
        success(nil);
        return;
    }
    
    if ([toDate timeIntervalSinceDate:[NSDate date]] > 0) {
        toDate = [NSDate date];
    }
    if ([fromDate timeIntervalSinceDate:[NSDate date]] > 0) {
        fromDate = [NSDate date];
    }

    __block NSMutableArray *histories = [NSMutableArray array];
    NSDate *originalFromDate = fromDate;
    
    NSDateComponents *oneDay = [NSDateComponents new];
    oneDay.day = 1;
    NSDate *loopDate = fromDate;
    NSInteger totalCount = 0;
    BOOL canUpdateFromDate = YES;
//    NSTimeInterval timeZoneOffset = [[NSTimeZone systemTimeZone] secondsFromGMTForDate:loopDate];
//    loopDate = [loopDate dateByAddingTimeInterval:-timeZoneOffset];
    
    //Get total count and add cached history
    while ([loopDate compare:toDate] == NSOrderedAscending || [loopDate compare:toDate] == NSOrderedSame){
        KMVehicleDayHistory *history = [[KMCacheManager sharedInstance] vehicleDayHistoryForDate:loopDate vehicleId:vehicleId];
        
        loopDate = [[NSCalendar currentCalendar] dateByAddingComponents:oneDay toDate:loopDate options:0];
        
        if (history) {
            [histories addObject:history];
            if (canUpdateFromDate) {
                fromDate = loopDate;
            }
        }else{
            //If not cached history found, will need to fetch from server, so from update must not change anymore
            canUpdateFromDate = NO;
        }
        totalCount ++;
    }
    if (histories.count == totalCount && totalCount > 0) {
        histories = [[histories reverseObjectEnumerator] allObjects].mutableCopy;
        success(histories);
        return;
    }
    
    NSDateComponents *theDateComps = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:fromDate];
    NSString *fromDateStr = [NSString stringWithFormat:@"%lu/%lu/%lu", (long)theDateComps.year, (long)theDateComps.month, (long)theDateComps.day];
    theDateComps = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:toDate];
    NSString *toDateStr = [NSString stringWithFormat:@"%lu/%lu/%lu", (long)theDateComps.year, (long)theDateComps.month, (long)theDateComps.day];
    
    NSString *path = [NSString stringWithFormat:@"vehicles/%@/summaries/duration", vehicleId];
    NSDictionary *params = @{@"start" : fromDateStr, @"end" : toDateStr};
    //    __weak typeof(self) weakSelf = self;
    [self.manager getObjectsAtPath:path parameters:params success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        if (success) {
            NSArray *theHistories = (NSArray *)mappingResult.array ;
//            history.historyDate = date;
//            [[KMCacheManager sharedInstance] cacheData:history identifier:vehicleId];
            for (KMVehicleDayHistory *history in theHistories) {
                history.needLoadTripHistory = YES;
                
                KMVehicleDayHistory *needRemoveHistory;
                for (KMVehicleDayHistory *theHistory in histories) {
                    if ([[NSCalendar currentCalendar] isDate:theHistory.historyDate inSameDayAsDate:history.historyDate]) {
                        history.trips = theHistory.trips;
                        needRemoveHistory = theHistory;
                        history.needLoadTripHistory = NO;
                        break;
                    }
                }
                if (needRemoveHistory) {
                    [histories removeObject:needRemoveHistory];
                }
                
                [[KMCacheManager sharedInstance] cacheData:history identifier:vehicleId];
            }
            [histories addObjectsFromArray:theHistories];
            [histories sortUsingSelector:@selector(compare:)];
            
            NSDate *currentDate = originalFromDate;
            for (KMVehicleDayHistory *history in histories) {
                while (![[NSCalendar currentCalendar] isDate:history.historyDate inSameDayAsDate:currentDate]) {
                    CGFloat duration  = [history.historyDate timeIntervalSinceDate:currentDate];
                    if (duration > 0) {
                        KMVehicleDayHistory *currentHistory = [[KMVehicleDayHistory alloc] init];
                        currentHistory.historyDate = currentDate;
                        [[KMCacheManager sharedInstance] cacheData:currentHistory identifier:vehicleId];
                        currentDate = [[NSCalendar currentCalendar] dateByAddingComponents:oneDay toDate:currentDate options:0];
                    }else{
                        currentDate = history.historyDate;
                        break;
                    }
                }
                currentDate = [[NSCalendar currentCalendar] dateByAddingComponents:oneDay toDate:currentDate options:0];
            }
            histories = [[histories reverseObjectEnumerator] allObjects].mutableCopy;
            
            success(histories);
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(error);
            DDLogWarn(@"Error getting vehicle history %@: %@", fromDateStr, error.localizedDescription);
        }
    }];

    return;
}

-(void)loadAddressWithLocation:(CLLocationCoordinate2D)location address:(void (^)(KMAddress *))success failure:(void (^)(NSError * error))failure{
    [[KMCacheManager sharedInstance] addressForCoordinate:location completionBlock:^(KMAddress *address) {
        if (address) {
            success(address);
        }else{
            NSDictionary *params = @{@"latitude" : @(location.latitude), @"longitude" : @(location.longitude)};
            [self.manager getObjectsAtPath:@"address" parameters:params success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                if (success) {
                    KMAddress *address = (KMAddress *)[mappingResult.array firstObject];
                    address.latitude = location.latitude; //The location result may different, so need to make it equal
                    address.longitude = location.longitude;
                    
                    if (address.optimizedAddress.length <= 10) {
                        CLGeocoder *ceo = [[CLGeocoder alloc]init];
                        CLLocation *loc = [[CLLocation alloc]initWithLatitude:location.latitude longitude:location.longitude];
                        
                        __block NSString *address;
                        
                        [ceo reverseGeocodeLocation:loc completionHandler:^(NSArray *placemarks, NSError *error) {
                            CLPlacemark *placemark = [placemarks objectAtIndex:0];
                            NSMutableArray *addressComps = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] mutableCopy];
                            [addressComps removeLastObject];
                            address = [addressComps componentsJoinedByString:@", "];
                            
                            KMAddress *theAddress = [[KMAddress alloc] init];
                            theAddress.latitude = location.latitude;
                            theAddress.longitude = location.longitude;
                            theAddress.address = address;
                            [[KMCacheManager sharedInstance] cacheData:theAddress identifier:nil];
                            success(theAddress);
                        }
                         ];
                    }else{
                    
                        [[KMCacheManager sharedInstance] cacheData:address identifier:nil];
                        success(address);
                    }
                }
            } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                if (failure) {
                    failure(error);
                }
            }];
        }
    }];
}


#pragma mark - Notifications

-(void)loadNotificationSettings:(void (^)(KMNotificationSettings *notificationSettings))success failure:(void (^)(NSError *error))failure{
    __weak typeof(self) weakSelf = self;
    [self.manager getObjectsAtPath:@"notifications/settings" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        if (success) {
            KMNotificationSettings *notfSettings = [mappingResult.array firstObject];
            weakSelf.notificationSettings = notfSettings;
            success(notfSettings);
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(error);
        }
        DDLogError(@"Error loading notification settings");
    }];
}

- (void)saveServerNotificationSettings:(void (^)(BOOL success))success forTypeKeypath:(NSString*)typeKeypath{
//    id value = [self.notificationSettings patchValueForKeypath:typeKeypath];
    
    BOOL needUpdateBoolValue = NO;
    BOOL needUpdateAll = [self.notificationSettings needUpdateAllForKeypath:typeKeypath boolValue:&needUpdateBoolValue];
    NSArray *objs = [self.notificationSettings valueForKey:typeKeypath];
    NSString *path = [NSString stringWithFormat:@"notifications/settings/%@", typeKeypath];
    if (needUpdateAll) {
        NSDictionary *dicto = @{@"enabled" : @(needUpdateBoolValue)}.mutableCopy;
        [self.manager patchObject:dicto path:path parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            success(YES);
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            NSDictionary* json = [NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData options:0 error:&error];
            __block BOOL successPatch = NO;
            [json enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                if([key isEqualToString:typeKeypath]){
                    successPatch = YES;
                    for (KMNotificationSettingsObject* settingsObj in objs) {
                        settingsObj.needUpdate = NO;
                    }
                    *stop = YES;
                }
            }];
            success(successPatch);
        }];
    }else{
        
        for (KMNotificationSettingsObject* settingsObj in objs) {
            if (!settingsObj.needUpdate) {
                continue;
            }
            NSDictionary *dicto = @{@"device_id" : settingsObj.vehicleId, @"enabled" : @(settingsObj.enabled)}.mutableCopy;
            [self.manager patchObject:dicto path:path parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                success(YES);
            } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                //Due to how json passed from server, there seems no way to use normal RestKit API to patch object. So we result to using json approach, the good thing is the patch to server does work, only  returned json cannot be passed to app using normal RestKit method.
                NSDictionary* json = [NSJSONSerialization JSONObjectWithData:operation.HTTPRequestOperation.responseData options:0 error:&error];
                __block BOOL successPatch = NO;
                [json enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                    if([key isEqualToString:typeKeypath]){
                        successPatch = YES;
                        settingsObj.needUpdate = NO;
                        *stop = YES;
                    }
                }];
                success(successPatch);
            }];
        }
    }
}


#pragma mark - Setup Helpers

- (void) setupResponseDescriptors {
    [self.manager setupResponseDescriptors];
    
    RKResponseDescriptor *authenticatedUserResponseDescriptors = [RKResponseDescriptor responseDescriptorWithMapping:[KMMappingProvider userMapping] method:RKRequestMethodGET pathPattern:@"profile" keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    RKResponseDescriptor *vehicleResponse = [RKResponseDescriptor responseDescriptorWithMapping:[KMMappingProvider vehicleMapping] method:RKRequestMethodGET pathPattern:nil keyPath:@"device" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    RKResponseDescriptor *locationResponse = [RKResponseDescriptor responseDescriptorWithMapping:[KMMappingProvider vehiclePositionMapping] method:RKRequestMethodGET pathPattern:@"vehicles/:id/location" keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    RKResponseDescriptor *vehiclesResponse = [RKResponseDescriptor responseDescriptorWithMapping:[KMMappingProvider vehicleMapping] method:RKRequestMethodGET pathPattern:@"vehicles" keyPath:@"devices" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    RKResponseDescriptor *vehicleHistoryResponse = [RKResponseDescriptor responseDescriptorWithMapping:[KMMappingProvider vehicleHistoryMapping] method:RKRequestMethodGET pathPattern:@"vehicles/:id/travels/:year/:month/:day" keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    RKResponseDescriptor *vehicleSummaryResponse = [RKResponseDescriptor responseDescriptorWithMapping:[KMMappingProvider daySummaryMapping] method:RKRequestMethodGET pathPattern:@"vehicles/:id/summaries/duration" keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    RKResponseDescriptor *vehicleSummaryTodayResponse = [RKResponseDescriptor responseDescriptorWithMapping:[KMMappingProvider daySummaryMapping] method:RKRequestMethodGET pathPattern:@"vehicles/:id/summaries/today" keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    RKResponseDescriptor *addressResponse = [RKResponseDescriptor responseDescriptorWithMapping:[KMMappingProvider addressMapping] method:RKRequestMethodGET pathPattern:@"address" keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    RKResponseDescriptor *notificationSettingsResponse = [RKResponseDescriptor responseDescriptorWithMapping:[KMMappingProvider notificationSettingsMapping] method:RKRequestMethodAny pathPattern:@"notifications/settings" keyPath:@"settings" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    RKRequestDescriptor *notificationSettingsRequest = [RKRequestDescriptor requestDescriptorWithMapping:[KMMappingProvider notificationSettingsRequestMapping]
                                                                                 objectClass:[NSMutableDictionary class]
                                                                                 rootKeyPath:nil method:RKRequestMethodPATCH];
    
    RKRequestDescriptor *profileRequest = [RKRequestDescriptor requestDescriptorWithMapping:[[KMMappingProvider profileRequestMapping] inverseMapping]
                                                                                             objectClass:[KMUser class]
                                                                                             rootKeyPath:nil method:RKRequestMethodPATCH];
    
    RKRequestDescriptor *avatarRequest = [RKRequestDescriptor requestDescriptorWithMapping:[KMMappingProvider avatarRequestMapping]
                                                                                objectClass:[KMAvatar class]
                                                                                rootKeyPath:nil method:RKRequestMethodPOST];
    
    RKRequestDescriptor *vehicleRequest = [RKRequestDescriptor requestDescriptorWithMapping:[[KMMappingProvider vehicleRequestMapping] inverseMapping]
                                                                               objectClass:[KMVehicle class]
                                                                               rootKeyPath:nil method:RKRequestMethodPATCH];
    
    RKRequestDescriptor *vehicleAvatarRequest = [RKRequestDescriptor requestDescriptorWithMapping:[KMMappingProvider avatarRequestMapping]
                                                                               objectClass:[KMAvatar class]
                                                                               rootKeyPath:nil method:RKRequestMethodPOST];

    
    [self.manager addRequestDescriptorsFromArray:@[profileRequest, avatarRequest, vehicleRequest, vehicleAvatarRequest, notificationSettingsRequest]];
    [self.manager addResponseDescriptorsFromArray:@[authenticatedUserResponseDescriptors, vehicleResponse, locationResponse, vehiclesResponse, vehicleHistoryResponse, addressResponse, notificationSettingsResponse, vehicleSummaryResponse, vehicleSummaryTodayResponse]];

}

#pragma mark - 

- (void)logoutCurrentUser{
    [[NSNotificationCenter defaultCenter] postNotificationName:KMUserWillLogoutNotification object:nil];
    
    self.currentUser = nil;
    self.vehicle = nil;
    self.vehicles = nil;
    _token = nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:KMUserLogoutNotification object:nil];
}

#pragma mark - Getter

- (BOOL)haveOnlyOneVehicle{
    if (self.vehicles.count <= 1) {
        return YES;
    }
    return NO;
}

- (BOOL)websocketSupported{
    BOOL supported = NO;
    for (KMVehicle *vehicle in self.vehicles) {
        if (vehicle.websocket) {
            supported = YES;
        }
    }
    return supported;
}



@end
