//
//  CXLogEvent.m
//  CXLogging
//
//  Created by Saira on 8/22/16.
//  Copyright © 2016 Saira. All rights reserved.
//

#import "CXLogEvent.h"
#import "Constants.h"

@implementation CXLogEvent

@synthesize timeStamp, level, message, exception, properties;

- (instancetype)initWithTimeStamp:(NSString *)cxTimeStamp level:(NSString *)cxLogLevel
                          message:(NSString *)cxLogMessage
                       properties:(nullable NSMutableDictionary *)cxLogProperties
                     andException:(nullable NSString *)cxLogException {
    
    if (self == [super init]) {
        self.timeStamp = cxTimeStamp;
        self.level = cxLogLevel;
        self.message = cxLogMessage;
        self.properties = [[NSMutableDictionary alloc] initWithDictionary:[cxLogProperties mutableCopy]];
        self.exception = cxLogException;
    }
    return self;
}

- (NSMutableDictionary *)toDictionary {
    
    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
    [data setObject:self.timeStamp forKey:LOG_TIMESTAMP_KEY];
    [data setObject:self.level forKey:LOG_LEVEL_KEY];
    [data setObject:self.message forKey:LOG_MESSAGE_KEY];
    if (self.exception) {
        [data setObject:self.exception forKey:LOG_EXCEPTION_KEY];
    }
    [data setObject:self.properties forKey:LOG_PROPERTIES_KEY];
    
    return data;
}

@end
