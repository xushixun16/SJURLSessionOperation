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

@end
