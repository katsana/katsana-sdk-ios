//
//  KMTrip.h
//  KatsanaMap
//
//  Created by Wan Ahmad Lutfi on 02/02/2016.
//  Copyright © 2016 bijokmind. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KMTrip : NSObject

@property (nonatomic, strong) KMVehiclePosition *start;
@property (nonatomic, strong) KMVehiclePosition *end;
@property (nonatomic, assign) double distance;
@property (nonatomic, assign) double duration;
@property (nonatomic, assign) float maxSpeed;
@property (nonatomic, assign) float averageSpeed;
@property (nonatomic, assign) double idleDuration;

@property (nonatomic, strong) NSArray *histories;
@property (nonatomic, strong) NSArray *violations;
@property (nonatomic, strong) NSArray *idles;

@property (nonatomic, weak) KMTrip *nextTrip;
@property (nonatomic, weak) KMTrip *prevTrip;

- (CGFloat)medianSpeed;

- (CGFloat)tripStopDuration;
- (NSString*)tripStopDurationString;
- (NSString*)maxSpeedString;
- (NSString*)averageSpeedString;

@end
