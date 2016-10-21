//
//  KMViolation.h
//  KatsanaMap
//
//  Created by Wan Ahmad Lutfi on 07/01/2016.
//  Copyright © 2016 bijokmind. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreLocation;

typedef NS_ENUM(NSInteger, KMViolationPolicyTypeId) {
    KMViolationPolicyTypeNone = 0,
    KMViolationPolicyTypeMovement,
    KMViolationPolicyTypeTime,
    KMViolationPolicyTypeSpeed,
    KMViolationPolicyTypeArea,
    KMViolationPolicyTypeBatteryCutoff,
    KMViolationPolicyTypeRefuel,
    KMViolationPolicyTypeSiphoning,
    KMViolationPolicyCheckpoint,
    
    KMViolationPolicyTypeHarshBrake,
    KMViolationPolicyTypeHarshAccelerate,
    KMViolationPolicyTypeHarshCorner,
    
    KMViolationPolicyTypeSpeedSummary,
    KMViolationPolicyTypeLockdown
};

@interface KMViolation : NSObject

//!Owner
@property (nonatomic, weak) KMVehicle *vehicle;

@property (nonatomic, strong) NSString *deviceId;
@property (nonatomic, strong) NSString *policyType;
@property (nonatomic, assign) KMViolationPolicyTypeId policyTypeId;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSString *address;

@property (nonatomic, assign) CGFloat distance;
@property (nonatomic, assign) CGFloat duration;
@property (nonatomic, assign) CGFloat latitude;
@property (nonatomic, assign) CGFloat longitude;
@property (nonatomic, strong) NSDate *startTime;
@property (nonatomic, strong) NSDate *endTime;
@property (nonatomic, assign) NSInteger startPosition;
@property (nonatomic, assign) NSInteger endPosition;

@property (nonatomic, assign) NSInteger violationId;
@property (nonatomic, assign) NSInteger policyId;


@property (nonatomic, assign) CGFloat maxSpeed;
@property (nonatomic, assign) CGFloat averageSpeed;

- (NSString*)violationType;
+ (NSArray*)violationTypes;
- (CLLocationCoordinate2D)coordinate;
- (NSString*)violationInfo;
- (NSString*)policyAlertString;
- (CGFloat)localizedMaxSpeed;

- (void)addressWithCompletionBlock:(void (^)(NSString *address))completion;


@end
