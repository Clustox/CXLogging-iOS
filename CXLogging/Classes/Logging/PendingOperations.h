//
//  PendingOperations.h
//  CXLogging
//
//  Created by Mac on 30/03/2016.
//  Copyright © 2016 Saira. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PendingOperations : NSObject

@property(nonatomic, strong) NSMutableDictionary *logglyLogsInProgress;

@property(nonatomic, strong) NSOperationQueue *logglyLogsQueue;


@end
