//
//  KMUser.m
//  KatsanaMap
//
//  Created by Wan Ahmad Lutfi on 12/14/15.
//  Copyright © 2015 bijokmind. All rights reserved.
//

#import "KMUser.h"
#import "KMViolation.h"
//#import "NSDate+Compare.h"
#import "KMActivityObject.h"
#import <objc/runtime.h>
//#import <RestKit/RestKit.h>

@interface KMUser ()

@property (nonatomic, strong) dispatch_queue_t queue;
@property (nonatomic, strong) NSMutableArray *avatarImageBlocks;

@end

@implementation KMUser{
    NSDate *_firstUpdateActivitesDate;
    NSDate *_lastAddActivityDate;
    BOOL _loadingImage;
}

- (NSDictionary*)jsonPatchDictionary{
    NSMutableDictionary *dicto = @{}.mutableCopy;
    if (self.address.length > 0) dicto[@"address"] = self.address;
    if (self.phoneHome.length > 0) dicto[@"phone_home"] = self.phoneHome;
    if (self.fullname.length > 0) dicto[@"fullname"] = self.fullname;
    if (self.emergencyFullName.length > 0) dicto[@"meta.emergency.fullname"] = self.emergencyFullName;
    if (self.emergencyPhoneHome.length > 0) dicto[@"meta.emergency.phone.home"] = self.emergencyPhoneHome;
    if (self.emergencyPhoneMobile.length > 0) dicto[@"meta.emergency.phone.mobile"] = self.emergencyPhoneMobile;
    return dicto;
}

- (dispatch_queue_t)queue{
    if (!_queue) {
        _queue = dispatch_queue_create("activityLock", DISPATCH_QUEUE_SERIAL);
    }
    return _queue;
}


- (NSMutableArray*)avatarImageBlocks{
    if (!_avatarImageBlocks) {
        _avatarImageBlocks = [NSMutableArray array];
    }
    return _avatarImageBlocks;
}

- (void)avatarImageWithBlock:(void (^)(UIImage *image))completion{
    if (!self.avatarURLPath) {
        completion(nil);
    }
    
    if (!_avatarImage) {
        if (_loadingImage) {
            @synchronized (self.avatarImageBlocks) {
                [self.avatarImageBlocks addObject:completion];
            }
            return;
        }
        _loadingImage = YES;
        [[ImageRequest shared] requestImageWithPath:self.avatarURLPath completion:^(UIImage * image) {
            _avatarImage = image;
            _loadingImage = NO;
            for (ImageCompletionBlock block in self.avatarImageBlocks) {
                block(image);
            }
            completion(image);
        } failure:^(NSError * error) {
        }];
    }else{
        completion(self.avatarImage);
    }
}


#pragma mark -

- (void)addActivityObject:(KMActivityObject *)activity{
    __weak typeof(self) weakSelf = self;
    dispatch_async(self.queue, ^{
        NSMutableArray *activities = weakSelf.activities.mutableCopy;
        if (!activities) {
            activities = [NSMutableArray array];
        }
        if (![[activities.firstObject identifier] isEqualToString:activity.identifier]) {
            [activities addObject:activity];
        }
        
        NSSortDescriptor* sortOrder = [NSSortDescriptor sortDescriptorWithKey: @"self"
                                                                    ascending: NO];
        [activities sortUsingDescriptors:@[sortOrder]];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self updateActivities:activities.copy];
            _lastAddActivityDate = [NSDate date];
        });
    });
}

- (void)setActivitiesFilterPredicate:(NSPredicate *)activitiesFilterPredicate{
    if (_activitiesFilterPredicate != activitiesFilterPredicate) {
        _activitiesFilterPredicate = activitiesFilterPredicate;
        [self updateFilterActivities];
    }
}

- (void)updateActivities:(NSArray*)activities{
    if (!_firstUpdateActivitesDate) {
        _firstUpdateActivitesDate = [NSDate date];
    }
    [self willChangeValueForKey:@"activities"];
    _activities = activities;
    [self didChangeValueForKey:@"activities"];
    
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(updateFilterActivities) withObject:nil afterDelay:1];
}

- (void)updateFilterActivities{
    NSArray *activities = self.activities;
    activities = [activities filteredArrayUsingPredicate:self.activitiesFilterPredicate];
    [self willChangeValueForKey:@"filteredActivities"];
    _filteredActivities = activities;
    [self didChangeValueForKey:@"filteredActivities"];
    
    KMActivityObject *act = [[KMCacheManager sharedInstance] latestCachedActivityObject];
    if (!act) {
        [[KMCacheManager sharedInstance] cacheData:self.activities identifier:self.userId];
    }else{
        NSMutableArray *insertedActivities = [NSMutableArray array];
        for (KMActivityObject *activity in self.activities) {
            if ([activity.startTime timeIntervalSinceDate:act.startTime] > 0) {
                [insertedActivities addObject:activity];
            }else{
                break;
            }
        }
        if (insertedActivities.count > 0) {
            [[KMCacheManager sharedInstance] cacheData:insertedActivities identifier:self.userId];
        }
    }
}

- (NSArray*)activitiesSeparatedByDaysForActivities:(NSArray*)theActivities{
    NSMutableArray *group = [NSMutableArray array];
    NSMutableArray *currentDayGroup;
    
    NSArray *activities = [[theActivities sortedArrayUsingSelector:@selector(compare:)] reverseObjectEnumerator].allObjects;
    NSDate *currentDate;
    for (KMViolation *violation in activities) {
        if (!currentDate || ![[NSCalendar currentCalendar] isDate:currentDate inSameDayAsDate:violation.startTime]) {
            currentDate = violation.startTime;
            currentDayGroup = [NSMutableArray array];
            [group addObject:currentDayGroup];
        }
        [currentDayGroup addObject:violation];
    }
    return group;
}

#pragma mark - KVC

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    //Do nothing
}

- (id)valueForUndefinedKey:(NSString *)key{
    //To get rid error
    return nil;
}

#pragma mark - Update

- (void)updateUserUsingUser:(KMUser*)user
{
    NSArray *properties = [self allPropertyNames];
    for (NSString *property in properties) {
        [self setValue:[user valueForKeyPath:property] forKeyPath:property];
    }
}

- (NSArray *)allPropertyNames
{
    unsigned count;
    objc_property_t *properties = class_copyPropertyList([self class], &count);
    
    NSMutableArray *rv = [NSMutableArray array];
    
    unsigned i;
    for (i = 0; i < count; i++)
    {
        objc_property_t property = properties[i];
        NSString *name = [NSString stringWithUTF8String:property_getName(property)];
        [rv addObject:name];
    }
    
    free(properties);
    
    return rv;
}

- (BOOL)isLoadingActivities{
    if (_lastAddActivityDate && [[NSDate date] timeIntervalSinceDate:_lastAddActivityDate] < 3) {
        return YES;
    }
    return NO;
}

- (NSString*)description{
    return [NSString stringWithFormat:@"%@, email:%@, id:%@", [super description], self.email, self.userId];
}

@end
