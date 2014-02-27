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
        [self.circularIndicator setIndeterminate:NO];
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    
    // 是否显示帮助图层
    if(![[PHConfig sharedPHConfigure] weatherFirstLaunch]) {
        [self.helpNaviButton removeFromSuperview];
    } else {
        [[PHConfig sharedPHConfigure] sayByeByeForFirstLaunch];
    }
    
    // 设置鼠标经过出现的图层
    [imageCell setTrackingRect:imageCell.frame];
    [self.toolView setAlphaValue:0.0f];
    imageCell.toolView = self.toolView;
    [self.imageCell setImageFrameStyle:NSImageFrameNone];
    
    // 设置进度条图层，不可以在nib里直接hidden，否则没有动画
    [self.circularView setAlphaValue:0.0];
    
    
    // 加载数据
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

// 设置成桌面
-(IBAction) setWallPaper:(id)sender
{
    if([PHTool checkPicturePath])
    {
        NSString *saveFileURL = [PHTool getFileNameURLWithDocumentImage:self.documentImage];
        if(![[NSFileManager defaultManager] fileExistsAtPath:saveFileURL])
        {
            //NSData* imageData = [HttpConnectionManager sync_doGet:[self.documentImage.url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [[self.circularView animator] setAlphaValue:1.0];
                ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[self.documentImage.url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
                request.showAccurateProgress = YES;
                [request setDownloadProgressDelegate:self.circularIndicator];
                [request startSynchronous];
                NSData* imageData = [request responseData];
                //[self.circularIndicator removeFromSuperview];
                if(imageData)
                {
                    NSLog(@"获取壁纸成功");
                    if([imageData writeToFile:saveFileURL atomically:YES])
                    {
                        NSLog(@"保存壁纸文件成功！");
                        dispatch_sync(dispatch_get_main_queue(), ^{
                            [self setWallPaperOnMainScreen];
                        });
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
            });
        }
        else
        {
            NSLog(@"保存壁纸文件成功！");
            [self setWallPaperOnMainScreen];
        }
    }
    
    // 加入通知中心
}

-(void)setWallPaperOnMainScreen
{
    [[self.circularView animator] setAlphaValue:0.0];
    
    NSString *saveFileURL = [PHTool getFileNameURLWithDocumentImage:self.documentImage];
    NSURL* localImageURL	= [NSURL fileURLWithPath:saveFileURL];
    NSError *error = nil;
    [[NSWorkspace sharedWorkspace] setDesktopImageURL:localImageURL forScreen:[NSScreen mainScreen] options:nil error:&error];
}

// 查看大图
-(IBAction) suffFullImage:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:self.documentImage.copyright]];
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

// 使用帮助
- (IBAction)howToUseAction:(id)sender
{
    [sender removeFromSuperview];
}


// menuitem的resize
-(void)changeShareViewSize
{
    
}

@end
