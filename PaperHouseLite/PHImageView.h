//
//  PHImageCell.h
//  PaperHouseLite
//
//  Created by cod7ce on 11/16/11.
//  Copyright 2011 纸房子. All rights reserved.
//

#import <AppKit/AppKit.h>

@interface PHImageView : NSImageView
{
    NSView *shareView;
}

@property (retain,nonatomic) NSView *shareView;

- (void)setTrackingRect:(NSRect)rect;

@end
