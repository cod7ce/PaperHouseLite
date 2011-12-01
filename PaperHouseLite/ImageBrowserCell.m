/*
 
 File:		ImageBrowserCell.m
 
 Abstract:	IKImageBrowserView is a view that can display and browse a 
 large amount of images and movies. This sample code demonstrates 
 how to use the view in a Cocoa Application.
 
 Version:	1.0
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the
 following terms, and your use, installation, modification or
 redistribution of this Apple software constitutes acceptance of these
 terms.  If you do not agree with these terms, please do not use,
 install, modify or redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software. 
 Neither the name, trademarks, service marks or logos of Apple Inc.
 may be used to endorse or promote products derived from the Apple
 Software without specific prior written permission from Apple.  Except
 as expressly stated in this notice, no other rights or licenses, express
 or implied, are granted by Apple herein, including but not limited to
 any patent rights that may be infringed by your derivative works or by
 other works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright © 2009 Apple Inc. All Rights Reserved
 
 */


#import "ImageBrowserCell.h"
#import "Utilities.h"


//---------------------------------------------------------------------------------
// glossyImage
//
// utilty function that creates, caches and returns the image named glossy.png
//---------------------------------------------------------------------------------
static CGImageRef glossyImage()
{
	static CGImageRef image = NULL;
	
	if(image == NULL)
		image = createImageWithName(@"glossy.png");
	
	return image;
}

//---------------------------------------------------------------------------------
// pinImage
//
// utilty function that creates, caches and returns the image named pin.tiff
//---------------------------------------------------------------------------------
static CGImageRef pinImage()
{
	static CGImageRef image = NULL;
	
	if(image == NULL)
		image = createImageWithName(@"pin.tiff");
	
	return image;
}


@implementation ImageBrowserCell

//---------------------------------------------------------------------------------
// layerForType:
//
// provides the layers for the given types
//---------------------------------------------------------------------------------
- (CALayer *) layerForType:(NSString*) type
{
	CGColorRef color;
	//retrieve some usefull rects
	NSRect frame = [self frame];
    //NSLog(@"frame [%f , %f, %f , %f]",frame.origin.x,frame.origin.y,frame.size.width,frame.size.height);
	NSRect imageFrame = [self imageFrame];
    //NSLog(@"imageFrame [%f , %f, %f , %f]",imageFrame.origin.x,imageFrame.origin.y,imageFrame.size.width,imageFrame.size.height);
	NSRect relativeImageFrame = NSMakeRect(imageFrame.origin.x - frame.origin.x, imageFrame.origin.y - frame.origin.y, imageFrame.size.width, imageFrame.size.height);
   // NSLog(@"relativeImageFrame [%f , %f, %f , %f]",relativeImageFrame.origin.x,relativeImageFrame.origin.y,relativeImageFrame.size.width,relativeImageFrame.size.height);
    
    //NSRect container = [super imageContainerFrame];
    //NSLog(@"container [%f , %f, %f , %f]",container.origin.x,container.origin.y,container.size.width,container.size.height);
	/* place holder layer */
	if(type == IKImageBrowserCellPlaceHolderLayer){
        return nil;
		//create a place holder layer
		CALayer *layer = [CALayer layer];
		layer.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);

		CALayer *placeHolderLayer = [CALayer layer];
		placeHolderLayer.frame = *(CGRect*) &relativeImageFrame;

		double fillComponents[4] = {1.0, 1.0, 1.0, 0.3};
		double strokeComponents[4] = {1.0, 1.0, 1.0, 0.9};
		CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();

		//set a background color
		color = CGColorCreate(colorSpace, fillComponents);
		[placeHolderLayer setBackgroundColor:color];
		CFRelease(color);
		
		//set a stroke color
		color = CGColorCreate(colorSpace, strokeComponents);
		[placeHolderLayer setBorderColor:color];
		CFRelease(color);
	
		[placeHolderLayer setBorderWidth:1.0];
		[placeHolderLayer setCornerRadius:3];
		CFRelease(colorSpace);
		
		[layer addSublayer:placeHolderLayer];
		
		return layer;
	}
	
	/* foreground layer */
	if(type == IKImageBrowserCellForegroundLayer){
		//no foreground layer on place holders
        return nil;
		if([self cellState] != IKImageStateReady)
			return nil;
		
		//create a foreground layer that will contain several childs layer
		CALayer *layer = [CALayer layer];
		layer.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);

		NSRect imageContainerFrame = [self imageContainerFrame];
		NSRect relativeImageContainerFrame = NSMakeRect(imageContainerFrame.origin.x - frame.origin.x, imageContainerFrame.origin.y - frame.origin.y, imageContainerFrame.size.width, imageContainerFrame.size.height);
		
		//add a glossy overlay
		CALayer *glossyLayer = [CALayer layer];
		glossyLayer.frame = *(CGRect*) &relativeImageContainerFrame;
		[glossyLayer setContents:(id)glossyImage()];
		[layer addSublayer:glossyLayer];
		
		//add a pin icon
        /*
		CALayer *pinLayer = [CALayer layer];
		[pinLayer setContents:(id)pinImage()];
		pinLayer.frame = CGRectMake((frame.size.width/2)-5, frame.size.height - 17, 24, 30);
		[layer addSublayer:pinLayer];
         */
		
		return layer;
	}

	/* selection layer */
	if(type == IKImageBrowserCellSelectionLayer){

		//create a selection layer
		CALayer *selectionLayer = [CALayer layer];
		selectionLayer.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
		double fillComponents[4] = {0.18, 0.42, 0.97, 0.9};
		double strokeComponents[4] = {0.18, 0.42, 0.97, 1.0};
		
		//set a background color
		CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
		color = CGColorCreate(colorSpace, fillComponents);
		[selectionLayer setBackgroundColor:color];
		CFRelease(color);
		
		//set a border color
		color = CGColorCreate(colorSpace, strokeComponents);
		[selectionLayer setBorderColor:color];
		CFRelease(color);

		[selectionLayer setBorderWidth:1.0];
		[selectionLayer setCornerRadius:3];
		
		return selectionLayer;
	}
	
	/* background layer */
	if(type == IKImageBrowserCellBackgroundLayer){
		//no background layer on place holders
        return nil;
		if([self cellState] != IKImageStateReady)
			return nil;
        
		CALayer *layer = [CALayer layer];
		layer.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
		
		NSRect backgroundRect = NSMakeRect(0, 0, frame.size.width, frame.size.height);		
		
		CALayer *photoBackgroundLayer = [CALayer layer];
		photoBackgroundLayer.frame = *(CGRect*) &backgroundRect;
				
		double fillComponents[4] = {0.95, 0.95, 0.95, 1.0};
		double strokeComponents[4] = {0.2, 0.2, 0.2, 0.5};

		CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
		
		color = CGColorCreate(colorSpace, fillComponents);
		[photoBackgroundLayer setBackgroundColor:color];
		CFRelease(color);
		
		color = CGColorCreate(colorSpace, strokeComponents);
		[photoBackgroundLayer setBorderColor:color];
		CFRelease(color);

		[photoBackgroundLayer setBorderWidth:1.0];
		[photoBackgroundLayer setShadowOpacity:0.5];
		[photoBackgroundLayer setCornerRadius:3];
		
		CFRelease(colorSpace);
		
		[layer addSublayer:photoBackgroundLayer];
		
		return layer;
	}
	
	return nil;
}

