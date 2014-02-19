//
//  PHTool.m
//  PaperHouseLite
//
//  Created by cod7ce on 10/31/11.
//  Copyright 2011 纸房子. All rights reserved.
//

#import "PHTool.h"
#import "RegexKitLite.h"
#import "PHConfig.h"
#import "JSON.h"

@implementation PHTool

// 获取xml内容，并将代理提交给本类
+(void)getConfigWithURL:(NSURL *)url XMLDeletgate:(PowerMenuItemView *)xmlDelegate
{
	
	NSData *xmlData = [NSData dataWithContentsOfURL:url];
                       
	NSXMLParser *parser = [[NSXMLParser alloc] initWithData:xmlData];
	[parser setDelegate:xmlDelegate];
	
	[parser parse];
	
	[parser release];
}

// 解析参数样式：<a href="a"><img src="c" /></a> ... <a href="..."><img src="..." /></a>
// 将a、b提取出来，通过b构造c，c为fullimagesrc
// 返回 PHDocumentImage 的对象数组
+(NSMutableArray *)parseToDocumentImageWithDesc:(NSString *)desc
{
    NSMutableArray *returnArray = [NSMutableArray arrayWithCapacity:500];
    NSString *regex = @"<a[^>]href=[^>]+target=\"_blank\"><img[^>]+src=\"[^>]+\"[^>]+><\\/a>";
    
    NSArray *matchArray = [desc componentsMatchedByRegex:regex];
    for (int i=0; i < matchArray.count; i++) 
    {
        NSString *subRegex = @"http:\\/\\/[^>]+(jpg|png|target)";
        NSArray *subMatchArray = [[matchArray objectAtIndex:i] componentsMatchedByRegex:subRegex];
        
        NSString *original = [subMatchArray objectAtIndex:0];
        NSString *small = [subMatchArray objectAtIndex:1];
        
        original = [original stringByReplacingOccurrencesOfRegex:@" target" withString:@""];
        NSString *full =  [small stringByReplacingOccurrencesOfRegex:@"-180x120" withString:@""];
        PHDocmentImage *phdi = [[PHDocmentImage alloc] initWithFullImageSrc:full 
                                                              SmallImageSrc:small 
                                                           OriginalImageSrc:original];
        [returnArray addObject:phdi];
        [phdi release];
    } 
    return returnArray;
}


// 检查图片存放目录是否存在，没有则创建
+(BOOL)checkPicturePath
{
    BOOL flag = TRUE;
    if(![[NSFileManager defaultManager] createDirectoryAtPath:[[[PHConfig sharedPHConfigure] getPicPath] stringByExpandingTildeInPath]
                                  withIntermediateDirectories:YES 
                                                   attributes:nil 
                                                        error:nil])
        {
            flag = FALSE;
        }
    return flag;
        
}

// 获取图片的存储位置
+(NSString *) getFileNameURLWithDocumentImage:(PHDocmentImage *)documentImage
{
    NSArray*  strs			= [documentImage.url componentsSeparatedByString:@"/"];
    NSString* fname         = [strs objectAtIndex:[strs count] - 1];
    NSArray*  fstrs			= [fname componentsSeparatedByString:@"."];
    NSString* extend         = [fstrs objectAtIndex:[fstrs count] - 1];
    
    NSString* saveFileURL   = [[NSString stringWithFormat:@"%@/%@.%@", [[PHConfig sharedPHConfigure] getPicPath], documentImage.name, extend] stringByExpandingTildeInPath];
    return saveFileURL;
}

// 将项目添加到启动项里
+(void)addAppAsLoginItem
{
    //获取程序的路径
    // 比如, /Applications/test.app
    NSString *appPath = [[NSBundle mainBundle] bundlePath];
 
    // 创建路径的引用
    CFURLRef url = (CFURLRef)[NSURL fileURLWithPath:appPath];
    
    // 我们只为当前用户添加启动项,所以我们用kLSSharedFileListSessionLoginItems
    // 如果要为全部用户添加,则替换为kLSSharedFileListGlobalLoginItems

    LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL,kLSSharedFileListSessionLoginItems,NULL);
    if(loginItems)
    { 
        //将项目插入启动表中.
        LSSharedFileListItemRef item = LSSharedFileListInsertItemURL(loginItems,kLSSharedFileListItemLast,NULL,NULL,url,NULL,NULL);
        if(item)
        {
            CFRelease(item);
        }
    } 
    CFRelease(loginItems);
}

