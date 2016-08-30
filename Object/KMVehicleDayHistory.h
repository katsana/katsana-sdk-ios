//
//  KMVehicleHistory.h
//  KatsanaMap
//
//  Created by Wan Ahmad Lutfi on 12/30/15.
//  Copyright © 2015 bijokmind. All rights reserved.
//

#import <Foundation/Foundation.h>
@class KMVehicle;

@interface KMVehicleDayHistory : NSObject

//@property (nonatomic, strong) NSDate *startDate;
//@property (nonatomic, strong) NSDate *endDate;
@property (nonatomic, weak) KMVehicle *owner;

@property (nonatomic, strong) NSArray *trips;
@property (nonatomic, assign) CGFloat maxSpeed;
@property (nonatomic, assign) CGFloat distance;
@property (nonatomic, assign) NSInteger violationCount;
@property (nonatomic, strong) NSDate *historyDate;
@property (nonatomic, assign) CGFloat idleDuration;
@property (nonatomic, assign) CGFloat duration;

//!Trip count from trip history;
@property (nonatomic, assign) NSInteger tripCount;
//!Set if need to load history
@property (nonatomic, assign) BOOL needLoadTripHistory;



- (CGFloat)totalDuration;
- (CGFloat)averageSpeed;
//!Return local timezone history date
- (NSDate*)localTimezoneHistoryDate;

- (NSString*)idleDurationString;
- (NSString*)averageSpeedString;
- (NSString*)todayMaxSpeedString;
- (NSString*)totalDistanceString;
- (NSString*)totalDurationString;
- (NSAttributedString*)totalDurationAttributedString;

- (BOOL)dateEqualToVehicleDayHistory:(KMVehicleDayHistory*)history;
- (BOOL)isEqual:(id)object;

#pragma mark - Custom type
//!Set if need indicator this object is custom type;
@property (nonatomic, assign) BOOL customType;
- (void)setupCustomTypeDetailFromDayHistories:(NSArray*)dayHistories;

@end