- (NSRect) frame
{
    NSRect frame = [super imageFrame];
    return frame;
}

//---------------------------------------------------------------------------------
// imageFrame
//
// define where the image should be drawn
//---------------------------------------------------------------------------------
- (NSRect) imageFrame
{
    return [super imageFrame];
    NSLog(@"step imageFrame");
	//get default imageFrame and aspect ratio
	NSRect imageFrame = [super imageFrame];
	
	if(imageFrame.size.height == 0 || imageFrame.size.width == 0) return NSZeroRect;
	
	float aspectRatio =  imageFrame.size.width / imageFrame.size.height;
	
	// compute the rectangle included in container with a margin of at least 10 pixel at the bottom, 5 pixel at the top and keep a correct  aspect ratio
	NSRect container = [self imageContainerFrame];
	container = NSInsetRect(container, 2, 2);
	
	if(container.size.height <= 0) return NSZeroRect;
	
	float containerAspectRatio = container.size.width / container.size.height;
	
	if(containerAspectRatio > aspectRatio){
		imageFrame.size.height = container.size.height;
		imageFrame.origin.y = container.origin.y;
		imageFrame.size.width = imageFrame.size.height * aspectRatio;
		imageFrame.origin.x = container.origin.x + (container.size.width - imageFrame.size.width)*0.5;
	}
	else{
		imageFrame.size.width = container.size.width;
		imageFrame.origin.x = container.origin.x;		
		imageFrame.size.height = imageFrame.size.width / aspectRatio;
		imageFrame.origin.y = container.origin.y + container.size.height - imageFrame.size.height;
	}
	
	//round it
	imageFrame.origin.x = floorf(imageFrame.origin.x);
	imageFrame.origin.y = floorf(imageFrame.origin.y);
	imageFrame.size.width = ceilf(imageFrame.size.width);
	imageFrame.size.height = ceilf(imageFrame.size.height);
	
    
    
	return imageFrame;
}

//---------------------------------------------------------------------------------
// imageContainerFrame
//
// override the default image container frame
//---------------------------------------------------------------------------------
- (NSRect) imageContainerFrame
{
    return [super frame];
    NSLog(@"step imageContainerFrame");
	NSRect container = [super frame];
    container.origin.y += 15;
	container.size.height -= 15;
	return container;
}

//---------------------------------------------------------------------------------
// titleFrame
//
// override the default frame for the title
//---------------------------------------------------------------------------------
- (NSRect) titleFrame
{	
    NSRect titleFrame =  [super titleFrame];
    titleFrame.size.height = 16.0;
    return [super titleFrame];
}

//---------------------------------------------------------------------------------
// selectionFrame
//
// make the selection frame a little bit larger than the default one
//---------------------------------------------------------------------------------
- (NSRect) selectionFrame
{
	return NSInsetRect([self frame], -5, -5);
}

@end
