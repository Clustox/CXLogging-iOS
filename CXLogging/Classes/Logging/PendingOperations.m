//
//  PendingOperations.m
//  CXLogging
//
//  Created by Mac on 30/03/2016.
//  Copyright © 2016 Saira. All rights reserved.
//

#import "PendingOperations.h"

@implementation PendingOperations

@synthesize logglyLogsInProgress = _logglyLogsInProgress;
@synthesize logglyLogsQueue = _logglyLogsQueue;


- (NSMutableDictionary *)logglyLogsInProgress {
    if (!_logglyLogsInProgress) {
        _logglyLogsInProgress = [[NSMutableDictionary alloc] init];
    }
    return _logglyLogsInProgress;
}

- (NSOperationQueue *)logglyLogsQueue {
    if (!_logglyLogsQueue) {
        _logglyLogsQueue = [[NSOperationQueue alloc] init];
        _logglyLogsQueue.name = @"Loggly Logs Queue";
        _logglyLogsQueue.maxConcurrentOperationCount = NSOperationQueueDefaultMaxConcurrentOperationCount;
    }
    return _logglyLogsQueue;
}

@end
