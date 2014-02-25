//
//  PowerMenuItemView.m
//  PaperHouseLite
//
//  Created by cod7ce on 10/28/11.
//  Copyright 2011 纸房子. All rights reserved.
//

#import "PowerMenuItemView.h"
#import "PHConfig.h"
#import "PHTool.h"
#import "HttpConnectionManager.h"


@implementation PowerMenuItemView

@synthesize imageCell,indicator;
@synthesize page,count;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        NSLog(@"初始化对象");
        self.page = 1;
        self.count = 1;
        self.documentImage = [[PHDocmentImage alloc] init];
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    if(![[PHConfig sharedPHConfigure] weatherFirstLaunch])
    {
        [self.helpNaviButton removeFromSuperview];
    }
    else
    {
        [[PHConfig sharedPHConfigure] sayByeByeForFirstLaunch];
    }
    [imageCell setTrackingRect:imageCell.frame];
    [self.toolView setAlphaValue:0.0f];
    imageCell.toolView = self.toolView;
    [self.imageCell setImageFrameStyle:NSImageFrameNone];
    NSLog(@"加载数据");
    
    [self getWallpaper:1];
}

-(void)getWallpaper:(NSInteger)cpage
{
    [self toggleIndicator];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?page=%ld", [[PHConfig sharedPHConfigure] getFeedStr], cpage]];
    NSLog(@"%@", [NSString stringWithFormat:@"%@?page=%ld", [[PHConfig sharedPHConfigure] getFeedStr], cpage]);
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL: url];
    [request setRequestMethod:@"Get"];
    request.delegate = self;
    [request startAsynchronous];
    request = nil;
}

// 通过传入参数设置等待indicator的状态
-(void) toggleIndicator
{
    if([indicator isHidden])
    {
        [indicator setHidden:FALSE];
        [indicator startAnimation:nil];
    }
    else
    {
        [indicator stopAnimation:nil];
        [indicator setHidden:TRUE];
    }
}
// 设置成桌面
-(IBAction) setWallPaper:(id)sender
{
    [self saveFullImage:nil];
    
    NSString *saveFileURL = [PHTool getFileNameURLWithDocumentImage:self.documentImage];
    NSURL* localImageURL	= [NSURL fileURLWithPath:saveFileURL];
    NSError *error = nil;
    [[NSWorkspace sharedWorkspace] setDesktopImageURL:localImageURL forScreen:[NSScreen mainScreen] options:nil error:&error];
    // 加入通知中心
}

// 存储壁纸
-(IBAction) saveFullImage:(id)sender
{
    
    if([PHTool checkPicturePath])
    {
        [self toggleIndicator];
        NSString *saveFileURL = [PHTool getFileNameURLWithDocumentImage:self.documentImage];
        if(![[NSFileManager defaultManager] fileExistsAtPath:saveFileURL])
        {
            NSData* imageData = [HttpConnectionManager sync_doGet:[self.documentImage.url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            if(imageData)
            {
                 NSLog(@"获取壁纸成功");
                if([imageData writeToFile:saveFileURL atomically:YES])
                {
                    NSLog(@"保存壁纸文件成功！");
                }
                else
                {
                    NSLog(@"保存壁纸文件失败！");
                }
            }
            else
            {
                NSLog(@"获取壁纸失败");
            }
        }
        else
        {
            NSLog(@"保存壁纸文件成功！");
        }
        
        [self toggleIndicator];
    }
}

// 查看大图
-(IBAction) suffFullImage:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:self.documentImage.copyright]];
}

// 上一张图片
-(IBAction) prevImage:(id)sender
{
    NSInteger cpage = self.page == 1 ? self.count : self.page - 1;
    [self getWallpaper:cpage];
}

// 下一张图片
-(IBAction) nextImage:(id)sender
{
    NSInteger cpage = self.page == self.count ? 1 : self.page + 1;
    [self getWallpaper:cpage];
}

// 分享按钮的动作，构造链接并打开分享
-(IBAction) shareSNSAction:(id)sender
{
    NSButton *tempBtn = (NSButton *)sender;
    NSInteger tag = tempBtn.tag;
    ShareType shareType = sina;
    if(tag == 2)
    {
        shareType = renren;
    }
    else if(tag == 3)
    {
        shareType = tencent;
    }
    else if(tag == 4)
    {
        shareType = douban;
    }
    else if(tag == 5)
    {
        shareType = kaixin;
    }
    else if(tag == 6)
    {
        shareType = net163;
    }
    [PHTool shareImageWithDocumentImage:self.documentImage Type:shareType];
}

- (IBAction)howToUseAction:(id)sender
{
    [sender removeFromSuperview];
}

