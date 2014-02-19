//
//  PHConfig.h
//  PaperHouseLite
//
//  Created by cod7ce on 10/31/11.
//  Copyright 2011 纸房子. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PowerMenuItemView.h"

@interface PHConfig : NSObject
{
	NSDictionary *config;
    
    NSString *firstLaunch;
    NSString *launchAtLogin;
    NSString *swifWP;
    NSString *needGrowl;
    NSString *downloadWP;
    NSString *wpDirectory;
    NSString *dataURL;
}

@property (nonatomic, retain) NSDictionary *config;

@property (nonatomic, retain) NSString *firstLaunch;
@property (nonatomic, retain) NSString *launchAtLogin;
@property (nonatomic, retain) NSString *swifWP;
@property (nonatomic, retain) NSString *needGrowl;
@property (nonatomic, retain) NSString *downloadWP;
@property (nonatomic, retain) NSString *wpDirectory;
@property (nonatomic, retain) NSString *dataURL;

+(PHConfig *)sharedPHConfigure;

- (void)initProporty;

-(NSURL *)getFeed;
-(NSString *)getFeedStr;
-(NSString *)getPicPath;
-(bool)weatherDefaultWPDirectory;
-(bool)weatherLaunchAtLogin;
-(bool)weatherNeedGrowl;
-(bool)weatherFirstLaunch;
-(bool)weatherDownloadWP;
-(bool)weatherSwifWP;
-(void)sayByeByeForFirstLaunch;
-(void)saveConfigToFile;

@end
