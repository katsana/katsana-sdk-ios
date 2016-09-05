//
//  KMVehicle.m
//  KatsanaMap
//
//  Created by Wan Ahmad Lutfi on 12/15/15.
//  Copyright © 2015 bijokmind. All rights reserved.
//

#import "KMVehicle.h"
//#import "KMCarImageRasterView.h"

@interface KMVehicle ()

@property (nonatomic, strong) NSMutableArray *carImageBlocks;

@end

@implementation KMVehicle{
    CLLocationCoordinate2D _lastCoordinate;
    BOOL _loadingImage;
}

- (void)reloadDataWithVehicle:(KMVehicle*)vehicle{
    self.vehicleDescription = vehicle.description;
    self.mode = vehicle.mode;
    self.current = vehicle.current;
    self.currentPosition = vehicle.currentPosition;
    self.avatarURLPath = vehicle.avatarURLPath;
    self.marker = vehicle.marker;
    self.todayMaxSpeed = vehicle.todayMaxSpeed;
    self.speedLimit = vehicle.speedLimit;
    self.odometer = vehicle.odometer;
    self.subscriptionEnd = vehicle.subscriptionEnd;
    self.websocket = vehicle.websocket;
    self.currentAddress = vehicle.currentAddress;
    self.carImage = vehicle.carImage;
}

- (NSString*)todayMaxSpeedString{
    return [NSString stringWithFormat:@"%.0f km/h", self.todayMaxSpeed * KNOT_TO_KMH];
}

- (NSMutableArray*)carImageBlocks{
    if (!_carImageBlocks) {
        _carImageBlocks = [NSMutableArray array];
    }
    return _carImageBlocks;
}

- (void)carImageWithBlock:(void (^)(UIImage *image))completion{
    if (!_carImage) {
        if (_loadingImage) {
            @synchronized (self.carImageBlocks) {
                [self.carImageBlocks addObject:completion];
            }
            return;
        }
        
        UIImage *image = [[KMCacheManager sharedInstance] imageForIdentifier:self.avatarURLPath.lastPathComponent];
        if (image) {
            _carImage = image;
            completion (image);
        }else{
            _loadingImage = YES;
            NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] init] ;
            [urlRequest setURL:[NSURL URLWithString:self.avatarURLPath]];
            [urlRequest setHTTPMethod:@"GET"];
            AFRKImageRequestOperation *requestOperation = [[AFRKImageRequestOperation alloc] initWithRequest:urlRequest];
            [requestOperation setCompletionBlockWithSuccess:^(AFRKHTTPRequestOperation *operation, id responseObject) {
                completion(responseObject);
                [[KMCacheManager sharedInstance] cacheData:responseObject identifier:self.avatarURLPath.lastPathComponent];
                _carImage = responseObject;
//                _maskedCarImage = nil;
                _loadingImage = NO;
                
                for (ImageCompletionBlock block in self.carImageBlocks) {
                    block(responseObject);
                }
            } failure:^(AFRKHTTPRequestOperation *operation, NSError *error) {
                _loadingImage = NO;
            }];
            [requestOperation start];
        }
        
        
    }else{
        completion(self.carImage);
    }
}

//- (void)maskedCarImageWithBlock:(void (^)(UIImage *image))completion{
//    if (_maskedCarImage) {
//        completion (_maskedCarImage);
//        return;
//    }
//    
//    CGSize defaultSize = CGSizeMake(40, 40);
//    
//    [self carImageWithBlock:^(UIImage *image) {
//        KMCarImageRasterView *imageView = [[KMCarImageRasterView alloc] initWithFrame:CGRectMake(0, 0, defaultSize.width, defaultSize.height)];
//        imageView.carImageView.borderWidth = 0;
//        imageView.image = image;
//        _maskedCarImage = imageView.image;
//        completion(_maskedCarImage);
//    }];
//}

- (void)currentAddressWithBlock:(void (^)(KMAddress *address))completion{
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(self.current.latitude, self.current.longitude);
    if (self.currentAddress && coord.latitude == _lastCoordinate.latitude && coord.longitude == _lastCoordinate.longitude && coord.latitude != 0) {
        completion(self.currentAddress);
        return;
    }
    
    if (coord.latitude !=0 && coord.longitude != 0) {
        [[KMUserManager sharedManager] loadAddressWithLocation:coord address:^(KMAddress *address) {
            self.currentAddress = address;
            _lastCoordinate = self.current.coordinate;
            completion(address);
        } failure:^(NSError *error) {
        }];
    }
}

@end
