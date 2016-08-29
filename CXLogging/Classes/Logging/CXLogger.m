//
//  CXLogger.m
//  CXLogging
//
//  Created by Saira on 8/22/16.
//  Copyright © 2016 Saira. All rights reserved.
//

#import "CXLogger.h"
#import "CXLogEvent.h"
#import "LogglyLogTask.h"
#import "Constants.h"

@interface CXLogger()<LogglyTaskDelegate> {
    BOOL debugger;
    NSMutableString *cachedEvents;
    NSUInteger cachedEventsCount;
    NSUInteger preExceptionEventCount;
}

@end

@implementation CXLogger

@synthesize cxLogLevel;

static CXLogger *getInstance = nil;

#pragma mark - Lazy instantiation

- (PendingOperations *)pendingOperations {
    if (!_pendingOperations) {
        _pendingOperations = [[PendingOperations alloc] init];
    }
    return _pendingOperations;
}


+ (CXLogger *)getInstance {
    
    if (getInstance == nil) {
        getInstance = [[CXLogger alloc] init];
    }
    
    return getInstance;
}

- (instancetype)init {
    
    if (self == [super init]) {
        debugger = NO;
        cachedEvents = [[NSMutableString alloc] init];
    }
    
    return self;
}

- (void)logEventWithType:(CXLogLevel)logLevel
                 message:(NSString *)message
             ifException:(NSString *)exception {
    
    if (debugger) {
        NSLog(@"%@",message);
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *properties = [[NSMutableDictionary alloc] init];
    
    NSString *currency = [defaults objectForKey:CURRENCY_KEY];
    if (currency) {
        [properties setObject:currency forKey:LOG_CURRENCY_KEY];
    }
    NSString *deviceId = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    if (deviceId) {
        [properties setObject:deviceId forKey:LOG_DEVICE_ID_KEY];
    }
    NSString *deviceName = [[UIDevice currentDevice] name];
    if (deviceName) {
        [properties setObject:deviceName forKey:LOG_DEVICE_NAME_KEY];
    }
    NSString *platform = [[UIDevice currentDevice] systemName];
    if (platform) {
        [properties setObject:platform forKey:LOG_PLATFORM_KEY];
    }
    NSString *osVersion = [[UIDevice currentDevice] systemVersion];
    if (osVersion) {
        [properties setObject:osVersion forKey:LOG_OS_VERSION_KEY];
    }
    
    if ([self shouldLog:logLevel]) {
        
        CXLogEvent *logEvent = [[CXLogEvent alloc] initWithTimeStamp:[self getCurrentTimeStamp]
                                                               level:[self interpretLogType:logLevel]
                                                             message:message
                                                          properties:properties
                                                        andException:exception];
        
        NSMutableDictionary *eventDictionary = [logEvent toDictionary];
        
        if (eventDictionary) {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSUInteger logLimit = [defaults integerForKey:LOG_LIMIT_KEY];
            
            if (exception && [exception length] > 0) {
                
                NSString *logsContent = [self getLogFileContent];
                
                if (logsContent) {
                    
                    logsContent = [logsContent stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                    logsContent = [logsContent stringByReplacingOccurrencesOfString:@"=" withString:@":"];
                    logsContent = [logsContent stringByReplacingOccurrencesOfString:@";" withString:@","];
                    logsContent = [logsContent stringByReplacingOccurrencesOfString:DEFAULT_SEPARATOR withString:@"\n"];
                    
                    NSArray *splitArray = [logsContent componentsSeparatedByString:@"\n"];
                   
                    NSUInteger arrayCount = [splitArray count];
                    if (splitArray && arrayCount > 0) {
                        if (arrayCount < 50) {
                            [cachedEvents appendString:logsContent];
                            preExceptionEventCount = arrayCount;
                            cachedEventsCount = arrayCount;
                        } else {
                            NSArray *lastFiftyEvents = [splitArray subarrayWithRange:NSMakeRange(arrayCount - 51,50)];
                            [cachedEvents appendString:[lastFiftyEvents componentsJoinedByString:@""]];
                            preExceptionEventCount = [lastFiftyEvents count];
                            cachedEventsCount = [lastFiftyEvents count];
                        }
                        
                        [defaults setInteger:preExceptionEventCount forKey:LOG_PRE_EXCEPTION_EVENT_COUNT];
                        [cachedEvents appendString:[NSString stringWithFormat:@"\n%@", eventDictionary]];
                        cachedEventsCount = cachedEventsCount + 1;
                    }
                }
            }
            
            NSUInteger preExceptionCount = [defaults integerForKey:LOG_PRE_EXCEPTION_EVENT_COUNT];
            NSUInteger maxCachedEventsCount = preExceptionCount + logLimit + 1;
            
            if (cachedEventsCount > 0 && cachedEventsCount < maxCachedEventsCount) {
                [cachedEvents appendString:[NSString stringWithFormat:@"\n%@", eventDictionary]];
                cachedEventsCount = cachedEventsCount + 1;
            }
            
            if (cachedEventsCount >= 20) {
                if (cachedEvents) {
                    NSData *logsData = [cachedEvents dataUsingEncoding:NSUTF8StringEncoding];
                    LogglyLogTask *logglyLogTask = [[LogglyLogTask alloc] initWithDelegate:self
                                                                                data:logsData
                                                                               queue:self.pendingOperations.logglyLogsQueue];
                    [logglyLogTask start];
                }
            }
            
            [self log:eventDictionary];            
        }
    }
    
}

- (NSString *)getCurrentTimeStamp {
    NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
    NSString *timeStampString = [NSString stringWithFormat:@"%.000f", timeStamp];
    return timeStampString;
}

- (void)log:(NSDictionary *)logsDict {
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:LOGGER_DIRECTORY]) {
        
        [[NSFileManager defaultManager] createDirectoryAtPath:LOGGER_DIRECTORY withIntermediateDirectories:false attributes:nil error:nil];
        
        if (debugger) NSLog(@"PSLogger file created: %@" ,LOGGER_FILENAME);
        
    }
    
    NSMutableData *logData = [[NSMutableData alloc] init];
    NSData *previousData = [NSData dataWithContentsOfURL:[self getLogFileUrl]];
    NSData *separatorData = [DEFAULT_SEPARATOR dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSData *currentEventData = [NSJSONSerialization dataWithJSONObject:logsDict options:NSJSONWritingPrettyPrinted error:&error];
    
    if (previousData) {
        [logData appendData:previousData];
    }
    if (separatorData) {
        [logData appendData:separatorData];
    }
    if (logData) {
        [logData appendData:currentEventData];
    }
    
    if (!logData) {
        NSLog(@"Got an error: %@", error);
    } else {
        NSError *writingError;
        if (![logData writeToURL:[self getLogFileUrl] atomically:true]) {
            if (debugger) NSLog(@"PSLogger was not updated due to error: %@" ,writingError);
        } else {
            if (debugger) NSLog(@"PSLogger event added");
        }
        
        [self compactLogFile];
    }
}

- (void)sendLogsToServer {
    
    NSString *logsContent = [self getLogFileContent];
        
    logsContent = [logsContent stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    logsContent = [logsContent stringByReplacingOccurrencesOfString:@"=" withString:@":"];
    logsContent = [logsContent stringByReplacingOccurrencesOfString:@";" withString:@","];
    logsContent = [logsContent stringByReplacingOccurrencesOfString:DEFAULT_SEPARATOR withString:@"\n"];
        
    if (logsContent) {
        NSData *logsData = [logsContent dataUsingEncoding:NSUTF8StringEncoding];
        LogglyLogTask *logglyLogTask = [[LogglyLogTask alloc] initWithDelegate:self
                                                                          data:logsData
                                                                         queue:self.pendingOperations.logglyLogsQueue];
        [logglyLogTask start];
    }
}

- (BOOL)shouldLog:(CXLogLevel)logLevel {
    BOOL shouldLog = NO;
    if (self.cxLogLevel <= logLevel) {
        shouldLog = YES;
    }
    
    return shouldLog;
}

- (NSString *)interpretLogType:(CXLogLevel)logLevel {
    switch (logLevel) {
        case CXLogLevelDebug:
            return @"Debug";
            break;
        case CXLogLevelError:
            return @"Error";
            break;
        case CXLogLevelInfo:
            return @"Info";
            break;
        case CXLogLevelNone:
            return @"None";
            break;
        default:
            break;
    }
}

- (NSString *)formatDate {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone defaultTimeZone]];
    [formatter setDateFormat:@"HH:mm:ss EEE dd/MM/yyyy"];
    
    return [formatter stringFromDate:[NSDate date]];
}

