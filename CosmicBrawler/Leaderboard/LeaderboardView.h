//
//  LeaderboardView.h
//  CosmicBrawler
//
//  Created by polerix on 2025-05-18.
//

#import <Cocoa/Cocoa.h>

@class LeaderboardView;
@class InitialsEntryView;

@protocol LeaderboardViewDelegate <NSObject>
- (void)leaderboardViewDidRequestReturnToMenu:(LeaderboardView *)view;
@end

@interface LeaderboardView : NSView
@property (nonatomic, weak) id<LeaderboardViewDelegate> delegate;
@property (nonatomic, copy) NSArray<NSDictionary *> *leaderboardEntries;
- (void)addScoreWithInitials:(NSString *)initials score:(NSInteger)score;
- (void)setLeaderboardEntries:(NSArray<NSDictionary *> *)entries;
@end


@protocol InitialsEntryViewDelegate <NSObject>
- (void)initialsEntryView:(InitialsEntryView *)view didEnterInitials:(NSString *)initials score:(NSInteger)score;
@end

@interface InitialsEntryView : NSView
@property (nonatomic, weak) id<InitialsEntryViewDelegate> delegate;
@property (nonatomic) NSInteger score;
@end
