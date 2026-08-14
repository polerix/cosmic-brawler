//
//  AppDelegate.h
//  CosmicBrawler
//
//  Created by polerix on 2025-05-17.
//

#import <Cocoa/Cocoa.h>
#import "GameView.h"
#import "LeaderboardView.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, GameViewDelegate, InitialsEntryViewDelegate, LeaderboardViewDelegate>
@property (nonatomic, strong) NSDictionary* pulpColors;
@end
