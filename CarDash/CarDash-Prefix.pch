//
//  Prefix header
//
//  The contents of this file are implicitly included at the beginning of every source file.
//

#import <Availability.h>

#ifndef __IPHONE_3_0
#warning "This project uses features only available in iOS SDK 3.0 and later."
#endif

#ifdef __OBJC__
    #import <UIKit/UIKit.h>
    #import <Foundation/Foundation.h>
    #import "FAOBD2Communicator.h"
#endif

#ifndef CONFIGURATION_AppStore
#define DEBUG_ON 1
#endif

#ifdef DEBUG_ON
#define DEBUG_NSLOG_FUNCTION_CALL	NSLog(@"%s", __PRETTY_FUNCTION__ );
#define DLog( s, ... ) NSLog( @"<%p %@:(%d)> %@", self, [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )
#else
#define DEBUG_NSLOG_FUNCTION_CALL
#define DLog( s, ... )
#endif