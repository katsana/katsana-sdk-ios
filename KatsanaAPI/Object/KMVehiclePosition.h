//
//  KMVehiclePosition.h
//  KatsanaMap
//
//  Created by Wan Ahmad Lutfi on 12/17/15.
//  Copyright © 2015 bijokmind. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KMVehiclePosition : NSObject

@property (nonatomic, assign) CGFloat altitude;
@property (nonatomic, assign) CGFloat course;
@property (nonatomic, assign) CGFloat latitude;
@property (nonatomic, assign) CGFloat longitude;
@property (nonatomic, assign) CGFloat speed;
@property (nonatomic, assign) CGFloat distance;
@property (nonatomic, assign) CGFloat fuelPercentage;

@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) NSString *voltage;
@property (nonatomic, strong) NSString *gsm;
@property (nonatomic, strong) NSString *ignitionState;

@property (nonatomic, strong) NSDate *trackedAt;
@property (nonatomic, strong) NSDate *updatedAt;
@property (nonatomic, strong) NSDate *createdAt;

- (NSString*)address;

- (NSDate*)localizedTrackedAt;
- (CLLocationCoordinate2D)coordinate;
- (void)addressWithCompletionBlock:(void (^)(NSString *address))completion;
-(void)addressWithCountry:(BOOL)useCountry completionBlock:(void (^)(NSString *address))completion;
- (NSString*)updatedDateString;
- (NSString*)speedString;

- (CGFloat)distanceToPosition:(KMVehiclePosition*)pos;
- (CGFloat)distanceToCoordinate:(CLLocationCoordinate2D)coord;
- (BOOL)locationEqualToVehiclePosition:(KMVehiclePosition*)otherPos;
- (BOOL)locationEqualToCoordinate:(CLLocationCoordinate2D)coord;

+ (KMVehiclePosition*)vehiclePositionFromDictionary:(NSDictionary*)dicto;

@end
