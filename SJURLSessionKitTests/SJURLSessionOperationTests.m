//
//  SJURLSessionOperationTests.m
//  SJURLSessionKit
//
//  Created by Soneé John on 1/24/17.
//  Copyright © 2017 AlphaSoft. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <SJURLSessionKit/SJURLSessionKit.h>

@interface SJURLSessionOperationTests : XCTestCase

@end

NSString * const SJURLSessionOperationTestsDownloadURL = @"https://dl.dropboxusercontent.com/u/417623669/Apple%20%E2%80%93%20Introducing%20AirPods.mp4";
@implementation SJURLSessionOperationTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

#pragma mark - Initialization Tests

- (void)testThatItInitializes {
    
    //Given these parms
    
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.example.com/bigfile.zip"]];
    
    NSURL *targetLocation = [NSURL fileURLWithPath:[@"~/Desktop/bigfile.zip" stringByExpandingTildeInPath]];
    NSData *resumeData = [NSData data];
    
    //Then
    SJURLSessionOperation *operation = [[SJURLSessionOperation alloc]initWithRequest:urlRequest targetLocation:targetLocation resumeData:resumeData];
    
    SJURLSessionOperation *operation2 = [[SJURLSessionOperation alloc]initWithRequest:urlRequest targetLocation:targetLocation];
    
    //Eval operation
    
    XCTAssertNotNil(operation, @"Operation should not be `nil` please check implementation!");
    
    XCTAssertEqualObjects(urlRequest, operation.urlRequest, @"`urlRequest` was not assigned. Please check implementation!");
    XCTAssertEqualObjects(targetLocation, operation.destinationURL, @"`destinationURL` was not assigned. Please check implementation!");
    XCTAssertEqualObjects(resumeData, operation.operationResumeData, @"`operationResumeData` was not assigned. Please check implementation!");
    
    // Eval operation2
    XCTAssertNotNil(operation2, @"Operation should not be `nil` please check implementation!");
    
    XCTAssertEqualObjects(urlRequest, operation2.urlRequest, @"`urlRequest` was not assigned. Please check implementation!");
    XCTAssertEqualObjects(targetLocation, operation2.destinationURL, @"`destinationURL` was not assigned. Please check implementation!");    
}

- (void)testThatItDoesNotInitialize_nil_urlRequest {
    
    //Given these parms

    NSURLRequest *urlRequest = nil;
    
    NSURL *targetLocation = [NSURL fileURLWithPath:[@"~/Desktop/bigfile.zip" stringByExpandingTildeInPath]];
    NSData *resumeData = [NSData data];
    
    //Eval
    XCTAssertThrows([[SJURLSessionOperation alloc]initWithRequest:urlRequest targetLocation:targetLocation resumeData:resumeData], @"Operation should throw an exception when `urlRequest` is nil");
}

- (void)testThatItDoesNotInitialize_nil_destinationURL {
    
    //Given these parms
    
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.example.com/bigfile.zip"]];
    
    NSURL *targetLocation = nil;
    NSData *resumeData = [NSData data];
    
    //Eval
    XCTAssertThrows([[SJURLSessionOperation alloc]initWithRequest:urlRequest targetLocation:targetLocation resumeData:resumeData], @"Operation should throw an exception when `destinationURL` is nil");
}

- (void)testThatItInitializes_nil_operationResumeData {

    //Given these parms
    
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.example.com/bigfile.zip"]];
    
    NSURL *targetLocation = [NSURL fileURLWithPath:[@"~/Desktop/bigfile.zip" stringByExpandingTildeInPath]];
    NSData *resumeData = [NSData data];
    
    //Eval
    
    XCTAssertNoThrow([[SJURLSessionOperation alloc]initWithRequest:urlRequest targetLocation:targetLocation resumeData:resumeData], @"Operation should not throw an execption when `operationResumeData` is nil.");
}

#pragma mark - Download

- (void)testThatItDownloadsSuccessfully {
    
    __block XCTestExpectation *expectation = [self expectationWithDescription:@""];
    
    //Given these parms
    
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:SJURLSessionOperationTestsDownloadURL]];
    NSURL *targetLocation = [NSURL fileURLWithPath:[[NSTemporaryDirectory() stringByAppendingPathComponent:[NSProcessInfo processInfo].globallyUniqueString] stringByAppendingPathExtension:SJURLSessionOperationTestsDownloadURL.pathExtension]];
    
    SJURLSessionOperation *operation = [[SJURLSessionOperation alloc]initWithRequest:urlRequest targetLocation:targetLocation];
    
    [operation setDownloadCompletionBlock:^(SJURLSessionOperation * _Nullable operation, NSError * _Nullable error, NSURL * _Nullable fileURL, NSURLResponse * _Nullable response) {
        
        XCTAssertNotNil(operation);
        XCTAssertNil(error);
        XCTAssertNil(operation.error);
        XCTAssertNotNil(fileURL);
        XCTAssertNotNil(operation.destinationURL);
        XCTAssertEqualObjects(targetLocation, fileURL);
        XCTAssertEqualObjects(targetLocation, operation.destinationURL);
        XCTAssertTrue([[NSFileManager defaultManager]fileExistsAtPath:fileURL.path]);
        XCTAssertTrue([[NSFileManager defaultManager]fileExistsAtPath:operation.destinationURL.path]);
        XCTAssertNotNil(response);
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            [[NSFileManager defaultManager]removeItemAtURL:targetLocation error:nil];
            [expectation fulfill];
        });
      
    }];
    
    [operation start];
    
    [self waitForExpectationsWithTimeout:500 handler:nil];
}

