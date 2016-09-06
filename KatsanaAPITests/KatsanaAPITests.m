//
//  KatsanaAPITests.m
//  KatsanaAPITests
//
//  Created by Wan Ahmad Lutfi on 29/08/2016.
//  Copyright © 2016 pixelated. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <KatsanaSDK/KatsanaSDK.h>
#import "XCTestCase+AsyncTesting.h"

@interface KatsanaAPITests : XCTestCase

@property (nonatomic, strong) NSString *token;
@property (nonatomic, strong) KMUser *user;
@property (nonatomic, strong) NSArray *vehicles;
@property (nonatomic, strong) NSArray *vehicle;

@end

@implementation KatsanaAPITests

- (void)setUp {
    [super setUp];
    if (!self.user) {
        NSString *path = @"/Users/Lutfi/testCredential.plist"; //Path to credential
        NSDictionary *dicto = [NSDictionary dictionaryWithContentsOfFile:path];
        
        NSString *email = dicto[@"username"];
        NSString *pass = dicto[@"password"];
        NSString *baseURL = dicto[@"baseURL"];
        if (baseURL) {
            [KMKatsana resetBaseURL:[NSURL URLWithString:baseURL]];
        }
        
        
        [[KMKatsana sharedInstance] loginWithUserName:email password:pass user:^(KMUser *user) {
            self.token = [KMKatsana sharedInstance].token;
            self.user = user;
            NSLog(@"%@", user);
            [self XCA_notify:XCTAsyncTestCaseStatusSucceeded];
        } failure:^(NSError *error) {
            [self XCA_notify:XCTAsyncTestCaseStatusFailed];
        }];
        [self XCA_waitForTimeout:5];
    }

    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

- (void)testLoadVehicles {
    [[KMKatsana sharedInstance] loadVehicles:^(NSArray *vehicles) {
        NSLog(@"%@", vehicles);
        [self XCA_notify:XCTAsyncTestCaseStatusSucceeded];
    } failure:^(NSError *error) {
        
        [self XCA_notify:XCTAsyncTestCaseStatusFailed];
    }];
    [self XCA_waitForTimeout:5];
}

- (void)testLoadVehicle{
    [[KMKatsana sharedInstance] loadVehicleWithId:@"34" vehicle:^(KMVehicle *vehicle) {
        NSLog(@"%@", vehicle);
        [self XCA_notify:XCTAsyncTestCaseStatusSucceeded];
    } failure:^(NSError *error) {
        [self XCA_notify:XCTAsyncTestCaseStatusFailed];
    }];
    [self XCA_waitForTimeout:5];
}

- (void)tests{
    [[KMKatsana sharedInstance] loadVehicleHistoryWithId:@"34" date:[NSDate date] vehicle:^(KMVehicleDayHistory *dayHistory) {
        NSLog(@"%@", dayHistory);
        [self XCA_notify:XCTAsyncTestCaseStatusSucceeded];
    } failure:^(NSError *error) {
        [self XCA_notify:XCTAsyncTestCaseStatusFailed];
    }];
    [self XCA_waitForTimeout:5];
}



@end
