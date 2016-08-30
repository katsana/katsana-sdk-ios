//
//  KMTrip.h
//  KatsanaMap
//
//  Created by Wan Ahmad Lutfi on 02/02/2016.
//  Copyright © 2016 bijokmind. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KMVehiclePosition.h"

@interface KMTrip : NSObject

@property (nonatomic, strong) KMVehiclePosition *start;
@property (nonatomic, strong) KMVehiclePosition *end;
@property (nonatomic, assign) CGFloat distance;
@property (nonatomic, assign) CGFloat duration;
@property (nonatomic, assign) CGFloat maxSpeed;
@property (nonatomic, assign) CGFloat averageSpeed;
@property (nonatomic, assign) CGFloat idleDuration;
@property (nonatomic, strong) NSArray *histories;
@property (nonatomic, strong) NSArray *violations;

@property (nonatomic, weak) KMTrip *nextTrip;
@property (nonatomic, weak) KMTrip *prevTrip;

- (CGFloat)medianSpeed;

- (CGFloat)tripStopDuration;
- (NSString*)tripStopDurationString;
- (NSString*)maxSpeedString;
- (NSString*)averageSpeedString;

@end
