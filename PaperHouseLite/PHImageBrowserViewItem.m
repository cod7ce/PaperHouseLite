//
//  PHImageBrowserViewItem.m
//  PaperHouseLite
//
//  Created by cod7ce on 11/21/11.
//  Copyright 2011 纸房子. All rights reserved.
//

#import "PHImageBrowserViewItem.h"

@implementation PHImageBrowserViewItem

@synthesize image;
@synthesize imageID;
@synthesize imagePath,size;

- (id)initWithImage:(NSImage*)anImage imageID:(NSString*)anImageID
{
	if (self = [super init]) {
		image = [anImage copy];
		imageID = [[anImageID lastPathComponent] copy];
	}
	return self;
}

- (void)dealloc
{
	[image release];
	[imageID release];
	[super dealloc];
}

- (NSString *) imageUID
{
	return imageID;
}
- (NSString *) imageRepresentationType
{
	return IKImageBrowserNSImageRepresentationType;
}
- (id) imageRepresentation
{
	return image;
}

- (NSString*) imageTitle
{
	return imageID;
}

- (NSString*) imageSubtitle
{
    return size;
}




@end
