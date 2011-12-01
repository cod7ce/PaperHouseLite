//
//  PHImageGallery.m
//  PaperHouseLite
//
//  Created by cod7ce on 11/18/11.
//  Copyright 2011 纸房子. All rights reserved.
//

#import "PHImageGallery.h"
#import "PHConfig.h"
#import "PHImageBrowserViewItem.h"
#import "ImageBrowserBackgroundLayer.h"
#import "PHTool.h"

@implementation PHImageGallery

@synthesize fileManager,imgArray,coverArray;

- (id)initWithWindowNibName:(NSString *)windowNibName
{
    NSLog(@"initWithWindowNibName");
    self = [super initWithWindowNibName:windowNibName];
    if (self) 
    {
        self.fileManager = [NSFileManager defaultManager];
    }
    return self;
}

-(void)windowDidLoad
{
    NSLog(@"windowDidLoad");
    [super windowDidLoad];
    [self toggleIndicator];
    NSString *dir = [[[PHConfig sharedPHConfigure] getPicPath] stringByExpandingTildeInPath];
    if([fileManager fileExistsAtPath:dir isDirectory:nil])
    {
        
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        self.imgArray   = [NSMutableArray array];
        self.coverArray = [NSMutableArray array];
        [self getAllWallpaper:dir];
        [pool release];
    }
    
    [browserView setDelegate:self];
    [browserView setDataSource:self];
    [browserView reloadData];
    
    [coverFlowView performSelectorOnMainThread:@selector(setContent:) withObject:coverArray waitUntilDone:NO];
    
    [self toggleIndicator];
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

// 初始化两种视图
- (void)awakeFromNib
{
    NSLog(@"awakeFromNib");
    /*************************************IKImageBrowserView*******************************************/
    
    ImageBrowserBackgroundLayer *backgroundLayer = [[[ImageBrowserBackgroundLayer alloc] init] autorelease];
	[browserView setBackgroundLayer:backgroundLayer];
	backgroundLayer.owner = browserView;
    
    [browserView setZoomValue:0.4];
    
    [browserView setCellsStyleMask:IKCellsStyleTitled | IKCellsStyleSubtitled | IKCellsStyleShadowed | IKCellsStyleOutlined];
    //-- change default font 
	// create a centered paragraph style
	NSMutableParagraphStyle *paraphStyle = [[[NSMutableParagraphStyle alloc] init] autorelease];
	[paraphStyle setLineBreakMode:NSLineBreakByTruncatingTail];
	[paraphStyle setAlignment:NSCenterTextAlignment];
	
	NSMutableDictionary *attributes = [[[NSMutableDictionary alloc] init] autorelease];	
	[attributes setObject:[NSFont titleBarFontOfSize:12] forKey:NSFontAttributeName]; 
	[attributes setObject:paraphStyle forKey:NSParagraphStyleAttributeName];	
	[attributes setObject:[NSColor blackColor] forKey:NSForegroundColorAttributeName];
	[browserView setValue:attributes forKey:IKImageBrowserCellsTitleAttributesKey];
	
	attributes = [[[NSMutableDictionary alloc] init] autorelease];	
	[attributes setObject:[NSFont boldSystemFontOfSize:12] forKey:NSFontAttributeName]; 
	[attributes setObject:paraphStyle forKey:NSParagraphStyleAttributeName];	
	[attributes setObject:[NSColor blackColor] forKey:NSForegroundColorAttributeName];
	
	[browserView setValue:attributes forKey:IKImageBrowserCellsHighlightedTitleAttributesKey];	
	
	//change intercell spacing
	[browserView setIntercellSpacing:NSMakeSize(20, 15)];
	
	//change selection color
	[browserView setValue:[NSColor colorWithCalibratedRed:1 green:0 blue:0.5 alpha:1.0] forKey:IKImageBrowserSelectionColorKey];
    [browserView setConstrainsToOriginalSize:YES];
    
    /*************************************IKImageBrowserView*******************************************/
    
    /*************************************CoverFlowView*******************************************/
    NSViewController *labelViewController = [[NSViewController alloc] initWithNibName:nil bundle:nil];
	NSTextField *label = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 10, 10)];
	[label setBordered:NO];
	[label setBezeled:NO];
	[label setEditable:NO];
	[label setSelectable:NO];
	[label setDrawsBackground:NO];
	[label setTextColor:[NSColor whiteColor]];
	[label setFont:[NSFont boldSystemFontOfSize:12.0]];
	[label setAutoresizingMask:NSViewWidthSizable];
	[label setAlignment:NSCenterTextAlignment];
	[label sizeToFit];
	NSRect labelFrame = [label frame];
	labelFrame.size.width = 400;
	[label setFrame:labelFrame];
	[labelViewController setView:label];
	[label bind:@"value" toObject:labelViewController withKeyPath:@"representedObject.name" options:nil];
	[label release];
	[coverFlowView setAccessoryController:labelViewController];
	[labelViewController release];
	
	[coverFlowView setImageKeyPath:@"image"];
	[coverFlowView setShowsScrollbar:NO];
	
	//[NSThread detachNewThreadSelector:@selector(loadImages) toTarget:self withObject:nil];
    /*************************************CoverFlowView*******************************************/
}

