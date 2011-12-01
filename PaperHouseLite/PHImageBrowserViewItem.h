//
//  PHImageBrowserViewItem.h
//  PaperHouseLite
//
//  Created by cod7ce on 11/21/11.
//  Copyright 2011 纸房子. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>

@interface PHImageBrowserViewItem : NSObject
{
    NSImage * image;
	NSString * imageID;
    NSString *imagePath;
    NSString *size;
}

- (id)initWithImage:(NSImage *)image imageID:(NSString *)imageID;

@property(readwrite,copy) NSImage * image;
@property(readwrite,copy) NSString * imageID;

@property(retain,nonatomic) NSString *imagePath;
@property(retain,nonatomic) NSString *size;

- (NSString *) imageUID;
- (NSString *) imageRepresentationType;
- (id) imageRepresentation;

- (NSString*) imageTitle;
- (NSString*) imageSubtitle;

@end
