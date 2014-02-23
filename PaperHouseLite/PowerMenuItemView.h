//
//  PowerMenuItemView.h
//  PaperHouseLite
//
//  Created by cod7ce on 10/28/11.
//  Copyright 2011 纸房子. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PHImageView.h"
#import "ASIFormDataRequest.h"
#import "PHDocmentImage.h"

typedef enum {
    Item,
	Title,
	Description,
    NoUse
} ElementName;

@interface PowerMenuItemView : NSViewController <NSMenuDelegate, ASIHTTPRequestDelegate>
{
    PHImageView *imageCell;
    NSProgressIndicator *indicator;
 /*   
    NSButton *set;
    NSButton *download;
    NSButton *fullView;
    NSButton *prev;
    NSButton *next;
  */
    
    NSUInteger count;
    NSUInteger page;
}

@property (retain,nonatomic) IBOutlet PHImageView *imageCell;
@property (retain,nonatomic) IBOutlet NSProgressIndicator *indicator;

@property (retain,nonatomic) IBOutlet NSView *toolView;
@property (assign) IBOutlet NSButton *prevBtn;
@property (assign) IBOutlet NSButton *nextBtn;

@property (retain,nonatomic) PHDocmentImage *documentImage;
@property (nonatomic) NSUInteger count;
@property (nonatomic) NSUInteger page;
//@property (retain,nonatomic) IBOutlet NSButton *setWallPaper;
@property (assign) IBOutlet NSButton *helpNaviButton;

-(IBAction) nextImage:(id)sender;
-(IBAction) prevImage:(id)sender;
-(IBAction) suffFullImage:(id)sender;
-(IBAction) saveFullImage:(id)sender;
-(IBAction) setWallPaper:(id)sender;

-(IBAction) shareSNSAction:(id)sender;
- (IBAction)howToUseAction:(id)sender;

-(void)changeShareViewSize;
-(void) toggleIndicator;

@end
