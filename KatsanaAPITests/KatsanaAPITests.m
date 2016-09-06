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

@end

@implementation KatsanaAPITests

- (void)setUp {
    [super setUp];
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

- (void)testLogin {
    [[KMUserManager sharedInstance] loginWithUserName:@"" password:@"" user:^(KMUser *user) {
        NSLog(@"%@", user);
    } failure:^(NSError *error) {
       
    }];
    [self XCA_waitForTimeout:5];
}

@end
