//
//  AppDelegate.m
//  CosmicBrawler
//
//  Created by polerix on 2025-05-17.
//

#import "AppDelegate.h"
#import "SplashView.h"
#import "StartMenuView.h"
#import "GameView.h"
#import "LeaderboardView.h"

@interface AppDelegate () <
    StartMenuDelegate,
    GameViewDelegate,
    LeaderboardViewDelegate,
    InitialsEntryViewDelegate
>
@property (strong) NSWindow *window;
@property (strong) NSView *currentView;

// Leaderboard data (shared between game and leaderboard)
@property (strong) NSMutableArray<NSDictionary *> *leaderboard;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [self setupMainMenu];
    self.pulpColors = @{
        @"pulp_black_dark" : [NSColor colorWithCalibratedRed:0.051 green:0.051 blue:0.051 alpha:1.0],
        @"pulp_black_mid" : [NSColor colorWithCalibratedRed:0.102 green:0.102 blue:0.102 alpha:1.0],
        @"pulp_black_light" : [NSColor colorWithCalibratedRed:0.200 green:0.200 blue:0.200 alpha:1.0],
        @"pulp_white_dark" : [NSColor colorWithCalibratedRed:0.910 green:0.878 blue:0.839 alpha:1.0],
        @"pulp_white_mid" : [NSColor colorWithCalibratedRed:1.000 green:0.973 blue:0.906 alpha:1.0],
        @"pulp_white_light" : [NSColor colorWithCalibratedRed:1.000 green:1.000 blue:1.000 alpha:1.0],
        @"pulp_red_dark" : [NSColor colorWithCalibratedRed:0.600 green:0.090 blue:0.090 alpha:1.0],
        @"pulp_red_mid" : [NSColor colorWithCalibratedRed:0.851 green:0.129 blue:0.129 alpha:1.0],
        @"pulp_red_light" : [NSColor colorWithCalibratedRed:1.000 green:0.298 blue:0.298 alpha:1.0],
        @"pulp_blue_dark" : [NSColor colorWithCalibratedRed:0.000 green:0.200 blue:0.400 alpha:1.0],
        @"pulp_blue_mid" : [NSColor colorWithCalibratedRed:0.000 green:0.341 blue:0.718 alpha:1.0],
        @"pulp_blue_light" : [NSColor colorWithCalibratedRed:0.298 green:0.533 blue:1.000 alpha:1.0],
        @"pulp_yellow_dark" : [NSColor colorWithCalibratedRed:0.761 green:0.690 blue:0.188 alpha:1.0],
        @"pulp_yellow_mid" : [NSColor colorWithCalibratedRed:0.949 green:0.847 blue:0.286 alpha:1.0],
        @"pulp_yellow_light" : [NSColor colorWithCalibratedRed:1.000 green:1.000 blue:0.600 alpha:1.0],
        @"pulp_green_dark" : [NSColor colorWithCalibratedRed:0.102 green:0.416 blue:0.173 alpha:1.0],
        @"pulp_green_mid" : [NSColor colorWithCalibratedRed:0.169 green:0.659 blue:0.290 alpha:1.0],
        @"pulp_green_light" : [NSColor colorWithCalibratedRed:0.400 green:0.800 blue:0.600 alpha:1.0],
        @"pulp_brown_dark" : [NSColor colorWithCalibratedRed:0.302 green:0.180 blue:0.078 alpha:1.0],
        @"pulp_brown_mid" : [NSColor colorWithCalibratedRed:0.471 green:0.267 blue:0.129 alpha:1.0],
        @"pulp_brown_light" : [NSColor colorWithCalibratedRed:0.627 green:0.322 blue:0.176 alpha:1.0],
        @"pulp_skin_dark" : [NSColor colorWithCalibratedRed:0.769 green:0.612 blue:0.478 alpha:1.0],
        @"pulp_skin_mid" : [NSColor colorWithCalibratedRed:0.953 green:0.776 blue:0.639 alpha:1.0],
        @"pulp_skin_light" : [NSColor colorWithCalibratedRed:1.000 green:0.855 blue:0.725 alpha:1.0],
        @"pulp_orange_dark" : [NSColor colorWithCalibratedRed:0.702 green:0.278 blue:0.075 alpha:1.0],
        @"pulp_orange_mid" : [NSColor colorWithCalibratedRed:0.914 green:0.455 blue:0.173 alpha:1.0],
        @"pulp_orange_light" : [NSColor colorWithCalibratedRed:1.000 green:0.647 blue:0.310 alpha:1.0],
        @"pulp_purple_dark" : [NSColor colorWithCalibratedRed:0.294 green:0.153 blue:0.294 alpha:1.0],
        @"pulp_purple_mid" : [NSColor colorWithCalibratedRed:0.431 green:0.231 blue:0.431 alpha:1.0],
        @"pulp_purple_light" : [NSColor colorWithCalibratedRed:0.651 green:0.298 blue:0.651 alpha:1.0],
    };

    // Create window
    self.window = [[NSWindow alloc] initWithContentRect:NSMakeRect(100, 100, 900, 700)
                                              styleMask:(NSWindowStyleMaskTitled |
                                                         NSWindowStyleMaskClosable |
                                                         NSWindowStyleMaskResizable)
                                                backing:NSBackingStoreBuffered
                                                  defer:NO];
    [self.window setTitle:@"Cosmic Brawler"];
    self.window.contentView.wantsLayer = NO;
    [self.window makeKeyAndOrderFront:nil];
    [NSApp activateIgnoringOtherApps:YES];

    self.leaderboard = [[[NSUserDefaults standardUserDefaults]
                         arrayForKey:@"cosmicbrawler.leaderboard"] mutableCopy] ?: [NSMutableArray array];

    [self showSplashView];
}

