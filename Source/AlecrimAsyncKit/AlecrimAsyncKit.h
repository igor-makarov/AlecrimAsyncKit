//
//  AlecrimAsyncKit.h
//  AlecrimAsyncKit
//
//  Created by Vanderlei Martinelli on 2015-08-04.
//  Copyright (c) 2015 Alecrim. All rights reserved.
//

#import <TargetConditionals.h>

#if TARGET_OS_EMBEDDED || TARGET_OS_SIMULATOR
    #import <UIKit/UIKit.h>
#elif TARGET_OS_MAC
    #import <Cocoa/Cocoa.h>
#endif

//! Project version number for AlecrimAsyncKit.
FOUNDATION_EXPORT double AlecrimAsyncKitVersionNumber;

//! Project version string for AlecrimAsyncKit.
FOUNDATION_EXPORT const unsigned char AlecrimAsyncKitVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <AlecrimAsyncKit/PublicHeader.h>


