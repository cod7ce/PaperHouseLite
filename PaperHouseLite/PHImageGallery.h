//
//  PHImageGallery.h
//  PaperHouseLite
//
//  Created by cod7ce on 11/18/11.
//  Copyright 2011 纸房子. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>
#import "MBCoverFlowView.h"

@interface PHImageGallery : NSWindowController
{
    NSFileManager *fileManager;
    NSMutableArray *imgArray;
    NSMutableArray *coverArray;
    
    IBOutlet MBCoverFlowView *coverFlowView;
    IBOutlet IKImageBrowserView *browserView;
    IBOutlet NSProgressIndicator *indicator;
    IBOutlet NSSlider *slider;
    IBOutlet NSWindow *owindow;
}

@property (retain,nonatomic) NSFileManager *fileManager;
@property (retain,nonatomic) NSMutableArray *imgArray;
@property (retain,nonatomic) NSMutableArray *coverArray;

-(void)getAllWallpaper:(NSString *)dir;
-(BOOL)isImageExtend:(NSString *)path;

- (IBAction)zoomSliderDidChange:(id)sender;
- (IBAction)viewChange:(id)sender;

-(void) toggleIndicator;
- (void)transformWindowToSize:(NSSize)size;

@end