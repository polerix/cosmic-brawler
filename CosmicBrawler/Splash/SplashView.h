//
//  SlashView.h
//  CosmicBrawler
//
//  Created by polerix on 2025-05-18.
//

// SplashView.h
// CosmicBrawler

#import <Cocoa/Cocoa.h>

@interface SplashView : NSView

@property (nonatomic, copy) void (^onFinish)(void); // Called when splash timer ends

@end
