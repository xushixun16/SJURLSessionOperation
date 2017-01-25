/*
 The MIT License (MIT)
 
 Copyright (c) 2015 - 2016 Soneé Delano John https://twitter.com/Sonee_John
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

#import "SJURLSessionOperation.h"

static inline NSString * SJKeyPathFromOperationState(SJURLSessionOperationState state) {
    switch (state) {
        case SJURLSessionOperationReadyState:
            return @"isReady";
        case SJURLSessionOperationExecutingState:
            return @"isExecuting";
        case SJURLSessionOperationFinishedState:
            return @"isFinished";
        case SJURLSessionOperationPausedState:
            return @"isPaused";
        default: {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunreachable-code"
            return @"state";
#pragma clang diagnostic pop
        }
    }
}

static inline BOOL SJStateTransitionIsValid(SJURLSessionOperationState fromState, SJURLSessionOperationState toState, BOOL isCancelled) {
    switch (fromState) {
        case SJURLSessionOperationReadyState:
            switch (toState) {
                case SJURLSessionOperationPausedState:
                case SJURLSessionOperationExecutingState:
                    return YES;
                case SJURLSessionOperationFinishedState:
                    return isCancelled;
                default:
                    return NO;
            }
        case SJURLSessionOperationExecutingState:
            switch (toState) {
                case SJURLSessionOperationPausedState:
                case SJURLSessionOperationFinishedState:
                    return YES;
                default:
                    return NO;
            }
        case SJURLSessionOperationFinishedState:
            return NO;
        case SJURLSessionOperationPausedState:
            return toState == SJURLSessionOperationReadyState;
        default: {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunreachable-code"
            switch (toState) {
                case SJURLSessionOperationPausedState:
                case SJURLSessionOperationReadyState:
                case SJURLSessionOperationExecutingState:
                case SJURLSessionOperationFinishedState:
                    return YES;
                default:
                    return NO;
            }
        }
#pragma clang diagnostic pop
    }
}

typedef void (^SJURLSessionOperationProgressBlock)(int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite);
typedef void (^SJURLSessionOperationCompletionBlock)(SJURLSessionOperation *operation, NSError *error, NSURL *fileURL, NSURLResponse *response);

NSString * const SJURLSessionOperationDidStartNotification = @"com.alphasoft.sjurlsession.operation.start";
NSString * const SJURLSessionOperationDidFinishNotification = @"com.alphasoft.sjurlsession.operation.finish";
static NSString * const SJURLSessionOperationLockName = @"com.alphasoft.sjurlsession.operation.lock";

@interface SJURLSessionOperation () <NSURLSessionDownloadDelegate>

@property (readwrite, nonatomic, strong) NSURLSessionDownloadTask *downloadTask;
@property (readwrite, nonatomic, strong) NSError *error;
@property (readwrite, nonatomic, strong) NSURLSession *session;
@property (readwrite, nonatomic, strong) NSURLRequest *request;
@property (readwrite, nonatomic, strong) NSURL *saveLocation;
@property (readwrite, nonatomic, strong) NSRecursiveLock *lock;
@property (readwrite, nonatomic, copy) SJURLSessionOperationProgressBlock downloadProgress;
@property (readwrite, nonatomic, copy) SJURLSessionOperationCompletionBlock completion;

@end

@implementation SJURLSessionOperation

#pragma mark - Object life cycle

- (instancetype)initWithRequest:(NSURLRequest *)urlRequest targetLocation:(NSURL *)destination resumeData:(NSData *)operationResumeData {
    
    NSParameterAssert(urlRequest);
    NSParameterAssert(destination);
    
    self = [super init];
    
    if (self) {
        
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
        _downloadTask = [_session downloadTaskWithRequest:urlRequest];
        _state = SJURLSessionOperationReadyState;
        _saveLocation = destination;
        _request = urlRequest;
        _urlRequest = urlRequest;
        _destinationURL = destination;
        _operationResumeData = operationResumeData;
        
        _lock = [[NSRecursiveLock alloc]init];
        _lock.name = SJURLSessionOperationLockName;
    }
    
    return self;
}

- (instancetype)initWithRequest:(NSURLRequest *)urlRequest targetLocation:(NSURL *)destination {
    
    return [self initWithRequest:urlRequest targetLocation:destination resumeData:nil];
}

#pragma mark - NSURLSessionDownloadDelegate

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    
    NSError *error = nil;
    
    if (![[NSFileManager defaultManager]copyItemAtURL:location toURL:self.destinationURL error:&error]) {
        
        if (error) {
            
            [self finishWithError:error resumeData:downloadTask.error.userInfo[NSURLSessionDownloadTaskResumeData]];
            
            if (self.completion) {
                self.completion(self, error, nil, downloadTask.response);
            }
        }
        return;
    }
    
    [self finish];
    
    if (self.completion) {
        self.completion(self, error, self.destinationURL, downloadTask.response);
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    
    [self finishWithError:error resumeData:task.error.userInfo[NSURLSessionDownloadTaskResumeData]];
    
    if (self.completion) {
        self.completion(self, error, nil, task.response);
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {

    if (self.downloadProgress) {
        self.downloadProgress(bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
    }
}

#pragma mark -

- (void)setDownloadProgressBlock:(void (^)(int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite))block {
    
    self.downloadProgress = block;
}
- (void)setDownloadCompletionBlock:(void (^)(SJURLSessionOperation *, NSError *, NSURL *, NSURLResponse *))block {
    
    self.completion = block;
}

#pragma mark -

- (void)setState:(SJURLSessionOperationState)state {
    if (!SJStateTransitionIsValid(self.state, state, [self isCancelled])) {
        return;
    }
    
    [self.lock lock];
    NSString *oldStateKey = SJKeyPathFromOperationState(self.state);
    NSString *newStateKey = SJKeyPathFromOperationState(state);
    
    [self willChangeValueForKey:newStateKey];
    [self willChangeValueForKey:oldStateKey];
    _state = state;
    [self didChangeValueForKey:oldStateKey];
    [self didChangeValueForKey:newStateKey];
    [self.lock unlock];
}

#pragma mark - NSOperation & Operation Control

- (void)resume {
    
    if (![self isPaused]) {
        return;
    }
    
    if (self.downloadTask) {
        [self.lock lock];
        self.state = SJURLSessionOperationReadyState;
        [self.lock unlock];
        [self start];
    }
}

- (void)pause {
    
    if ([self isPaused] || [self isFinished] || [self isCancelled]) {
        return;
    }
    
    [self.lock lock];
    
    if ([self isExecuting]) {
        
        if(self.downloadTask){
            
            [self.downloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
                _operationResumeData = resumeData;
            }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
            [notificationCenter postNotificationName:SJURLSessionOperationDidFinishNotification object:self];
        });
    
        }
    }

    self.state = SJURLSessionOperationPausedState;
    [self.lock unlock];
}

- (void)cancel {
    
    [self.lock lock];
    if (![self isFinished] && ![self isCancelled]) {
        [super cancel];
        
        if ([self isExecuting]) {
            
            [self.downloadTask cancel];
            [self finish];
        }
    }
    [self.lock unlock];
}

- (void)start {
    
    [self.lock lock];
    if ([self isCancelled]) {
        [self finish];
        return;
        
    } else if ([self isReady]) {
        self.state = SJURLSessionOperationExecutingState;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:SJURLSessionOperationDidStartNotification object:self];
        });
        
        if (self.operationResumeData) {
            self.downloadTask = [self.session downloadTaskWithResumeData:self.operationResumeData];
        }
        
        [self.downloadTask resume];
    }
    
    [self.lock unlock];
}

- (void)finishWithError:(NSError *)error resumeData:(NSData *)resumeData {
    
    self.error = error;
    _operationResumeData = resumeData;
    [self finish];
}

- (void)finish {
    
    [self.lock lock];
    self.state = SJURLSessionOperationFinishedState;
    [self.lock unlock];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:SJURLSessionOperationDidFinishNotification object:self];
    });
}

- (BOOL)isPaused {
    return self.state == SJURLSessionOperationPausedState;
}

- (BOOL)isReady {
    return self.state == SJURLSessionOperationReadyState && [super isReady];
}

- (BOOL)isExecuting {
    return self.state == SJURLSessionOperationExecutingState;
}

- (BOOL)isFinished {
    return self.state == SJURLSessionOperationFinishedState
    ;
}

- (BOOL)isConcurrent {
    return YES;
}

@end
