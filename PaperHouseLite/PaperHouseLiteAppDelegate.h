//
//  PaperHouseLiteAppDelegate.h
//  PaperHouseLite
//
//  Created by cod7ce on 11-10-26.
//  Copyright 2011年 纸房子. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MenubarController.h"
#import "PowerMenuItemView.h"

@interface PaperHouseLiteAppDelegate : NSObject <NSApplicationDelegate, NSPopoverDelegate> {
    NSWindow *window;
    NSStatusItem *theItem;
    
    NSButton *checkLogin;
    
    NSButton *autosetWP;
    NSButton *swifWP;
    NSMatrix *selfPathRadios;
    NSButton *growl;
    
    NSTextField *selfPath;
    
    NSMenuItem *checkUpdateItem;
    
}

@property (assign) IBOutlet NSWindow *window;

@property (nonatomic, retain) IBOutlet NSButton *checkLogin;
@property (nonatomic, retain) IBOutlet NSButton *autosetWP;
@property (nonatomic, retain) IBOutlet NSButton *swifWP;
@property (nonatomic, retain) IBOutlet NSButton *growl;
@property (nonatomic, retain) IBOutlet NSTextField *selfPath;
@property (nonatomic, retain) IBOutlet NSMatrix *selfPathRadios;
@property (nonatomic, retain) IBOutlet NSMenuItem *checkUpdateItem;

-(void)initPreferencePenalWithConfigFile;

-(IBAction)lanuchAtLogin:(id)sender;
-(IBAction)autosetWallpaper:(id)sender;
-(IBAction)autosetWallpaper:(id)sender;
-(IBAction)wpDirectory:(id)sender;
-(IBAction)selectedPath:(id)sender;


#pragma mark For Drop Down Menu
@property (nonatomic, strong) NSPopover *popover;
@property (nonatomic, strong) MenubarController *menubarController;
@property (nonatomic, strong) PowerMenuItemView *powerMenuItemView;

- (IBAction)togglePanel:(id)sender;
@end
