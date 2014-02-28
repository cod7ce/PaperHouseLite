//
//  PaperHouseLiteAppDelegate.m
//  PaperHouseLite
//
//  Created by cod7ce on 11-10-26.
//  Copyright 2011年 纸房子. All rights reserved.
//

#import "PaperHouseLiteAppDelegate.h"
#import "PHImageGallery.h"
#import "PHConfig.h"
#import "PHTool.h"
#import "StatusItemView.h"

@implementation PaperHouseLiteAppDelegate

@synthesize window;
@synthesize checkLogin,autosetWP,swifWP,selfPath,selfPathRadios,checkUpdateItem,growl;

@synthesize panelController = _panelController;

void *kContextActivePanel = &kContextActivePanel;

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == kContextActivePanel) {
        self.menubarController.hasActiveIcon = self.panelController.hasActivePanel;
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}


#pragma mark -

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    
    if([[PHConfig sharedPHConfigure] weatherFirstLaunch])
    {
        [PHTool addAppAsLoginItem];
    }
    [self initPreferencePenalWithConfigFile];
    
    self.menubarController = [[MenubarController alloc] init];
    //self.powerMenuItemView = [[PowerMenuItemView alloc] initWithNibName:@"PowerMenuItemView" bundle:nil];
    [self initRightClickMenuForStatusBar];
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
    // Explicitly remove the icon from the menu bar
    self.menubarController = nil;
    return NSTerminateNow;
}

- (void)initRightClickMenuForStatusBar
{
    self.rightClickMenu = [[NSMenu alloc] initWithTitle:@"nihao"];
    
    //* 菜单元素对象，add后release
    NSMenuItem *menuItem;
    
    menuItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"about", nil) action:@selector(showAppAboutPage) keyEquivalent:@""];
    menuItem.tag = 1;
    [self.rightClickMenu addItem:menuItem];
    [menuItem release];
    
    
    menuItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"home", nil) action:@selector(openZHZWebSite) keyEquivalent:@"a"];
    menuItem.tag = 3;
    [self.rightClickMenu addItem:menuItem];
    [menuItem release];
    
    [self.rightClickMenu addItem:[NSMenuItem separatorItem]];
    
    menuItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Preferences", nil) action:@selector(setAppPreferences) keyEquivalent:@","];
    menuItem.tag = 2;
    [self.rightClickMenu addItem:menuItem];
    [menuItem release];
    
    [self.rightClickMenu addItem:checkUpdateItem];
    
    [self.rightClickMenu addItem:[NSMenuItem separatorItem]];
    /*
     menuItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"gallery", nil) action:@selector(openGallery) keyEquivalent:@"g"];
     menuItem.tag = 2;
     [theMenu addItem:menuItem];
     [menuItem release];
     
     [theMenu addItem:[NSMenuItem separatorItem]];
     */
    
    menuItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"exit", nil) action:@selector(exitApp) keyEquivalent:@"q"];
    menuItem.tag = 5;
    [self.rightClickMenu addItem:menuItem];
    [menuItem release];
    
    self.rightClickMenu.delegate = self;
}

#pragma mark Drop Down Menu 部分

// Actions

- (IBAction)togglePanel:(id)sender
{
    StatusItemView *statusItem = (StatusItemView *)sender;
    if (statusItem.eventType == NSLeftMouseDown)
    {
        self.menubarController.hasActiveIcon = !self.menubarController.hasActiveIcon;
        self.panelController.hasActivePanel = self.menubarController.hasActiveIcon;
        /*
        if (self.popover == nil)
        {
            self.popover = [[NSPopover alloc] init];
            //self.popover.appearance = NSPopoverAppearanceHUD;
            self.popover.contentViewController = self.powerMenuItemView;
            self.popover.animates = YES;
            self.popover.behavior = NSPopoverBehaviorTransient;
            
            // so we can be notified when the popover appears or closes
            self.popover.delegate = self;
            
            NSView *siv = (NSView *)self.menubarController.statusItemView;
            // configure the preferred position of the popover
            NSRectEdge prefEdge = NSMaxYEdge;
            [self.popover showRelativeToRect:[siv bounds] ofView:siv preferredEdge:prefEdge];
            [self.popover.contentViewController.view.window becomeFirstResponder];
        }
         */
    }
    else if (statusItem.eventType == NSRightMouseDown)
    {
        NSLog(@"right mouse down");
        NSLog(@"%@", self.menubarController.statusItem.menu);
        
        [self.menubarController.statusItem popUpStatusItemMenu:self.rightClickMenu];
    }
}

