//
//  CXLogEvent.h
//  CXLogging
//
//  Created by Saira on 8/22/16.
//  Copyright © 2016 Saira. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CXLogEvent : NSObject

@property(nonnull, nonatomic, strong) NSString *timeStamp;

@property(nonnull, nonatomic, strong) NSString *level;

@property(nonnull, nonatomic, strong) NSString *message;

@property(nullable, nonatomic, strong) NSString *exception;

@property(nullable, nonatomic, strong) NSMutableDictionary *properties;

- (nonnull instancetype)initWithTimeStamp:(nonnull NSString *)cxTimeStamp
                            level:(nonnull NSString *)cxLogLevel
                          message:(nonnull NSString *)cxLogMessage
                       properties:(nullable NSMutableDictionary *)cxLogProperties
                     andException:(nullable NSString *)cxLogException;

- (nonnull NSMutableDictionary *)toDictionary;

@end
