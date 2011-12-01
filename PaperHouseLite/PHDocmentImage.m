//
//  PHDocmentImage.m
//  PaperHouseLite
//
//  Created by cod7ce on 11/1/11.
//  Copyright 2011 纸房子. All rights reserved.
//

#import "PHDocmentImage.h"

@implementation PHDocmentImage

@synthesize fullImageSrc, smallImageSrc, originalImageSrc;

- (id)init
{
    self = [super init];
    if (self) {
        
    } 
    return self;
}

- (id)initWithFullImageSrc:(NSString *)full SmallImageSrc:(NSString *)small OriginalImageSrc:(NSString *)original
{
    self = [super init];
    if (self) {
        self.fullImageSrc = full;
        self.smallImageSrc = small;
        self.originalImageSrc = original;
    } 
    return self;
}



@end
