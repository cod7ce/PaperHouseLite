//
//  PHImageCell.m
//  PaperHouseLite
//
//  Created by cod7ce on 11/16/11.
//  Copyright 2011 纸房子. All rights reserved.
//

#import "PHImageView.h"

@implementation PHImageView

@synthesize shareView;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)setTrackingRect:(NSRect)rect
{
    [self addTrackingRect:rect owner:self userData:nil assumeInside:YES];
}

- (void)mouseExited:(NSEvent *)theEvent
{
    [[shareView animator] setAlphaValue:0.0];
    [super mouseExited:theEvent];
}

- (void)mouseEntered:(NSEvent *)theEvent
{
    [[shareView animator] setAlphaValue:1.0];
    [super mouseEntered:theEvent];
}


@end
