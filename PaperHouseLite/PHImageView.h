//
//  PHImageCell.h
//  PaperHouseLite
//
//  Created by cod7ce on 11/16/11.
//  Copyright 2011 纸房子. All rights reserved.
//

#import <AppKit/AppKit.h>

@interface PHImageView : NSImageView

@property (retain,nonatomic) NSView *shareView;
@property (retain,nonatomic) NSButton *prevBtn;
@property (retain,nonatomic) NSButton *nextBtn;

- (void)setTrackingRect:(NSRect)rect;
- (void)setShareView:(NSView *)shareView PrevBtn:(NSButton *)prevBtn NextBtn:(NSButton *)nextBtn;

@end
