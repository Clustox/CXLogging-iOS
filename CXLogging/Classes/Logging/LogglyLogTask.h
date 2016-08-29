//
//  LogglyLogTask.h
//  CXLogging
//
//  Created by Saira on 8/22/16.
//  Copyright © 2016 Saira. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LogglyTaskDelegate <NSObject>

- (void)onTaskFinished:(BOOL)success;

@end

@interface LogglyLogTask : NSObject<NSURLSessionDataDelegate>

@property(nonatomic, strong) NSData *dataToPost;

@property(nonatomic, strong) NSOperationQueue *delegateQueue;

@property(nonatomic, weak) id<LogglyTaskDelegate> delegate;

- (id)initWithDelegate:(id<LogglyTaskDelegate>)taskDelegate
                  data:(NSData *)logData
                 queue:(NSOperationQueue *)operationQueue;

- (void)start;

@end
