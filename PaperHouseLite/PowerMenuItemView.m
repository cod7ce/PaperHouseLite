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
#import "PHDocmentImage.h"
#import "HttpConnectionManager.h"


@implementation PowerMenuItemView

ElementName en;
Boolean itemFlag;
Boolean itemStartFlag;
Boolean mainThread;
NSString *fullTitle = @"";
NSString *fullDesc = @"";

@synthesize imageCell,comboBox,indicator;
@synthesize cellIndex,imageIndex,allImage,cellName;
@synthesize shareView;
//@synthesize set,download,fullView,prev,next;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        NSLog(@"初始化对象");
        self.cellIndex = 0;
        self.imageIndex = 0;
        allImage = [[NSMutableArray alloc] initWithCapacity:5000];
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    [GrowlApplicationBridge setGrowlDelegate:self];
	[GrowlApplicationBridge reregisterGrowlNotifications];
    [imageCell setTrackingRect:imageCell.frame];
    [shareView setAlphaValue:0.0f];
    [imageCell setShareView:shareView];
    NSLog(@"加载数据");
    // 打开一个新的线程去执行数据的获取
    [NSThread detachNewThreadSelector:@selector(getDataWithNewThread) toTarget:self withObject:nil];
    
}

// 当数据加载时，menu打开就执行waitIndicator的效果
- (void)menuWillOpen:(NSMenu *)menu
{
    if (waitIndicator != NULL) 
    {
        [waitIndicator performSelector:@selector(startAnimation:)
                            withObject:self
                            afterDelay:0.0
                               inModes:[NSArray arrayWithObject:NSEventTrackingRunLoopMode]];
    }
}

// 在新的线程中获取数据，并结束线程
-(void)getDataWithNewThread
{
    mainThread = NO;
    [PHTool getConfigWithURL:[[PHConfig sharedPHConfigure] getFeed] XMLDeletgate:self];
    mainThread = YES;
    [NSThread exit];
}