// IKImage的双击事件
- (void) imageBrowser:(IKImageBrowserView *) aBrowser cellWasDoubleClickedAtIndex:(NSUInteger) index
{
    PHImageBrowserViewItem * item = (PHImageBrowserViewItem *)[self.imgArray objectAtIndex:index];
    [PHTool setWallpaperWithPath:item.imagePath AndName:item.imageID];
}

// 获取所有的壁纸文件，并构造IKImageBrowserView和MBCoverFlowView所需的数据就够
- (void)getAllWallpaper:(NSString *)dir
{
    NSArray *dirArray = [fileManager contentsOfDirectoryAtPath:dir error:nil];
    BOOL isDir = NO;
    for (NSString *file in dirArray) 
    {
        NSString *path = [dir stringByAppendingPathComponent:file];
        [fileManager fileExistsAtPath:path isDirectory:(&isDir)];
        if (isDir) 
        {
            [self getAllWallpaper:path];
        }
        else
        {
            if ([self isImageExtend:path]) 
            {
                NSImage * image = [[NSImage alloc] initWithContentsOfFile:path];
                [image setSize:NSMakeSize(600.0, 375.0)];
                NSImageRep *imgObj = [NSImageRep imageRepWithContentsOfURL:[NSURL fileURLWithPath:path]];
                NSString * imageID = [path lastPathComponent];
                PHImageBrowserViewItem * item = [[PHImageBrowserViewItem alloc] initWithImage:image imageID:imageID];
                item.imagePath = path;
                item.size = [NSString stringWithFormat:@"%ld X %ld",imgObj.pixelsWide, imgObj.pixelsHigh];
                [imgArray addObject:item];
                
                NSDictionary *imageInfo = [NSDictionary dictionaryWithObjectsAndKeys:image, @"image", imageID, @"name", path, @"path", nil];
                [coverArray addObject:imageInfo];
                [item release];
            }
        }
        isDir = NO;    
    }
}

// 判断是否是壁纸（通过后缀判断）
-(BOOL)isImageExtend:(NSString *)path
{
    BOOL flag = NO;
    NSArray*  extends		= [[path lastPathComponent] componentsSeparatedByString:@"."];
    NSString* extend        = [extends objectAtIndex:[extends count] - 1];
    if([extend isEqualToString:@"jpg"] || [extend isEqualToString:@"png"] )
    {
        flag = YES;
    }
    return flag;
}

// 当视图为IKImageBrowserView时，zoom图片大小
- (IBAction)zoomSliderDidChange:(id)sender
{
	// update the zoom value to scale images
    [browserView setZoomValue:[sender floatValue]];
	
	// redisplay
    [browserView setNeedsDisplay:YES];
}

// 切换wallpaper gallery视图显示方式
- (IBAction)viewChange:(id)sender
{
    NSSegmentedControl *segment = (NSSegmentedControl *)sender;
    NSInteger tag = [segment selectedSegment];
    if(tag == 0)
    {
        [coverFlowView setHidden:TRUE];
        [self transformWindowToSize:NSMakeSize(970.0, 675.0)]; 
        [browserView setHidden:FALSE];
        [slider setEnabled:TRUE];
    }
    else if(tag == 1)
    {
        [browserView setHidden:TRUE];
        [slider setEnabled:FALSE];
        [self transformWindowToSize:NSMakeSize(720.0, 330.0)];        
        [coverFlowView setHidden:FALSE];
    }
}

// resize窗体到size的大小
- (void)transformWindowToSize:(NSSize)size
{
    NSRect rect = [owindow frame];
    rect.origin.y += rect.size.height;
    rect.origin.y -= size.height;
    rect.size.width = size.width;
    rect.size.height = size.height;
    [owindow setFrame:rect display:YES animate:YES];
}

// datasource   and   delegate
- (NSUInteger) numberOfItemsInImageBrowser:(IKImageBrowserView *) aBrowser
{
    return [self.imgArray count];
}

- (id) imageBrowser:(IKImageBrowserView *) aBrowser itemAtIndex:(NSUInteger)index
{
    return [self.imgArray objectAtIndex:index];
}

- (void)windowWillClose:(NSNotification *)notification
{
    [self dealloc];
}

-(void)dealloc
{
    NSLog(@"dealloc");
    [imgArray release];
    [coverArray release];
    [fileManager release];
    [super dealloc];
}

@end