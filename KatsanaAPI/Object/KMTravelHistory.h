//
//  KMVehicleHistory.h
//  KatsanaMap
//
//  Created by Wan Ahmad Lutfi on 12/30/15.
//  Copyright © 2015 bijokmind. All rights reserved.
//

#import <Foundation/Foundation.h>
@class KMVehicle;

@interface KMTravelHistory : NSObject

//@property (nonatomic, strong) NSDate *startDate;
//@property (nonatomic, strong) NSDate *endDate;
@property (nonatomic, weak) KMVehicle *owner;

@property (nonatomic, strong) NSArray <KMTrip*> *trips;
@property (nonatomic, assign) float maxSpeed;
@property (nonatomic, assign) double distance;
@property (nonatomic, assign) NSInteger violationCount;
@property (nonatomic, assign) double idleDuration;
@property (nonatomic, assign) double duration;

@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSDate *lastUpdate;

//!Trip count from trip history;
@property (nonatomic, assign) NSInteger tripCount;
//!Set if need to load history
@property (nonatomic, assign) BOOL needLoadTripHistory;



- (CGFloat)totalDuration;
- (CGFloat)averageSpeed;
//!Return local timezone history date
- (NSDate*)localTimezoneDate;

- (NSString*)idleDurationString;
- (NSString*)averageSpeedString;
- (NSString*)todayMaxSpeedString;
- (NSString*)totalDistanceString;
- (NSString*)totalDurationString;
- (NSAttributedString*)totalDurationAttributedString;

- (BOOL)dateEqualToVehicleDayHistory:(KMTravelHistory*)history;
- (BOOL)isEqual:(id)object;
//!Get trip contains given time
- (KMTrip*)tripAtTime:(NSDate*)time;


@end
