/*
The MIT License (MIT)

Copyright (c) 2015 Soneé Delano John https://twitter.com/Sonee_John

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

#import <Foundation/Foundation.h>
#import "AFNetworking/AFNetworking.h"
/**
 SJURLSessionOperation creates and manages an NSURLSessionDownloadTask object based on a specified request and download location. SJURLSessionOperation is a subclass of NSOperation which then can be used with a NSOperationQueue. In addition, it uses AFURLSessionManager so, it requires AFNetworking.
 
 */
NS_ASSUME_NONNULL_BEGIN
@interface SJURLSessionOperation : NSOperation
///---------------------------------------------------
/// @name Initializing an SJURLSessionOperation Object
///---------------------------------------------------

/**
 *  Initializes and returns a newly allocated operation object with a url request and a destination to save the file.
 *
 *  @param urlRequest  The HTTP request for the request.
 *  @param destination The destination to save the downloaded file upon completion. During the download, the file will be stored in a temporary loction, and upon completion it will be moved to the specified destination. In additonal, the temporay file used during the download will be automatically deleted after being moved to the specified destination.
 *
 *  @return An initialized `SJURLSessionOperation` object.
 */
- (nullable instancetype)initWithRequest:(NSURLRequest *)urlRequest targetLocation:(NSURL *)destination NS_DESIGNATED_INITIALIZER;

///------------------------------------
/// @name Pausing / Resuming Operations
///------------------------------------

/**
 * Pauses the execution of the operation.
 A paused operation returns `NO` for `-isReady`, `-isExecuting`, and `-isFinished`. As such, it will remain in an `NSOperationQueue` until it is either cancelled or resumed. Pausing a finished, cancelled, or paused operation has no effect.
 */
-(void)pause;
/**
 Whether the request operation is currently paused.
 
 @return `YES` if the operation is currently paused, otherwise `NO`.
 */
- (BOOL)isPaused;
/**
 *  Resumes the execution of the paused operation.
    Resuming a operation that is not paused has no effect.
 */
-(void)resume;

///---------------------------------
/// @name Setting Callbacks
///---------------------------------

/**
 *   Sets a callback to be called when an undetermined number of bytes have been downloaded from the server.
 *
 *  @param block A block object to be called when an undetermined number of bytes have been downloaded from the server. This block has no return value and takes three arguments: the number of bytes read since the last time the download progress block was called, the total bytes read, and the total bytes expected to be read during the request, as initially determined by the expected content size of the `NSHTTPURLResponse` object. This block may be called multiple times, and will execute on the main queue.
 */
- (void)setDownloadProgressBlock:(nullable void (^)(int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite))block;

/**
 *  Sets a callback to be called when operation finishes.
 *
 *  @param block A block to be executed when a task finishes. This block has no return value and takes four arguments: the operation, the error describing the network or parsing error that occurred, if any, the path of the downloaded file, and the server response.
 */
- (void)setDownloadCompletionBlock:(nullable void (^)(SJURLSessionOperation *_Nullable operation, NSError *_Nullable error, NSURL *_Nullable fileURL, NSURLResponse *_Nullable response))block;

///-----------------------------------------
/// @name Getting Information
///-----------------------------------------

/**
 The error, if any, that occurred in the lifecycle of the operation.
 */
@property (readonly, nonatomic, strong, nullable) NSError *error;
/**
 *  The resume data for the operation. This value may be `nil`.
 */
@property (strong, nonatomic) NSData *resumeData;

///--------------------
/// @name Notifications
///--------------------

/**
 Posted when an operation begins executing.
 */
extern NSString * const SJURLSessionOperationDidStartNotification;

/**
 Posted when an operation finishes.
 */
extern NSString * const SJURLSessionOperationDidFinishNotification;

@end
NS_ASSUME_NONNULL_END