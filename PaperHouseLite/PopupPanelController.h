#import "BackgroundView.h"
#import "StatusItemView.h"
#import "PowerMenuItemView.h"

@class PopupPanelController;

@protocol PopupPanelControllerDelegate <NSObject>

@optional

- (StatusItemView *)statusItemViewForPanelController:(PopupPanelController *)controller;

@end

#pragma mark -

@interface PopupPanelController : NSWindowController <NSWindowDelegate>
{
    BOOL _hasActivePanel;
    __unsafe_unretained BackgroundView *_backgroundView;
    __unsafe_unretained id<PopupPanelControllerDelegate> _delegate;
}

@property (nonatomic, unsafe_unretained) IBOutlet BackgroundView *backgroundView;
@property (assign) IBOutlet PowerMenuItemView *powerMenuItemViewController;

@property (nonatomic) BOOL hasActivePanel;
@property (nonatomic, unsafe_unretained, readonly) id<PopupPanelControllerDelegate> delegate;

- (id)initWithDelegate:(id<PopupPanelControllerDelegate>)delegate;

- (void)openPanel;
- (void)closePanel;

@end
