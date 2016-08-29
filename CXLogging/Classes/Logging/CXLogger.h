//
//  CXLogger.h
//  CXLogging
//
//  Created by Saira on 8/22/16.
//  Copyright © 2016 Saira. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "PendingOperations.h"
#import "Enums.h"

@interface CXLogger : NSObject

@property(readwrite) CXLogLevel cxLogLevel;

@property(nonatomic, strong) PendingOperations *pendingOperations;

+ (CXLogger *)getInstance;

- (void)logEventWithType:(CXLogLevel)logLevel
                 message:(NSString *)message
             ifException:(NSString *)exception;

- (void)sendLogsToServer;

- (NSURL *)getLogFileUrl;

- (NSData *)getLogsData;

@end

