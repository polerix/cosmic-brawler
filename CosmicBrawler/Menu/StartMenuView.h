//
//  StartMenuView.h
//  CosmicBrawler
//
//  Created by polerix on 2025-05-18.
//

#import <Cocoa/Cocoa.h>

@class StartMenuView;

@protocol StartMenuDelegate <NSObject>
- (void)startMenuDidRequestStartGame:(StartMenuView *)menu;
@end

@interface StartMenuView : NSView

@property (nonatomic, weak) id<StartMenuDelegate> delegate;

@end