#pragma mark - Splash

- (void)showSplashView {
    SplashView *splash = [[SplashView alloc] initWithFrame:self.window.contentView.bounds];
    __weak typeof(self) weakSelf = self;
    splash.onFinish = ^{
        [weakSelf showStartMenu];
    };
    [self swapToView:splash];
}

#pragma mark - Start Menu

- (void)showStartMenu {
    StartMenuView *menu = [[StartMenuView alloc] initWithFrame:self.window.contentView.bounds];
    menu.delegate = self;
    [self swapToView:menu];
}

- (void)startMenuDidRequestStartGame:(StartMenuView *)view {
    [self showGameView];
}

#pragma mark - Game View

- (void)showGameView {
    GameView *game = [[GameView alloc] initWithFrame:self.window.contentView.bounds];
    game.delegate = self;
    [self swapToView:game];
}

- (void)gameView:(GameView *)view didEndGameWithScore:(NSInteger)score {
    NSAlert *initialsPrompt = [[NSAlert alloc] init];
    initialsPrompt.messageText = @"Enter Your Initials";
    initialsPrompt.informativeText = [NSString stringWithFormat:@"Score: %ld", (long)score];
    NSTextField *input = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 200, 24)];
    [initialsPrompt setAccessoryView:input];
    [initialsPrompt addButtonWithTitle:@"OK"];
    [initialsPrompt runModal];

    NSString *initials = [[input stringValue] uppercaseString];
    if (initials.length == 0) initials = @"???";
    [self.leaderboard addObject:@{@"name": initials, @"score": @(score)}];

    // Sort + trim
    [self.leaderboard sortUsingComparator:^NSComparisonResult(NSDictionary *a, NSDictionary *b) {
        return [b[@"score"] compare:a[@"score"]];
    }];
    while (self.leaderboard.count > 5) [self.leaderboard removeLastObject];

    [[NSUserDefaults standardUserDefaults] setObject:self.leaderboard
                                              forKey:@"cosmicbrawler.leaderboard"];

    [self showLeaderboard];
}

#pragma mark - Leaderboard

- (void)showLeaderboardWithInitials:(NSString *)initials score:(NSInteger)score {
    LeaderboardView *leaderboard = [[LeaderboardView alloc] initWithFrame:self.window.contentView.bounds];
    leaderboard.delegate = self;
    leaderboard.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    [leaderboard addScoreWithInitials:initials score:score];
    [self.window setContentView:leaderboard];
}

- (void)showLeaderboard {
    LeaderboardView *lb = [[LeaderboardView alloc] initWithFrame:self.window.contentView.bounds];
    lb.delegate = self;
    [lb setLeaderboardEntries:self.leaderboard];
    [self swapToView:lb];
}

#pragma mark - View Management

- (void)swapToView:(NSView *)newView {
    newView.frame = self.window.contentView.bounds;
    newView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    [self.window.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.window.contentView addSubview:newView];
    self.currentView = newView;
    [self.window makeFirstResponder:newView];
}

#pragma mark - Menu

- (void)setupMainMenu {
    NSMenu *mainMenu = [[NSMenu alloc] initWithTitle:@"MainMenu"];
    NSMenuItem *appMenuItem = [[NSMenuItem alloc] init];
    NSMenu *appMenu = [[NSMenu alloc] initWithTitle:@"Cosmic Brawler"];

    NSMenuItem *aboutItem = [[NSMenuItem alloc] initWithTitle:@"About Cosmic Brawler"
                                                        action:@selector(orderFrontStandardAboutPanel:)
                                                 keyEquivalent:@""];
    [appMenu addItem:aboutItem];
    [appMenu addItem:[NSMenuItem separatorItem]];
    NSMenuItem *quitItem = [[NSMenuItem alloc] initWithTitle:@"Quit"
                                                       action:@selector(terminate:)
                                                keyEquivalent:@"q"];
    [appMenu addItem:quitItem];

    [mainMenu addItem:appMenuItem];
    [mainMenu setSubmenu:appMenu forItem:appMenuItem];
    [NSApp setMainMenu:mainMenu];
}

- (BOOL)applicationSupportsSecureRestorableState:(NSApplication *)app {
    return NO;
}

#pragma mark - Leaderboard

- (void)gameViewDidEndGameWithScore:(NSInteger)score {
    NSLog(@"[AppDelegate] Game ended with score: %ld", (long)score);

    InitialsEntryView *entryView = [[InitialsEntryView alloc] initWithFrame:self.window.contentView.bounds];
    entryView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    entryView.delegate = self;
    entryView.score = score;

    [self.window setContentView:entryView];
}

- (void)initialsEntryView:(InitialsEntryView *)view didSubmitInitials:(NSString *)initials {
    LeaderboardView *leaderboard = [[LeaderboardView alloc] initWithFrame:self.window.contentView.bounds];
    leaderboard.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    [leaderboard addScoreWithInitials:initials score:view.score];
    [self.window setContentView:leaderboard];
}

- (void)initialsEntryView:(InitialsEntryView *)view didEnterInitials:(NSString *)initials score:(NSInteger)score {
    NSLog(@"[AppDelegate] Player entered initials: %@ for score: %ld", initials, (long)score);
    [self showLeaderboardWithInitials:initials score:score];
}

- (void)leaderboardViewDidRequestReturnToMenu:(LeaderboardView *)view { 
    [self showStartMenu];
}

@end
