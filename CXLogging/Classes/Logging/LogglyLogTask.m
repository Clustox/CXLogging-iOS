//
//  LogglyLogTask.m
//  CXLogging
//
//  Created by Saira on 8/22/16.
//  Copyright © 2016 Saira. All rights reserved.
//

#import "LogglyLogTask.h"
#import "Constants.h"

@implementation LogglyLogTask

@synthesize delegate, dataToPost, delegateQueue;

- (id)initWithDelegate:(id<LogglyTaskDelegate>)taskDelegate
                  data:(NSData *)logData
                 queue:(NSOperationQueue *)operationQueue {
    
    if (self == [super init]) {
        self.delegate = taskDelegate;
        self.dataToPost = logData;
        self.delegateQueue = operationQueue;
    }
    
    return self;
}


- (void)start {
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration:defaultConfigObject
                                                                 delegate:self
                                                            delegateQueue:self.delegateQueue];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat: LOGGLY_BULK_ENDPOINT, USER_TOKEN]];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setHTTPBody:self.dataToPost];
    
    NSURLSessionDataTask * dataTask = [defaultSession dataTaskWithRequest:urlRequest];
    [dataTask resume];
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
            didReceiveResponse:(NSURLResponse *)response
        completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
            didReceiveData:(NSData *)data {
    NSString * str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"Received String %@",str);
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
            didCompleteWithError:(NSError *)error {
    if(error == nil) {
        [self.delegate onTaskFinished:YES];
    } else {
        [self.delegate onTaskFinished:NO];
    }
}


@end
