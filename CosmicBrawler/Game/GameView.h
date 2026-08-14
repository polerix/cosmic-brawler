//
//  GameView.h
//  CosmicBrawler
//
//  Created by polerix on 2025-05-17.
//

#import <Cocoa/Cocoa.h>

@class GameView;

@protocol GameViewDelegate <NSObject>
- (void)gameView:(GameView *)view didEndGameWithScore:(NSInteger)score;
- (void)gameViewDidEndGameWithScore:(NSInteger)score;
@end

@interface GameView : NSView

@property (nonatomic, weak) id<GameViewDelegate> delegate;

@end
