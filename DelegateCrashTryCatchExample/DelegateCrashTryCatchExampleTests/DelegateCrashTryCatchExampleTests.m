//
//  DelegateCrashTryCatchExampleTests.m
//  DelegateCrashTryCatchExampleTests
//
//  Created by 성기평 on 2015. 6. 29..
//  Copyright (c) 2015년 hothead. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

@interface DelegateCrashTryCatchExampleTests : XCTestCase

@end

@implementation DelegateCrashTryCatchExampleTests

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
    XCTAssert(YES, @"Pass");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