#pragma mark 偏好设置部分
// 初始化偏好设置面板
- (void)initPreferencePenalWithConfigFile
{
    // 存储路径
    if (![[PHConfig sharedPHConfigure] weatherDefaultWPDirectory])
    {
        [selfPathRadios selectCellAtRow:1 column:0];
        [selfPath setStringValue:[[PHConfig sharedPHConfigure] getPicPath]];
    }
    // growl提示
    if([[PHConfig sharedPHConfigure] weatherNeedGrowl])
    {
        growl.state = NSOnState;
    }
    else
    {
        growl.state = NSOffState;
    }
    // 自动桌面
    autosetWP.state = NSOffState;
    swifWP.state = NSOnState;
    [swifWP setEnabled:FALSE];
    
    if([[PHConfig sharedPHConfigure] weatherDownloadWP])
    {
        autosetWP.state = NSOnState;
        [swifWP setEnabled:TRUE];
    }
    if(![[PHConfig sharedPHConfigure] weatherSwifWP])
    {
        swifWP.state = NSOffState;
    }
    
    // 自动启动
    if([[PHConfig sharedPHConfigure] weatherLaunchAtLogin])
    {
        checkLogin.state = NSOnState;
    }
    else
    {
        checkLogin.state = NSOffState;
    }
}

// 打开设置面板
- (void)setAppPreferences
{
    [self.window center];
    [[self window] makeKeyAndOrderFront:nil];
}
// 打开壁纸长廊
- (void)openGallery
{
    PHImageGallery *phig = [[PHImageGallery alloc] initWithWindowNibName:@"PHImageGallery"];
    [phig.window display];
}

// 打开关于面板
- (void)showAppAboutPage
{
    [[NSApplication sharedApplication] orderFrontStandardAboutPanel:nil];
}

// 进入纸房子官方网站
- (void)openZHZWebSite
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://www.zhifangzi.com"]];
}

// 关闭纸房子
- (void)exitApp
{
    [[NSApplication sharedApplication] stop:nil];
}

// 开机启动或不启动app
-(IBAction) lanuchAtLogin:(id)sender
{
    NSButton *check =(NSButton *)sender;
    if(check.state == NSOnState)
    {
        NSLog(@"ns on");
        [PHTool addAppAsLoginItem];
        [[PHConfig sharedPHConfigure] setLaunchAtLogin:@"YES"];
    }
    else
    {
         NSLog(@"ns off");
        [PHTool deleteAppFromLoginItem];
        [[PHConfig sharedPHConfigure] setLaunchAtLogin:@"NO"];
    }
    [[PHConfig sharedPHConfigure] saveConfigToFile];
}

// 是否下载封面壁纸，是否过滤不同分辨率壁纸
-(IBAction)autosetWallpaper:(id)sender
{
    NSButton *btn = (NSButton *)sender;
    if(btn.tag == 1)
    {
        if(autosetWP.state == NSOnState)
        {
            [[PHConfig sharedPHConfigure] setDownloadWP:@"YES"];
            [swifWP setEnabled:TRUE];
        }
        else
        {
            [[PHConfig sharedPHConfigure] setDownloadWP:@"NO"];
            [swifWP setEnabled:FALSE];
        }
        
    }
    else if(btn.tag == 2)
    {
        if(swifWP.state == NSOnState)
        {
            [[PHConfig sharedPHConfigure] setSwifWP:@"YES"];
        }
        else
        {
            [[PHConfig sharedPHConfigure] setSwifWP:@"NO"];
        }
    }
    [[PHConfig sharedPHConfigure] saveConfigToFile];
}

