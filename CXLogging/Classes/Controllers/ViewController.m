//
//  ViewController.m
//  CXLogging
//
//  Created by Saira on 8/22/16.
//  Copyright © 2016 Saira. All rights reserved.
//

#import "ViewController.h"
#import "CXLogger.h"
#import "Constants.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [[CXLogger getInstance] logEventWithType:CXLogLevelError
                                     message:@"Button Pressed"
                                 ifException:nil];
}

- (IBAction)sendLogsToServer:(id)sender {
    if ([USER_TOKEN isEqualToString:@"ADD_YOUR_TOKEN_HERE"]) {
        NSLog(@"Please replace your token with USER_TOKEN in Constants");
        return;
    }
        
    [[CXLogger getInstance] sendLogsToServer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
