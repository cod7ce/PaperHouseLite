//
//  PHImageCell.m
//  PaperHouseLite
//
//  Created by cod7ce on 11/16/11.
//  Copyright 2011 纸房子. All rights reserved.
//

#import "PHImageView.h"

@implementation PHImageView

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)setShareView:(NSView *)shareView PrevBtn:(NSButton *)prevBtn NextBtn:(NSButton *)nextBtn
{
    self.shareView = shareView;
    self.prevBtn = prevBtn;
    self.nextBtn = nextBtn;
}

- (void)setTrackingRect:(NSRect)rect
{
    [self addTrackingRect:rect owner:self userData:nil assumeInside:YES];
}

- (void)mouseExited:(NSEvent *)theEvent
{
    [[self.shareView animator] setAlphaValue:0.0];
    [[self.prevBtn animator] setAlphaValue:0.0];
    [[self.nextBtn animator] setAlphaValue:0.0];
    [super mouseExited:theEvent];
}

- (void)mouseEntered:(NSEvent *)theEvent
{
    [[self.shareView animator] setAlphaValue:1.0];
    [[self.prevBtn animator] setAlphaValue:1.0];
    [[self.nextBtn animator] setAlphaValue:1.0];
    [super mouseEntered:theEvent];
}


@end
