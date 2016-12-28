//
//  KMVehicleLocation.h
//  KatsanaMap
//
//  Created by Wan Ahmad Lutfi on 12/17/15.
//  Copyright © 2015 bijokmind. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreLocation;

@interface KMVehicleLocation : NSObject


@property (nonatomic, assign) double latitude;
@property (nonatomic, assign) double longitude;
@property (nonatomic, assign) float speed;

@property (nonatomic, assign) double altitude;
@property (nonatomic, assign) double course;
@property (nonatomic, assign) float distance;
//@property (nonatomic, assign) float fuelPercentage;

///Accuracy of the location, if unavailable will always return 0
@property (nonatomic, assign) float verticalAccuracy;
@property (nonatomic, assign) float horizontalAccuracy;

@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) NSString *voltage;
@property (nonatomic, strong) NSString *gsm;
@property (nonatomic, assign) BOOL ignitionState;

@property (nonatomic, strong) NSDate *trackedAt;
@property (nonatomic, strong) NSDate *updatedAt;
@property (nonatomic, strong) NSDate *createdAt;

- (NSString*)address;

- (CGFloat)localizedSpeed;
- (NSDate*)localizedTrackedAt;
- (CLLocationCoordinate2D)coordinate;
- (void)addressWithCompletionBlock:(void (^)(NSString *address))completion;
-(void)addressWithCountry:(BOOL)useCountry completionBlock:(void (^)(NSString *address))completion;
- (NSString*)updatedDateString;
- (NSString*)speedString;

- (CGFloat)distanceToPosition:(KMVehicleLocation*)pos;
- (CGFloat)distanceToCoordinate:(CLLocationCoordinate2D)coord;
- (BOOL)locationEqualToVehiclePosition:(KMVehicleLocation*)otherPos;
- (BOOL)locationEqualToCoordinate:(CLLocationCoordinate2D)coord;

+ (KMVehicleLocation*)vehiclePositionFromDictionary:(NSDictionary*)dicto;

@end