- (NSURL *)getLogFileUrl {
    return [NSURL fileURLWithPath:[LOGGER_DIRECTORY stringByAppendingPathComponent:LOGGER_FILENAME]];
    
}

- (NSString *)getLogFileContent {
    
    if ([[NSString stringWithContentsOfFile:[LOGGER_DIRECTORY stringByAppendingPathComponent:LOGGER_FILENAME] encoding:NSUTF8StringEncoding error:NULL] length] != 0) {
        
        return [NSString stringWithContentsOfFile:[LOGGER_DIRECTORY stringByAppendingPathComponent:LOGGER_FILENAME] encoding:NSUTF8StringEncoding error:NULL];
    } else {
        return @"";
    }
    
}

- (NSData *)getLogsData {
    
    if ([[NSString stringWithContentsOfFile:[LOGGER_DIRECTORY stringByAppendingPathComponent:LOGGER_FILENAME] encoding:NSUTF8StringEncoding error:NULL] length] != 0) {
        
        NSString *logsContent = [self getLogFileContent];
        
        logsContent = [logsContent stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        logsContent = [logsContent stringByReplacingOccurrencesOfString:@"=" withString:@":"];
        logsContent = [logsContent stringByReplacingOccurrencesOfString:@";" withString:@","];
        logsContent = [logsContent stringByReplacingOccurrencesOfString:DEFAULT_SEPARATOR withString:@"\n"];
        
        if (logsContent) {
            NSData *logsData = [logsContent dataUsingEncoding:NSUTF8StringEncoding];
            if (logsData) {
                return logsData;
            }
        }
    }
    
    return [NSData data];
}

- (NSNumber *)getFileSize {
    
    NSError *error;
    NSURL *fileUrl = [self getLogFileUrl];
    NSString *absolutePath = [fileUrl path];
    NSDictionary *fileDictionary = [[NSFileManager defaultManager] attributesOfItemAtPath:absolutePath error: &error];
    
    NSNumber *size = [fileDictionary objectForKey:NSFileSize];
    return size;
}

- (BOOL)compactLogFile {
    
    BOOL success = NO;
    NSNumber *logFileSize = [self getFileSize];
    NSNumber *maxFileSize = [NSNumber numberWithLong:4194304];
    
    if (logFileSize && logFileSize >= maxFileSize) {
        NSString *logsContent = [self getLogFileContent];
        
        if (logsContent) {
            NSArray *splitArray = [logsContent componentsSeparatedByString:DEFAULT_SEPARATOR];
            
            if (splitArray && [splitArray count] > 0) {
                
                NSUInteger arrayCount = [splitArray count];
                if (arrayCount && arrayCount > 5) {
                    NSUInteger subArrayCount = arrayCount/5 - 1;
                    NSArray *subArray = [splitArray subarrayWithRange:NSMakeRange(subArrayCount, arrayCount - subArrayCount)];
                    
                    if (subArray && [subArray count] > 0) {
                        
                        NSMutableString *appendContents = [[NSMutableString alloc] init];
                        
                        for (int counter = 0; counter < [subArray count]; counter++) {
                            
                            NSString *logEvent = [subArray objectAtIndex:counter];
                            if (logEvent && ![logEvent isEqualToString:DEFAULT_SEPARATOR]) {
                                [appendContents appendString:[NSString stringWithFormat:@"%@\n" ,[subArray objectAtIndex:counter]]];
                                if (counter < [subArray count] - 1) {
                                    [appendContents appendString:DEFAULT_SEPARATOR];
                                }
                            }
                        }
                        
                        NSError *writingError;
                        if ([appendContents writeToURL:[self getLogFileUrl] atomically:true encoding:NSUTF8StringEncoding error:&writingError]) {
                            success = YES;
                        }
                    }
                }
            }
        }
    }
    
    return success;
}

- (BOOL)deleteFileAtPath:(NSURL *)filePath {
    
    NSError *error;
    BOOL success = [[NSFileManager defaultManager] removeItemAtPath:filePath.path error:&error];
    if (success) {
        if (debugger) {
            NSLog(@"Log File deleted successfully");
        }
    } else {
        if (debugger) {
            NSLog(@"Could not delete file -:%@ ",error.localizedDescription);
        }
    }
    return success;
}

#pragma MARK - LogglyTaskDelegate method

- (void)onTaskFinished:(BOOL)success {
    if (success) {
        if (cachedEvents) {
            cachedEvents = [NSMutableString stringWithString:@""];
        }
    }
}

@end
