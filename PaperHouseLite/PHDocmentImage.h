//
//  PHDocmentImage.h
//  PaperHouseLite
//
//  Created by cod7ce on 11/1/11.
//  Copyright 2011 纸房子. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PHDocmentImage : NSObject
{
    NSString *fullImageSrc;
    NSString *smallImageSrc;
    NSString *originalImageSrc;
}

@property (nonatomic,retain) NSString *fullImageSrc;
@property (nonatomic,retain) NSString *smallImageSrc;
@property (nonatomic,retain) NSString *originalImageSrc;

- (id)initWithFullImageSrc:(NSString *)full SmallImageSrc:(NSString *)small OriginalImageSrc:(NSString *)original;

@end
