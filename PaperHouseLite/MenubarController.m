#import "MenubarController.h"
#import "StatusItemView.h"

@implementation MenubarController

@synthesize statusItemView = _statusItemView;

#pragma mark -

- (id)init
{
    self = [super init];
    if (self != nil)
    {
        // Install status item into the menu bar
        NSStatusItem *statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:STATUS_ITEM_VIEW_WIDTH];
        [statusItem retain];
        
        _statusItemView = [[StatusItemView alloc] initWithStatusItem:statusItem];
        NSImage *img = [NSImage imageNamed:@"wallpaper"];
        [img setSize:CGSizeMake(18, 16)];
        NSImage *aimg = [NSImage imageNamed:@"wallpaperh"];
        [aimg setSize:CGSizeMake(18, 16)];
        _statusItemView.image = img;
        _statusItemView.alternateImage = aimg;
        _statusItemView.action = @selector(togglePanel:);
        
    }
    return self;
}

- (void)dealloc
{
    NSLog(@"dealooc");
    [[NSStatusBar systemStatusBar] removeStatusItem:self.statusItem];
    [super dealloc];
}

#pragma mark -
#pragma mark Public accessors

- (NSStatusItem *)statusItem
{
    return self.statusItemView.statusItem;
}

#pragma mark -

- (BOOL)hasActiveIcon
{
    return self.statusItemView.isHighlighted;
}

- (void)setHasActiveIcon:(BOOL)flag
{
    self.statusItemView.isHighlighted = flag;
}

@end