+(void) deleteAppFromLoginItem
{
	NSString * appPath = [[NSBundle mainBundle] bundlePath];
    
	// This will retrieve the path for the application
	// For example, /Applications/test.app
	CFURLRef url = (CFURLRef)[NSURL fileURLWithPath:appPath]; 
    
	// Create a reference to the shared file list.
	LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
	if (loginItems) 
    {
        NSLog(@"获取到启动列表");
		UInt32 seedValue;
		//Retrieve the list of Login Items and cast them to
		// a NSArray so that it will be easier to iterate.
		NSArray  *loginItemsArray = (NSArray *)LSSharedFileListCopySnapshot(loginItems, &seedValue);
		for(id itemRef in loginItemsArray)
        {
			//Resolve the item with URL
			if (LSSharedFileListItemResolve((LSSharedFileListItemRef)itemRef, 0, (CFURLRef*) &url, NULL) == noErr) 
            {
				NSString * urlPath = [(NSURL*)url path];
				if ([urlPath compare:appPath] == NSOrderedSame)
                {
					LSSharedFileListItemRemove(loginItems,(LSSharedFileListItemRef)itemRef);
				}
			}
		}
		[loginItemsArray release];
	}
}

+(void)downloadWPWithPath:(NSString *)path AndWeatherSwif:(bool)swif
{
    
}

// 通过action过去json数据所生成Dictoinary
+ (NSDictionary *)getDataWithURL:(NSString *)url
{	
	// 初始化請求
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];         
	// 設置URL
	[request setURL:[NSURL URLWithString:url]];
	// 設置HTTP方法
	[request setHTTPMethod:@"POST"];
	// 發送同步請求, 這裡得returnData就是返回得數據楽
	NSData *returnData = [NSURLConnection sendSynchronousRequest:request 
											   returningResponse:nil error:nil]; 
	// 釋放對象
	[request release];
	
	NSString *results = [[[NSString alloc] 
                          initWithBytes:[returnData bytes] 
                          length:[returnData length] 
                          encoding:NSUTF8StringEncoding] autorelease];
	NSLog(@"return string : %@",results);
	NSDictionary *josnResult = [results JSONValue];	
	return josnResult;
}

+(void)shareImageWithDocumentImage:(PHDocmentImage *)docImage Type:(ShareType)type
{
    NSString *link;
    NSString *url   = docImage.copyright;
    NSString *pic   = [docImage.url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *title = [docImage.name stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *site  = [@" - 房子宽屏壁纸[每天都有新壁纸，没有都有新心情]" stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *app   = [@"纸房子宽屏壁纸" stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    switch(type)
    {
        case sina:
            link = [NSString stringWithFormat:@"http://service.weibo.com/share/share.php?url=%@&appkey=1680648568&title=%@&pic=%@&ralateUid=2395175762",url,title,pic];
            break;
        case renren:
            link = [NSString stringWithFormat:@"http://widget.renren.com/dialog/feed?app_id=169572&name=%@&url=%@&image=%@&description=%@&redirect_uri=http://www.zhifangzi.com",title,url,pic,[title stringByAppendingString:site]];
            break;
        case tencent:
            link = [NSString stringWithFormat:@"http://v.t.qq.com/share/share.php?title=%@&site=http://www.zhifangzi.com&pic=%@&url=%@",title,pic,url];
            break;
        case douban:
            break;
        case kaixin:
            link = [NSString stringWithFormat:@"http://www.kaixin001.com/rest/records.php?content=%@&url=%@&starid=100018896&aid=100018896&style=11&pic=%@",[title stringByAppendingString:site],url,pic];
            break;
        case net163:
            link = [NSString stringWithFormat:@"http://t.163.com/article/user/checkLogin.do?source=%@&info=%@&images=%@",app,[[title stringByAppendingString:site] stringByAppendingString:url],pic];
            break;
        
    }
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:link]];
}

+(NSString *)getURLStringWithString:(NSString *)os
{
    //‘:’, ‘/’, ‘%’, ‘#’, ‘;’, and ‘@‘
    os = [os stringByReplacingOccurrencesOfRegex:@":" withString:@"%3A"];
    os = [os stringByReplacingOccurrencesOfRegex:@"/" withString:@"%2F"];
    os = [os stringByReplacingOccurrencesOfRegex:@"#" withString:@"%23"];
    os = [os stringByReplacingOccurrencesOfRegex:@";" withString:@"%3B"];
    os = [os stringByReplacingOccurrencesOfRegex:@"@" withString:@"%40"];
    return os;
}

+(void)setWallpaperWithPath:(NSString *)path AndName:(NSString *)name
{
    NSURL* localImageURL	= [NSURL fileURLWithPath:path];
    NSError *error = nil;
    [[NSWorkspace sharedWorkspace] setDesktopImageURL:localImageURL forScreen:[NSScreen mainScreen] options:nil error:&error];
    if([[PHConfig sharedPHConfigure] weatherNeedGrowl])
    {
        [GrowlApplicationBridge notifyWithTitle:NSLocalizedString(@"notify_wall", nil)
                                    description:[NSString stringWithFormat: @"%@%@", NSLocalizedString(@"notify_set", nil), name]
                               notificationName:@"StandardReminder"
                                       iconData:nil
                                       priority:1
                                       isSticky:NO
                                   clickContext:@"test"];
    }
}

@end
