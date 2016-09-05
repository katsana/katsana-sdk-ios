//
//  KMUserManager.h
//  KatsanaMap
//
//  Created by Wan Ahmad Lutfi on 12/14/15.
//  Copyright © 2015 bijokmind. All rights reserved.
//

static NSString* KMUserLogonSuccessNotification  = @"userLogonSuccessNotf";
static NSString* KMUserWillLogoutNotification  = @"userWillLogoutNotf";
static NSString* KMUserLogoutNotification  = @"userLogoutNotf";
static NSString* KMVehicleLocationUpdatedNotification  = @"vehicleLocationUpdatedNotf";

@class KMUser;
@class KMVehicle;
@class KMVehicleDayHistory;
@class KMAddress;
@class KMVehiclePosition;
@class KMNotificationSettings;

@interface KMUserManager : NSObject;

//@property (nonatomic, strong) NSString *baseURL;

@property (nonatomic, readonly, copy) NSString *token;
@property (nonatomic, strong) KMUser *currentUser;
@property (nonatomic, strong) KMVehicle *vehicle;
@property (nonatomic, strong) NSArray *vehicles;
@property (nonatomic, strong) KMNotificationSettings *notificationSettings;

@property (nonatomic, strong) KMVehiclePosition *lastVehiclePosition;
@property (nonatomic, strong) NSDate *lastUpdateToken;

+ (instancetype) sharedInstance;

- (BOOL)websocketSupported;
- (BOOL)haveOnlyOneVehicle;
- (NSString*)lastVehicleId;
- (NSArray*)lastVehicleIds;
- (NSArray*)lastVehicleImeis;
- (KMVehicle*)vehicleWithVehicleId:(NSString*)vehicleId;

- (void)refreshToken:(void (^)(BOOL))success;
- (void)loginWithUserName:(NSString *)email password:(NSString*)password user:(void (^)(KMUser *))success failure:(void (^)(NSError *error))failure;
- (void)loadFirebaseUserToken:(void (^)(NSString *token))success failure:(void (^)(NSError *error))failure;

//Profile
- (void)saveUserProfile:(void (^)(BOOL success, NSDictionary *responseError))success;
- (void)saveUserProfileImage:(UIImage*)image success:(void (^)(BOOL success))success;
- (void)saveVehicleProfile:(NSString*)vehicleId success:(void (^)(BOOL success, NSDictionary *responseError))success;
- (void)saveVehicleProfileImage:(UIImage*)image vehicleId:(NSString*)vehicleId success:(void (^)(BOOL success))success;

//Vehicle
-(void)loadVehicleWithId:(NSString*)vehicleId vehicle:(void (^)(KMVehicle *))success failure:(void (^)(NSError *error))failure;
-(void)loadVehicles:(void (^)(NSArray *))success failure:(void (^)(NSError *error))failure;
-(void)loadVehicles:(void (^)(NSArray *))success forceLoad:(BOOL)forceLoad failure:(void (^)(NSError *error))failure;
- (void)loadFirstVehicle:(void (^)(KMVehicle *))success failure:(void (^)(NSError *error))failure;;

//Vehicle Location
-(void)loadVehicleLocationWithId:(NSString*)vehicleId vehicle:(void (^)(KMVehiclePosition *))success failure:(void (^)(NSError *error))failure;
-(void)loadAllVehicleLocations:(void (^)(NSArray *))success failure:(void (^)(NSError *error))failure;

//History
-(void)loadVehicleHistoryWithId:(NSString*)vehicleId date:(NSDate*)date vehicle:(void (^)(KMVehicleDayHistory *))success failure:(void (^)(NSError *error))failure;
//!Load trip history, if no cached data, get summary data
-(void)loadVehicleHistoriesWithId:(NSString*)vehicleId fromDate:(NSDate*)fromDate toDate:(NSDate*)toDate histories:(void (^)(NSArray *histories))success failure:(void (^)(NSError *error))failure;
-(void)loadVehicleHistoryWithId:(NSString*)vehicleId date:(NSDate*)date forceLoad:(BOOL)forceLoad UTCDate:(BOOL)useUTCDate vehicle:(void (^)(KMVehicleDayHistory *))success failure:(void (^)(NSError *error))failure;
- (void)loadTripSummaryTodayForVehicleId:(NSString*)vehicleId success:(void (^)(KMVehicleDayHistory *dayHistory))success;

//Address
-(void)loadAddressWithLocation:(CLLocationCoordinate2D)location address:(void (^)(KMAddress *))success failure:(void (^)(NSError *error))failure;

//Notifications
-(void)loadNotificationSettings:(void (^)(KMNotificationSettings *))success failure:(void (^)(NSError *error))failure;
- (void)saveServerNotificationSettings:(void (^)(BOOL success))success forTypeKeypath:(NSString*)typeKeypath;

- (void)logoutCurrentUser;

@end
