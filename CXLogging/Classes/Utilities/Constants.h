//
//  Constants.h
//  CXLogging
//
//  Created by Saira on 8/22/16.
//  Copyright © 2016 Saira. All rights reserved.
//

#ifndef Constants_h
#define Constants_h

#pragma mark - Urls

#define LOGGLY_BULK_ENDPOINT @"https://logs-01.loggly.com/bulk/%@/tag/bulk/"
#define USER_TOKEN @"ADD_YOUR_TOKEN_HERE"

#pragma mark - Log Keys

#define CURRENCY_KEY @"default_currency"
#define LOG_LIMIT_KEY @"log_limit"
#define LOG_CURRENCY_KEY @"CURRENCY"
#define LOG_DEVICE_ID_KEY @"DEVCICE_IDENTIFIER"
#define LOG_DEVICE_NAME_KEY @"DEVICE_NAME"
#define LOG_PLATFORM_KEY @"PLATFORM"
#define LOG_OS_VERSION_KEY @"OPERATING_SYSTEM_VERSION"
#define LOG_TIMESTAMP_KEY @"TIME_STAMP"
#define LOG_LEVEL_KEY @"LOG_LEVEL"
#define LOG_MESSAGE_KEY @"MESSAGE"
#define LOG_EXCEPTION_KEY @"EXCEPTION"
#define LOG_PROPERTIES_KEY @"PROPERTIES"
#define LOG_PRE_EXCEPTION_EVENT_COUNT @"PRE_EXCEPTION_EVENT_COUNT"

#pragma mark - File Path

#define LOGGER_DIRECTORY [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"CXLogging"]
#define LOGGER_APP [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"]
#define LOGGER_APP_FORMATTED [[LOGGER_APP stringByReplacingOccurrencesOfString:@" " withString:@"-"] lowercaseString]
#define LOGGER_FILENAME [NSString stringWithFormat:@"%@-logger.txt" ,LOGGER_APP_FORMATTED]
#define DEFAULT_SEPARATOR @"Clustox"

#endif /* Constants_h */
