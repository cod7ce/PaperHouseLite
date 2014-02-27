//
//  DNCircularIndicator.h
//  CircularIndicator
//
//  Created by Xu Jun on 5/8/13.
//  Copyright (c) 2013 Xu Jun. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ASIHTTPRequest.h"

@interface DNCircularIndicator : NSView <ASIProgressDelegate>

@property (nonatomic, assign) BOOL indeterminate;

@property (nonatomic, assign) double minValue;
@property (nonatomic, assign) double maxValue;
@property (nonatomic, assign) double doubleValue;

- (void)startAnimation:(id)sender;
- (void)stopAnimation:(id)sender;

@end
