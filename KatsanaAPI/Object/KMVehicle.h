//
//  KMVehicle.h
//  KatsanaMap
//
//  Created by Wan Ahmad Lutfi on 12/15/15.
//  Copyright © 2015 bijokmind. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface KMVehicle : NSObject

@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *vehicleId;
@property (nonatomic, strong) NSString *vehicleDescription;
@property (nonatomic, strong) NSString *vehicleNumber;
@property (nonatomic, strong) NSString *imei;
@property (nonatomic, strong) NSString *mode;
@property (nonatomic, strong) KMVehicleLocation *current;
@property (nonatomic, strong) NSString *avatarURLPath;
@property (nonatomic, strong) NSString *markerURLPath;
@property (nonatomic, assign) float todayMaxSpeed;
@property (nonatomic, assign) float odometer;
@property (nonatomic, strong) NSDate *subscriptionEnd;
@property (nonatomic, assign) BOOL websocket;

@property (nonatomic, strong) KMAddress *currentAddress;
@property (nonatomic, strong) KMImage *carImage;
@property (nonatomic, strong) KMImage *carThumbImage;
@property (nonatomic, strong) KMImage *maskedCarImage;
//!Externally set
@property (nonatomic, strong) id beacon;
@property (nonatomic, assign) BOOL showAtActivityScreen;


- (void)carImageWithBlock:(void (^)(KMImage *image))completion;
- (void)carThumbImageWithBlock:(void (^)(KMImage *image))completion;

//!Get car image with size {40, 40} the image already masked round without border. It can save performace because the car image will have too be regenerated multiple times in different screens.
- (void)maskedCarImageWithBlock:(void (^)(KMImage *image))completion;

- (void)currentAddressWithBlock:(void (^)(KMAddress *address))completion;

- (NSString*)todayMaxSpeedString;

- (void)reloadDataWithVehicle:(KMVehicle*)vehicle;
- (void)reloadBlockImage;

- (NSDictionary*)jsonPatchDictionary;

@end
