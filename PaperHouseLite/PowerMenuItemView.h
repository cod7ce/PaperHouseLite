//
//  PowerMenuItemView.h
//  PaperHouseLite
//
//  Created by cod7ce on 10/28/11.
//  Copyright 2011 纸房子. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Growl/Growl.h>
#import "PHImageView.h"

typedef enum {
    Item,
	Title,
	Description,
    NoUse
} ElementName;

@interface PowerMenuItemView : NSViewController <NSMenuDelegate, NSXMLParserDelegate, NSComboBoxDelegate, GrowlApplicationBridgeDelegate>
{
    PHImageView *imageCell;
    NSComboBox *comboBox;
    NSProgressIndicator *indicator;
 /*   
    NSButton *set;
    NSButton *download;
    NSButton *fullView;
    NSButton *prev;
    NSButton *next;
  */  
    NSView *shareView;
    
    IBOutlet NSView *waitView;
    IBOutlet NSProgressIndicator *waitIndicator;
    NSUInteger cellIndex;
    NSUInteger imageIndex;
    NSMutableArray *allImage;
    NSString *cellName;
}

@property (retain,nonatomic) IBOutlet PHImageView *imageCell;
@property (retain,nonatomic) IBOutlet NSComboBox *comboBox;
@property (retain,nonatomic) IBOutlet NSProgressIndicator *indicator;

@property (retain,nonatomic) IBOutlet NSView *shareView;

 /* 
@property (retain,nonatomic) IBOutlet NSButton *set;
@property (retain,nonatomic) IBOutlet NSButton *download;
@property (retain,nonatomic) IBOutlet NSButton *fullView;
@property (retain,nonatomic) IBOutlet NSButton *prev;
@property (retain,nonatomic) IBOutlet NSButton *next;
*/
@property (nonatomic) NSUInteger cellIndex;
@property (nonatomic) NSUInteger imageIndex;
@property (nonatomic,retain) NSMutableArray *allImage;
@property (nonatomic,retain) NSString *cellName;
//@property (retain,nonatomic) IBOutlet NSButton *setWallPaper;

-(IBAction) nextImage:(id)sender;
-(IBAction) prevImage:(id)sender;
-(IBAction) suffFullImage:(id)sender;
-(IBAction) saveFullImage:(id)sender;
-(IBAction) setWallPaper:(id)sender;

-(IBAction) shareSNSAction:(id)sender;

-(void)getDataWithNewThread;
-(void)changeShareViewSize;
-(void) setImageCellWithCellIndex:(NSUInteger)index1 AndImageIndex:(NSUInteger)index2;
-(NSString *) getFileNameURLWithImageSrc:(NSString *)imageSrc;
-(void) toggleIndicator;

@end