#pragma mark - ASIHttpRequestDelegate
- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSError *error;
    NSData *responseData = [request responseData];
    NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseData
                                                           options:NSJSONReadingMutableLeaves
                                                             error:&error];
    if (result)
    {
        self.page = [[result objectForKey:@"page"] integerValue];
        self.count = [[result objectForKey:@"count"] integerValue];
        [self.documentImage setProperties:[result objectForKey:@"wallpaper"]];
        // 打开一个新的线程去执行数据的获取
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_queue_t mainQueue = dispatch_get_main_queue();
        dispatch_async(queue, ^{
            NSURL *url = [NSURL URLWithString: [self.documentImage.thumbnailUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            NSImage *img = [[NSImage alloc] initWithContentsOfURL:url];
            dispatch_sync(mainQueue, ^{
                [self.imageCell setImage:img];
                [self.authorLabel setStringValue:[NSString stringWithFormat:@"作品来自：%@", self.documentImage.author]];
                [self changeShareViewSize];
                [self toggleIndicator];
                [img release];
            });
        });
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    [self toggleIndicator];
    NSLog(@"数据获取错误,%@", request.error);
}

// delegate
/*
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
    itemStartFlag = TRUE;
    if([@"item" isEqualToString:elementName])
    {
        en = Item;
        itemFlag = TRUE;
    }
    else if ([@"title" isEqualToString:elementName])
    {
        en = Title;
    }
    else if ([@"content:encoded" isEqualToString:elementName])
    {
        en = Description;
    }
    else
    {
        en = NoUse;
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if (itemStartFlag) 
    {
        if(en == Title && itemFlag)
        {
            fullTitle = [fullTitle stringByAppendingString:string];
        }
        else if(en == Description)
        {
            fullDesc = [fullDesc stringByAppendingString:string];
        }
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    itemStartFlag = FALSE;
    if (itemFlag) 
    {
        if([@"title" isEqualToString:elementName])
        {
            [comboBox addItemWithObjectValue:fullTitle];
            fullTitle = @"";
        }
        else if([@"content:encoded" isEqualToString:elementName])
        {
            [allImage addObject:[PHTool parseToDocumentImageWithDesc:fullDesc]];
            fullDesc = @"";
        }
    }
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    NSLog(@"xml数据正则解析");
    [comboBox selectItemAtIndex:0];
    //[self setImageCellWithCellIndex:cellIndex AndImageIndex:imageIndex];
    if([[PHConfig sharedPHConfigure] weatherDownloadWP])
    {
        if([PHTool checkPicturePathWithCellName:cellName])
        {
            PHDocmentImage *img = [[allImage objectAtIndex:cellIndex] objectAtIndex:imageIndex];
            NSString* imageURL = [img fullImageSrc];        
            NSString *saveFileURL = [self getFileNameURLWithImageSrc:imageURL];
            if(![[NSFileManager defaultManager] fileExistsAtPath:saveFileURL])
            {
                NSData* imageData = [HttpConnectionManager sync_doGet:[imageURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                if(imageData)
                {
                    if([imageData writeToFile:saveFileURL atomically:YES])
                    {
                        NSLog(@"保存壁纸文件成功！");
                        NSScreen *screen = [NSScreen mainScreen];
                        NSImageRep *imgObj = [NSImageRep imageRepWithContentsOfURL:[NSURL fileURLWithPath:saveFileURL]];
                        bool flag = TRUE;
                        if([[PHConfig sharedPHConfigure] weatherSwifWP])
                        {
                            NSLog(@"weatherSwifWp");
                            if(!([imgObj pixelsWide] >= screen.frame.size.width && [imgObj pixelsHigh] >= screen.frame.size.height))
                            {
                                flag = FALSE;
                            }
                        }
                        if(flag)
                        {
                            NSURL* localImageURL	= [NSURL fileURLWithPath:saveFileURL];
                            NSError *error = nil;
                            [[NSWorkspace sharedWorkspace] setDesktopImageURL:localImageURL forScreen:[NSScreen mainScreen] options:nil error:&error];
                        }
                    }
                }
            }
        }
    }
    if([[PHConfig sharedPHConfigure] weatherNeedGrowl])
    {
        [GrowlApplicationBridge notifyWithTitle:NSLocalizedString(@"notify_get", nil)
                                    description:NSLocalizedString(@"notify_icon", nil)
                               notificationName:@"StandardReminder"
                                       iconData:nil
                                       priority:1
                                       isSticky:NO
                                   clickContext:@"test"];
    }
    
    // 隐藏等待视图层，注销waitIndicator，从主视图中删等待图层
    [[waitView animator] setAlphaValue:0.0];
    waitIndicator = NULL;
    [waitView removeFromSuperview];
    
    // 调回主线程执行menuitem的resize
    [self performSelectorOnMainThread:@selector(changeShareViewSize) withObject:nil waitUntilDone:NO];
}
*/
// menuitem的resize
-(void)changeShareViewSize
{
    
}

@end
