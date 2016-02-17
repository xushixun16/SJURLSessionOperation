//
//  ViewController.m
//  SJURLSessionOperation Demo
//
//  Created by Soneé John on 2/16/16.
//  Copyright © 2016 AlphaSoft. All rights reserved.
//

#import "ViewController.h"
#import "SJURLSessionOperation.h"

@interface ViewController ()

@property (nonatomic, strong) SJURLSessionOperation *operation;
@property (nonatomic, strong) NSByteCountFormatter *byteFormatter;

@end
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    self.byteFormatter = [[NSByteCountFormatter alloc]init];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (IBAction)operationControlAction:(id)sender {
    
    if ([self.downloadButton.title isEqualToString:@"Download"]) {
        
        NSURL *downloadURL = [NSURL URLWithString:self.urlTextField.stringValue];
        NSSavePanel *savePanel = [[NSSavePanel alloc]init];
        [savePanel setNameFieldStringValue:[NSString stringWithFormat:@"File Name.%@",downloadURL.pathExtension]];
        [savePanel setPrompt:@"Download"];
        
        NSInteger result = [savePanel runModal];
        
        if (result == NSFileHandlingPanelOKButton) {
         
            //Setup download operation
            self.operation = [[SJURLSessionOperation alloc]initWithRequest:[NSURLRequest requestWithURL:downloadURL] targetLocation:savePanel.URL];
            
            //Set blocks
            [self registerCompletionBlockForOperation:self.operation];
            [self registerProgressBlockForOperation:self.operation];
            
            [self.operation addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial context:NULL];

            [self.operation start];
            
        }
     
    }else if ([self.downloadButton.title isEqualToString:@"Pause"]){
        
        [self.operation pause];
        if (self.operation.isPaused) {
            [self.downloadButton setTitle:@"Resume"];
        }
    }else if ([self.downloadButton.title isEqualToString:@"Resume"]){
        
        [self.operation resume];
        if (self.operation.isExecuting) {
            [self.downloadButton setTitle:@"Pause"];
        }
    }
}

- (IBAction)cancelAction:(id)sender {
    
    [self.operation cancel];
}

#pragma mark - Key-Value Observing (KVO)
- (NSString*)nameOfState:(SJURLSessionOperationState)state {
    switch (state) {
        case SJURLSessionOperationExecutingState:
            return @"SJURLSessionOperationExecutingState";
            break;
        case SJURLSessionOperationFinishedState:
            return @"SJURLSessionOperationFinishedState";
            break;
        case SJURLSessionOperationPausedState:
            return @"SJURLSessionOperationPausedState";
            break;
        case SJURLSessionOperationReadyState:
            return @"SJURLSessionOperationReadyState";
        default:
            return nil;
            break;
    };
    
    return nil;
}
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:@"state"]) {
        // ...
        NSLog(@"Operation state: %@",[self nameOfState:self.operation.state]);
        
        if ([self.operation isFinished]) {
            
            @try {
                [object removeObserver:self forKeyPath:@"state"];
            }
            @catch (NSException * __unused exception) {}

        }
        
    }
    
}

#pragma mark - SJURLSessionOperation Blocks
-(void)registerCompletionBlockForOperation:(SJURLSessionOperation *)operation{
    
    [operation setDownloadCompletionBlock:^(SJURLSessionOperation * _Nullable operation, NSError * _Nullable error, NSURL * _Nullable fileURL, NSURLResponse * _Nullable response) {
        
        [self.downloadButton setTitle:@"Download"];
        [self.cancelButton setHidden:YES];

        
        if (error) {
            
            if (error.code != NSURLErrorCancelled) {
                [[NSAlert alertWithError:error]runModal];
            }
            [self.progressLabel setStringValue:error.localizedDescription];
            [self.progressBar setDoubleValue:0];
            [self.percentageTextField setStringValue:@"%0%%"];
            [self.percentageTextField setHidden:YES];
            
        }else{
            
        }
            
    }];
    
}

-(void)registerProgressBlockForOperation:(SJURLSessionOperation *)operation{
    
    [operation setDownloadProgressBlock:^(int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
        
        if (self.percentageTextField.isHidden) {
            [self.percentageTextField setHidden:NO];
        }
        
        if (self.cancelButton.isHidden) {
            [self.cancelButton setHidden:NO];
        }
        
        if ([self.downloadButton.title isEqualToString:@"Download"]) {
            [self.downloadButton setTitle:@"Pause"];
        }
        
        if (self.progressLabel.isHidden) {
            [self.progressLabel setHidden:NO];
        }
        
        
       NSInteger percentage = (double)totalBytesWritten * 100 / (double)totalBytesExpectedToWrite;
        
      [self.progressBar setDoubleValue:percentage];
      [self.percentageTextField setStringValue:[NSString stringWithFormat:@"%ld%%",(long)percentage]];
    
        NSString *formattedByteWritten = [self.byteFormatter stringFromByteCount:(long) (long)totalBytesWritten];
        NSString *formattedExpectedToWrite = [self.byteFormatter stringFromByteCount:(long) (long)totalBytesExpectedToWrite];

        
        [self.progressLabel setStringValue:[NSString stringWithFormat:@"%@ of %@",formattedByteWritten,formattedExpectedToWrite]];

        
    }];
    
    
}

@end
