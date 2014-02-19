//
//  PHConfig.m
//  PaperHouseLite
//
//  Created by cod7ce on 10/31/11.
//  Copyright 2011 纸房子. All rights reserved.
//

#import "PHConfig.h"

static PHConfig *sharedAC;

@implementation PHConfig

@synthesize config;

@synthesize  firstLaunch,launchAtLogin,swifWP,downloadWP,wpDirectory,dataURL,needGrowl;

// 单例模式
+(PHConfig *)sharedPHConfigure
{
	@synchronized(self){
		if (!sharedAC) {
			sharedAC = [[PHConfig alloc] init];
		}
		return sharedAC;
	}
}

// 初始化PHConfig
-(id)init
{
	self = [super init];
	if (self) {
		NSString *path	  = [[NSBundle mainBundle] pathForResource:@"configure" ofType:@"plist"];
		config            = [[NSDictionary alloc] initWithContentsOfFile:path];
        
        [self initProporty];
	}
	return self;
}

- (void)initProporty
{
    firstLaunch     = [self.config objectForKey:@"firstlanuch"];
    launchAtLogin   = [self.config objectForKey:@"lanuchatlogin"];
    swifWP          = [self.config objectForKey:@"siftwp"];
    downloadWP      = [self.config objectForKey:@"downloadwp"];
    wpDirectory     = [self.config objectForKey:@"wpdirectory"];
    dataURL         = [self.config objectForKey:@"dataurl"];
    needGrowl       = [self.config objectForKey:@"needgrowl"];
}

// 获取数据来源url
-(NSURL *)getFeed
{
    return [NSURL URLWithString:self.dataURL];
}

// 获取数据来源url
-(NSString *)getFeedStr
{
    return self.dataURL;
}

// 获取图片存放路径
-(NSString *)getPicPath
{
    return self.wpDirectory;
}

// 获取是默认的下载路径
-(bool)weatherDefaultWPDirectory
{
    BOOL flag = FALSE;
    if([@"~/Pictures/纸房子宽屏壁纸" isEqualToString:self.wpDirectory])
    {
        flag = TRUE;
    }
    return flag;
}

// 是否需要growl提示
-(bool)weatherNeedGrowl
{
    BOOL flag = FALSE;
    if([@"YES" isEqualToString:self.needGrowl])
    {
        flag = TRUE;
    }
    return flag;
}

// 获取是否软件需要自动下载并设置封面壁纸
-(bool)weatherDownloadWP
{
    BOOL flag = FALSE;
    if([@"YES" isEqualToString:self.downloadWP])
    {
        flag = TRUE;
    }
    return flag;
}

// 获取是否软件需要自动下载并设置封面壁纸
-(bool)weatherSwifWP
{
    BOOL flag = FALSE;
    if([@"YES" isEqualToString:self.swifWP])
    {
        flag = TRUE;
    }
    return flag;
}

// 获取是否软件需要登陆是启动
-(bool)weatherLaunchAtLogin
{
    BOOL flag = FALSE;
    if([@"YES" isEqualToString:self.launchAtLogin])
    {
        flag = TRUE;
    }
    return flag;
}

// 获取是否软件为第一次启动
-(bool)weatherFirstLaunch
{
    BOOL flag = FALSE;
    if([@"YES" isEqualToString:self.firstLaunch])
    {
        flag = TRUE;
    }
    return flag;
}

// 告别第一次启动
-(void)sayByeByeForFirstLaunch
{
    self.firstLaunch = @"NO";
    [self saveConfigToFile];
}

// 将配置写入文档
-(void)saveConfigToFile
{
    NSDictionary *configTemp = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:self.firstLaunch, self.launchAtLogin, self.swifWP, self.needGrowl, self.downloadWP, self.wpDirectory, self.dataURL, nil]
                                                             forKeys:[NSArray arrayWithObjects:@"firstlanuch", @"lanuchatlogin", @"siftwp", @"needgrowl", @"downloadwp", @"wpdirectory", @"dataurl", nil]];
    NSString *path	 = [[NSBundle mainBundle] pathForResource:@"configure" ofType:@"plist"];
    [configTemp writeToFile:path atomically:YES];
}

@end
