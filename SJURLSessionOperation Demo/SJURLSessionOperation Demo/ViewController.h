//
//  ViewController.h
//  SJURLSessionOperation Demo
//
//  Created by Soneé John on 2/16/16.
//  Copyright © 2016 AlphaSoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ViewController : NSViewController

@property (weak) IBOutlet NSTextField *urlTextField;

@property (weak) IBOutlet NSButton *downloadButton;
@property (weak) IBOutlet NSButton *cancelButton;

@property (weak) IBOutlet NSProgressIndicator *progressBar;
@property (weak) IBOutlet NSTextField *percentageTextField;
@property (weak) IBOutlet NSTextField *progressLabel;

- (IBAction)operationControlAction:(id)sender;
- (IBAction)cancelAction:(id)sender;

@end

