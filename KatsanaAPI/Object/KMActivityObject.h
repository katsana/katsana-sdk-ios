//
//  KMActivityObject.h
//  Katsana
//
//  Created by Wan Ahmad Lutfi on 17/06/2016.
//  Copyright © 2016 bijokmind. All rights reserved.
//

@interface KMActivityObject : KMViolation

@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, assign) CGFloat altitude;
@property (nonatomic, assign) CGFloat course;
@property (nonatomic, assign) CGFloat speed;
@property (nonatomic, strong) NSAttributedString *attributedMessage;

@property (nonatomic, strong) NSString *serverTimeText;

- (NSString*)alertDescription;
+ (NSArray*)violationsFromDictionary:(NSDictionary*)dicto;
+ (KMActivityObject*)activityObjectFromDictionary:(NSDictionary*)obj identifier:(NSString*)identifier;

- (NSString*)dateString;

+ (NSDateFormatter*)sharedDateFormatter3;
- (CGFloat)localizedSpeed;

@end