// growl提示切换操作
-(IBAction)needGrowl:(id)sender
{
    if(growl.state == NSOnState)
    {
        [[PHConfig sharedPHConfigure] setNeedGrowl:@"YES"];
    }
    else
    {
        [[PHConfig sharedPHConfigure] setNeedGrowl:@"NO"];
    }
    [[PHConfig sharedPHConfigure] saveConfigToFile];
}

// 并根据判断设置存储路径
-(IBAction)wpDirectory:(id)sender
{
    NSMatrix *matrix = (NSMatrix *)sender;
    NSInteger selectedRow = [matrix selectedRow];
    if (selectedRow == 0) 
    {
        [[PHConfig sharedPHConfigure] setWpDirectory:@"~/Pictures/纸房子宽屏壁纸"];
        [[PHConfig sharedPHConfigure] saveConfigToFile];
    }
    else if(selectedRow == 1)
    {
        if (![@"" isEqualToString:[selfPath stringValue]]) 
        {
            [[PHConfig sharedPHConfigure] setWpDirectory:[selfPath stringValue]];
            [[PHConfig sharedPHConfigure] saveConfigToFile];
        }
    }
}


// 路径选择，并根据判断设置存储路径
-(IBAction)selectedPath:(id)sender
{
    NSOpenPanel *pathSelector = [NSOpenPanel openPanel];
    [pathSelector setCanChooseFiles:FALSE];
    [pathSelector setCanChooseDirectories:TRUE];
    [pathSelector setCanCreateDirectories:TRUE];
    [pathSelector setAllowsMultipleSelection:FALSE];
    [pathSelector setDirectoryURL:[NSURL fileURLWithPath:NSHomeDirectory()]];
    
    [pathSelector setTitle:NSLocalizedString(@"func_dir", nil)];
    NSInteger i = [pathSelector runModal];
    
    if(i == NSOKButton)
    {
        NSURL *theFilePath = [[pathSelector URLs] objectAtIndex:0];
        [selfPath setStringValue:[theFilePath path]];
        
        NSInteger r = [selfPathRadios selectedRow];
        if(r == 1)
        {
            [[PHConfig sharedPHConfigure] setWpDirectory:[theFilePath path]];
            [[PHConfig sharedPHConfigure] saveConfigToFile];
        }
    }
}

#pragma mark AppDelegate
- (void)applicationDidResignActive:(NSNotification *)aNotification
{
    if (self.popover && self.popover.isShown) {
        [self.popover close];
    }
}

#pragma mark -
#pragma mark NSPopoverDelegate
// -------------------------------------------------------------------------------
// Invoked on the delegate when the NSPopoverWillShowNotification notification is sent.
// This method will also be invoked on the popover.
// -------------------------------------------------------------------------------
- (void)popoverWillShow:(NSNotification *)notification
{
    self.menubarController.hasActiveIcon = YES;
}

// -------------------------------------------------------------------------------
// Invoked on the delegate when the NSPopoverDidCloseNotification notification is sent.
// This method will also be invoked on the popover.
// -------------------------------------------------------------------------------
- (void)popoverDidClose:(NSNotification *)notification
{
    self.menubarController.hasActiveIcon = NO;
    [self.popover release];
    self.popover = nil;
}

// -------------------------------------------------------------------------------
// Invoked on the delegate asked for the detachable window for the popover.
// -------------------------------------------------------------------------------

#pragma mark - Public accessors

- (PopupPanelController *)panelController
{
    if (_panelController  == nil) {
        _panelController  = [[PopupPanelController alloc] initWithDelegate:self];
        [self.panelController  addObserver:self forKeyPath:@"hasActivePanel" options:0 context:kContextActivePanel];
        //[self.panelController.backgroundView addSubview:self.powerMenuItemView.view];
    }
    return _panelController;
}

#pragma mark - PanelControllerDelegate

- (StatusItemView *)statusItemViewForPanelController:(PopupPanelController *)controller
{
    return self.menubarController.statusItemView;
}

#pragma mark NSMenuDelegate
-(void)menuWillOpen:(NSMenu *)menu
{
    self.menubarController.hasActiveIcon = YES;
}

-(void)menuDidClose:(NSMenu *)menu
{
    self.menubarController.hasActiveIcon = NO;
}

@end