#pragma mark - Operation Control

- (void)testThatItResumesFromPausedState {
    
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:SJURLSessionOperationTestsDownloadURL]];
    NSURL *targetLocation = [NSURL fileURLWithPath:[[NSTemporaryDirectory() stringByAppendingPathComponent:[NSProcessInfo processInfo].globallyUniqueString] stringByAppendingPathExtension:SJURLSessionOperationTestsDownloadURL.pathExtension]];
    
    SJURLSessionOperation *operation = [[SJURLSessionOperation alloc]initWithRequest:urlRequest targetLocation:targetLocation];
    
    [operation start];
    
    sleep(5);
    
    [operation pause];
    
    sleep(5);
    
    [operation resume];
    
    XCTAssertTrue(operation.isExecuting);
    XCTAssertTrue(operation.state == SJURLSessionOperationExecutingState);
}

- (void)testThatItDoesNotResumeFromNonPausedState {
    
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:SJURLSessionOperationTestsDownloadURL]];
    NSURL *targetLocation = [NSURL fileURLWithPath:[[NSTemporaryDirectory() stringByAppendingPathComponent:[NSProcessInfo processInfo].globallyUniqueString] stringByAppendingPathExtension:SJURLSessionOperationTestsDownloadURL.pathExtension]];
    
    SJURLSessionOperation *operation = [[SJURLSessionOperation alloc]initWithRequest:urlRequest targetLocation:targetLocation];
    
    [operation start];
    
    sleep(5);
    
    [operation resume];
    
    XCTAssertTrue(operation.isExecuting);
    XCTAssertTrue(operation.state == SJURLSessionOperationExecutingState);
}

- (void)testThatItPausesFromExecutingState {
    
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:SJURLSessionOperationTestsDownloadURL]];
    NSURL *targetLocation = [NSURL fileURLWithPath:[[NSTemporaryDirectory() stringByAppendingPathComponent:[NSProcessInfo processInfo].globallyUniqueString] stringByAppendingPathExtension:SJURLSessionOperationTestsDownloadURL.pathExtension]];
    
    SJURLSessionOperation *operation = [[SJURLSessionOperation alloc]initWithRequest:urlRequest targetLocation:targetLocation];
    
    [operation start];
    
    sleep(5);
    
    [operation pause];
    
    XCTAssertTrue(operation.isPaused);
}

- (void)testThatItDoesNotPauseFromFinishedState {
    
    __block XCTestExpectation *expectation = [self expectationWithDescription:@""];
    
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:SJURLSessionOperationTestsDownloadURL]];
    NSURL *targetLocation = [NSURL fileURLWithPath:[[NSTemporaryDirectory() stringByAppendingPathComponent:[NSProcessInfo processInfo].globallyUniqueString] stringByAppendingPathExtension:SJURLSessionOperationTestsDownloadURL.pathExtension]];
    
    SJURLSessionOperation *operation = [[SJURLSessionOperation alloc]initWithRequest:urlRequest targetLocation:targetLocation];
    
     [operation setDownloadCompletionBlock:^(SJURLSessionOperation * _Nullable operation, NSError * _Nullable error, NSURL * _Nullable fileURL, NSURLResponse * _Nullable response) {
         
         
         XCTAssertNil(error);
         [operation pause];
         XCTAssertFalse(operation.isPaused);
         static dispatch_once_t onceToken;
         dispatch_once(&onceToken, ^{
             [expectation fulfill];
         });
     }];
    
    [operation start];
    
    [self waitForExpectationsWithTimeout:500 handler:nil];
}

- (void)testThatItReturnsCustomDescription {
    
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:SJURLSessionOperationTestsDownloadURL]];
    NSURL *targetLocation = [NSURL fileURLWithPath:[[NSTemporaryDirectory() stringByAppendingPathComponent:[NSProcessInfo processInfo].globallyUniqueString] stringByAppendingPathExtension:SJURLSessionOperationTestsDownloadURL.pathExtension]];
    
    SJURLSessionOperation *operation = [[SJURLSessionOperation alloc]initWithRequest:urlRequest targetLocation:targetLocation];
    
    NSString *testString = [NSString stringWithFormat:@"< %@: %p | Destination URL: %@>",[operation className], operation, operation.destinationURL];
    XCTAssertNotNil(operation.description);
    XCTAssertEqualObjects(operation.description, testString);
}

- (void)testThatItReturnsDebugDescription {
    
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:SJURLSessionOperationTestsDownloadURL]];
    NSURL *targetLocation = [NSURL fileURLWithPath:[[NSTemporaryDirectory() stringByAppendingPathComponent:[NSProcessInfo processInfo].globallyUniqueString] stringByAppendingPathExtension:SJURLSessionOperationTestsDownloadURL.pathExtension]];
    
    SJURLSessionOperation *operation = [[SJURLSessionOperation alloc]initWithRequest:urlRequest targetLocation:targetLocation];
    
    NSString *testString = [NSString stringWithFormat:@"%@ | State: SJURLSessionOperationReadyState", operation.description];
    XCTAssertNotNil(operation.debugDescription);
    XCTAssertEqualObjects(operation.debugDescription, testString);
}


@end
