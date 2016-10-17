//
//  KMUser.h
//  KatsanaMap
//
//  Created by Wan Ahmad Lutfi on 12/14/15.
//  Copyright © 2015 bijokmind. All rights reserved.
//

#import <Foundation/Foundation.h>
@class KMActivityObject;


@interface KMUser : NSObject

@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *phoneHome;
@property (nonatomic, strong) NSString *phoneMobile;
@property (nonatomic, strong) NSString *identification;
@property (nonatomic, strong) NSString *fullname;
@property (nonatomic, assign) NSInteger status;

@property (nonatomic, strong) NSString *quickbooksId;
@property (nonatomic, strong) NSString *braintreeId;
@property (nonatomic, strong) NSString *paypalEmail;
@property (nonatomic, strong) NSString *cardToken;
@property (nonatomic, strong) NSString *cardrand;
@property (nonatomic, strong) NSString *cardLastFour;

@property (nonatomic, strong) NSString *emergencyFullName;
@property (nonatomic, strong) NSString *emergencyPhoneHome;
@property (nonatomic, strong) NSString *emergencyPhoneMobile;

@property (nonatomic, strong) NSDate *createdAt;
@property (nonatomic, strong) NSDate *updatedAt;
@property (nonatomic, strong) NSString *subscriptionDateString;

@property (nonatomic, strong) NSString *avatarURLPath;
@property (nonatomic, strong) UIImage *avatarImage;

//@property (nonatomic, strong) NSString *meta;

@property (atomic, strong) NSArray *activities;
@property (atomic, readonly) NSArray *filteredActivities;
//!Predicate to filter activities
@property (nonatomic, strong) NSPredicate *activitiesFilterPredicate;

- (void)addActivityObject:(KMActivityObject*)activity;
- (NSArray*)activitiesSeparatedByDaysForActivities:(NSArray*)theActivities;

//!Update user with latest data loaded. For example after load profile API
- (void)updateUserUsingUser:(KMUser*)user;
- (void)updateFilterActivities;

//!Return YES if firebase still loading activities. Indicator that activity is still loading, useful when app first opened but have many backlogs data
- (BOOL)isLoadingActivities;
- (void)avatarImageWithBlock:(void (^)(UIImage *image))completion;

- (NSDictionary*)jsonPatchDictionary;

@end
