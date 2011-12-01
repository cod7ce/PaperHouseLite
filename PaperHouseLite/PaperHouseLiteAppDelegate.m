//
//  PaperHouseLiteAppDelegate.m
//  PaperHouseLite
//
//  Created by cod7ce on 11-10-26.
//  Copyright 2011年 纸房子. All rights reserved.
//

#import "PaperHouseLiteAppDelegate.h"
#import "PowerMenuItemView.h"
#import "PHImageGallery.h"
#import "PHConfig.h"
#import "PHTool.h"

@implementation PaperHouseLiteAppDelegate

@synthesize window, theItem;
@synthesize checkLogin,autosetWP,swifWP,selfPath,selfPathRadios,checkUpdateItem,growl;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    if([[PHConfig sharedPHConfigure] weatherFirstLaunch])
    {
        [PHTool addAppAsLoginItem];
        [[PHConfig sharedPHConfigure] sayByeByeForFirstLaunch];
    }
    [self initPreferencePenalWithConfigFile];
    [self activateStatusMenu];
}

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

// 初始化状态memu
- (void)activateStatusMenu
{
    NSStatusBar *bar = [NSStatusBar systemStatusBar];
    
    theItem = [bar statusItemWithLength:NSVariableStatusItemLength];
    [theItem retain];
    
    NSImage *menuImg = [NSImage imageNamed:@"home.png"];
    [menuImg setSize: NSMakeSize(22.0, 22.0) ];
    [theItem setImage:menuImg];
    [theItem setHighlightMode:YES];
    NSMenu *theMenu = [[NSMenu alloc] initWithTitle:@"nihao"];
    
    //* 菜单元素对象，add后release
	NSMenuItem *menuItem;
    
    menuItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"about", nil) action:@selector(showAppAboutPage) keyEquivalent:@""];
    menuItem.tag = 1;
    [theMenu addItem:menuItem];
    [menuItem release];
    
    
    menuItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"home", nil) action:@selector(openZHZWebSite) keyEquivalent:@"a"];
    menuItem.tag = 3;
    [theMenu addItem:menuItem];
    [menuItem release];

    
    [theMenu addItem:[NSMenuItem separatorItem]];
    
    menuItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Preferences", nil) action:@selector(setAppPreferences) keyEquivalent:@","];
    menuItem.tag = 2;
    [theMenu addItem:menuItem];
    [menuItem release];
    
    [theMenu addItem:checkUpdateItem];
    
    [theMenu addItem:[NSMenuItem separatorItem]];
    /*
    menuItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"gallery", nil) action:@selector(openGallery) keyEquivalent:@"g"];
    menuItem.tag = 2;
    [theMenu addItem:menuItem];
    [menuItem release];
       
    [theMenu addItem:[NSMenuItem separatorItem]];
    */
	menuItem = [[NSMenuItem alloc] init];
    PowerMenuItemView *pmi = [[PowerMenuItemView alloc] initWithNibName:@"PowerMenuItemView" bundle:nil];
    menuItem.view = pmi.view;
    [theMenu setDelegate:pmi];
    
	[theMenu addItem:menuItem];
    [menuItem release];
    
    
    [theMenu addItem:[NSMenuItem separatorItem]];
    
    
    
    menuItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"exit", nil) action:@selector(exitApp) keyEquivalent:@"q"];
    menuItem.tag = 5;
    [theMenu addItem:menuItem];
    [menuItem release];
    
    //*/
    [theItem setMenu:theMenu];
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

@end