// 通过传入参数设置等待indicator的状态
-(void) toggleIndicator
{
    if(mainThread == YES)
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
    
}
// 设置成桌面
-(IBAction) setWallPaper:(id)sender
{
    if([PHTool checkPicturePathWithCellName:cellName])
    {
        [self toggleIndicator];
        PHDocmentImage *img = [[allImage objectAtIndex:cellIndex] objectAtIndex:imageIndex];
        NSString* imageURL = [img fullImageSrc];        
        NSString *saveFileURL = [self getFileNameURLWithImageSrc:imageURL];
        if(![[NSFileManager defaultManager] fileExistsAtPath:saveFileURL])
        {
            NSData* imageData = [HttpConnectionManager sync_doGet:[imageURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
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
        NSURL* localImageURL	= [NSURL fileURLWithPath:saveFileURL];
        NSError *error = nil;
        [[NSWorkspace sharedWorkspace] setDesktopImageURL:localImageURL forScreen:[NSScreen mainScreen] options:nil error:&error];
        [self toggleIndicator];
        if([[PHConfig sharedPHConfigure] weatherNeedGrowl])
        {
            NSArray*  strs			= [imageURL componentsSeparatedByString:@"/"];
            NSString* fname         = [strs objectAtIndex:[strs count] - 1];
            [GrowlApplicationBridge notifyWithTitle:NSLocalizedString(@"notify_wall", nil)
                                        description:[NSString stringWithFormat: @"%@%@", NSLocalizedString(@"notify_set", nil), fname]
                                   notificationName:@"StandardReminder"
                                           iconData:nil
                                           priority:1
                                           isSticky:NO
                                       clickContext:@"test"];
        }
    }
}

// 获取图片的存储位置
-(NSString *) getFileNameURLWithImageSrc:(NSString *)imageSrc
{
    NSArray*  strs			= [imageSrc componentsSeparatedByString:@"/"];
    NSString* fname         = [strs objectAtIndex:[strs count] - 1];
    
    NSString* saveFileURL   = [[NSString stringWithFormat:@"%@/%@/%@", [[PHConfig sharedPHConfigure] getPicPath],cellName,fname] stringByExpandingTildeInPath];
    return saveFileURL;
}

// 存储壁纸
-(IBAction) saveFullImage:(id)sender
{
    
    if([PHTool checkPicturePathWithCellName:cellName])
    {
        [self toggleIndicator];
        PHDocmentImage *img = [[allImage objectAtIndex:cellIndex] objectAtIndex:imageIndex];
        NSString* imageURL = [img fullImageSrc];        
        NSString *saveFileURL = [self getFileNameURLWithImageSrc:imageURL];
        
        if(![[NSFileManager defaultManager] fileExistsAtPath:saveFileURL])
        {
            NSData* imageData = [HttpConnectionManager sync_doGet:[imageURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
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
        if([[PHConfig sharedPHConfigure] weatherNeedGrowl])
        {
            NSArray*  strs			= [imageURL componentsSeparatedByString:@"/"];
            NSString* fname         = [strs objectAtIndex:[strs count] - 1];
            [GrowlApplicationBridge notifyWithTitle:NSLocalizedString(@"notify_succ", nil)
                                        description:[NSString stringWithFormat: @"%@%@", NSLocalizedString(@"notify_save", nil), fname]
                                   notificationName:@"StandardReminder"
                                           iconData:nil
                                           priority:1
                                           isSticky:NO
                                       clickContext:@"test"];
        }
        
        [self toggleIndicator];
    }
}

// 查看大图
-(IBAction) suffFullImage:(id)sender
{
    PHDocmentImage *img = [[allImage objectAtIndex:cellIndex] objectAtIndex:imageIndex];
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:img.originalImageSrc]];
}

// 上一张图片
-(IBAction) prevImage:(id)sender
{
    [self toggleIndicator];
    NSUInteger prevImageIndex = 0;
    NSArray *array = [allImage objectAtIndex:self.cellIndex];
    if (imageIndex==0) {
        prevImageIndex = array.count-1;
    }else{
        prevImageIndex = imageIndex-1;
    }
    [self setImageCellWithCellIndex:cellIndex AndImageIndex:prevImageIndex];
    [self toggleIndicator];
}

// 下一张图片
-(IBAction) nextImage:(id)sender
{
    [self toggleIndicator];
    NSUInteger nextImageIndex = imageIndex+1;;
    NSArray *array = [allImage objectAtIndex:self.cellIndex];
    if(nextImageIndex >= array.count)
    {
        nextImageIndex = 0;
    }
    [self setImageCellWithCellIndex:cellIndex AndImageIndex:nextImageIndex];
    [self toggleIndicator];
}

// 通过图片索引设置图片
-(void) setImageCellWithCellIndex:(NSUInteger)index1 AndImageIndex:(NSUInteger)index2
{
    PHDocmentImage *img = [[allImage objectAtIndex:index1] objectAtIndex:index2];
    NSURL *url = [NSURL URLWithString: [img.smallImageSrc stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSImage *imgs = [[NSImage alloc] initWithContentsOfURL:url];
    [imageCell setImage:imgs];
    [imgs release];
    imageIndex = index2;
}

// 通过

// combobox更改选项，更换专辑索引，重置图片索引，重绘imageview
- (void)comboBoxSelectionDidChange:(NSNotification *)notification
{
    [self toggleIndicator];
    cellIndex = [comboBox indexOfSelectedItem];
    cellName  = [comboBox objectValueOfSelectedItem];
    imageIndex = 0;
    [self setImageCellWithCellIndex:cellIndex AndImageIndex:imageIndex];
    [self toggleIndicator];
}

// 分享按钮的动作，构造链接并打开分享
-(IBAction) shareSNSAction:(id)sender
{
    if (![@"" isEqualToString:cellName]) 
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
        PHDocmentImage *img = [[allImage objectAtIndex:cellIndex] objectAtIndex:imageIndex];
        [PHTool shareImageWithDocumentImage:img Title:cellName Type:shareType];
    } 
}

// delegate
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

// menuitem的resize
-(void)changeShareViewSize
{
    NSRect rect = [shareView frame];
    rect.origin.y += rect.size.height;
    rect.origin.y -= 158.0;
    rect.size.height = 158.0;
    rect.size.width  = 304.0;
    [[shareView animator] setFrame:rect];
    [[self.view animator] setFrame:rect];
}


// 注册growl的展示方法
- (NSDictionary *) registrationDictionaryForGrowl
{
	NSArray *notifications = [NSArray arrayWithObject: @"StandardReminder"];
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
						  notifications, GROWL_NOTIFICATIONS_ALL,
						  notifications, GROWL_NOTIFICATIONS_DEFAULT, nil];
	
	return dict;
}

@end
