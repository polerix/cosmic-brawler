//
//  LeaderboarView.m
//  CosmicBrawler
//
//  Created by polerix on 2025-05-18.
//

#import <Foundation/Foundation.h>
#import "LeaderboardView.h"

#define LEADERBOARD_KEY @"cosmicbrawler.leaderboard"
#define MAX_LEADERBOARD_ENTRIES 5

@interface LeaderboardView ()
@property (nonatomic, strong) NSMutableArray *entries;
@end

@implementation LeaderboardView
@synthesize leaderboardEntries = _leaderboardEntries;

- (instancetype)initWithFrame:(NSRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self loadLeaderboard];
    }
    return self;
}

- (BOOL)isFlipped { return YES; }

- (void)addScoreWithInitials:(NSString *)initials score:(NSInteger)score {
    NSDictionary *entry = @{ @"name": initials ?: @"???", @"score": @(score) };
    [self.entries addObject:entry];
    
    [self.entries sortUsingComparator:^NSComparisonResult(NSDictionary *a, NSDictionary *b) {
        return [b[@"score"] compare:a[@"score"]];
    }];
    
    while (self.entries.count > MAX_LEADERBOARD_ENTRIES) {
        [self.entries removeLastObject];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:self.entries forKey:LEADERBOARD_KEY];
    [self setNeedsDisplay:YES];
}

- (void)loadLeaderboard {
    NSArray *stored = [[NSUserDefaults standardUserDefaults] arrayForKey:LEADERBOARD_KEY];
    self.entries = stored ? [stored mutableCopy] : [NSMutableArray array];
}

- (void)drawRect:(NSRect)dirtyRect {
    [[NSColor blackColor] set];
    NSRectFill(self.bounds);
    
    NSDictionary *titleAttrs = @{ NSFontAttributeName: [NSFont boldSystemFontOfSize:42],
                                  NSForegroundColorAttributeName: [NSColor whiteColor] };
    NSString *title = @"HALL OF HEROES";
    CGSize titleSize = [title sizeWithAttributes:titleAttrs];
    CGFloat centerX = self.bounds.size.width / 2;
    [title drawAtPoint:NSMakePoint(centerX - titleSize.width/2, 50) withAttributes:titleAttrs];
    
    NSDictionary *entryAttrs = @{ NSFontAttributeName: [NSFont userFixedPitchFontOfSize:24],
                                  NSForegroundColorAttributeName: [NSColor lightGrayColor] };
    CGFloat y = 120;
    for (int i = 0; i < self.entries.count; i++) {
        NSDictionary *entry = self.entries[i];
        NSString *line = [NSString stringWithFormat:@"%d. %@ - %ld",
                          i + 1, entry[@"name"], [entry[@"score"] integerValue]];
        CGSize size = [line sizeWithAttributes:entryAttrs];
        [line drawAtPoint:NSMakePoint(centerX - size.width / 2, y) withAttributes:entryAttrs];
        y += 36;
    }
}

- (void)setLeaderboardEntries:(NSArray<NSDictionary *> *)entries {
    _leaderboardEntries = [entries copy];
    [self setNeedsDisplay:YES];
}

- (BOOL)acceptsFirstResponder {
    return YES;
}

- (void)viewDidMoveToWindow {
    [self.window makeFirstResponder:self];
}

- (void)keyDown:(NSEvent *)event {
    if ([self.delegate respondsToSelector:@selector(leaderboardViewDidRequestReturnToMenu:)]) {
        [self.delegate leaderboardViewDidRequestReturnToMenu:self];
    }
}

- (void)mouseDown:(NSEvent *)event {
    if ([self.delegate respondsToSelector:@selector(leaderboardViewDidRequestReturnToMenu:)]) {
        [self.delegate leaderboardViewDidRequestReturnToMenu:self];
    }
}

@end

@interface InitialsEntryView ()
@property (nonatomic, strong) NSMutableString *initials;
@end

@implementation InitialsEntryView

- (instancetype)initWithFrame:(NSRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.initials = [NSMutableString string];
        self.wantsLayer = NO;
        [self.window makeFirstResponder:self];
    }
    return self;
}

- (BOOL)acceptsFirstResponder {
    return YES;
}

- (void)viewDidMoveToWindow {
    [self.window makeFirstResponder:self];
}

- (void)keyDown:(NSEvent *)event {
    NSString *key = event.charactersIgnoringModifiers.uppercaseString;
    
    // Backspace or delete
    if ([key isEqualToString:@"\x7F"] || [key isEqualToString:@"\b"]) {
        if (self.initials.length > 0) {
            [self.initials deleteCharactersInRange:NSMakeRange(self.initials.length - 1, 1)];
            [self setNeedsDisplay:YES];
        }
        return;
    }

    // Return / Enter
    if ([key isEqualToString:@"\r"] && self.initials.length > 0) {
        [self submitInitials];
        return;
    }

    // A-Z only
    if (key.length == 1) {
        unichar ch = [key characterAtIndex:0];
        if (ch >= 'A' && ch <= 'Z') {
            if (self.initials.length < 3) {
                [self.initials appendString:key];
                [self setNeedsDisplay:YES];
                if (self.initials.length == 3) {
                    [self submitInitials];
                }
            }
        }
    }
}

- (void)submitInitials {
    if ([self.delegate respondsToSelector:@selector(initialsEntryView:didEnterInitials:score:)]) {
        [self.delegate initialsEntryView:self didEnterInitials:self.initials score:self.score];
    }
}

- (void)drawRect:(NSRect)dirtyRect {
    [[NSColor blackColor] setFill];
    NSRectFill(self.bounds);

    CGFloat centerX = NSMidX(self.bounds);
    CGFloat y = 140;

    NSString *prompt = @"ENTER INITIALS";
    NSDictionary *titleAttrs = @{ NSFontAttributeName: [NSFont boldSystemFontOfSize:48],
                                  NSForegroundColorAttributeName: [NSColor whiteColor] };
    CGSize promptSize = [prompt sizeWithAttributes:titleAttrs];
    [prompt drawAtPoint:NSMakePoint(centerX - promptSize.width / 2, y)
         withAttributes:titleAttrs];

    NSString *entry = [NSString stringWithFormat:@"%@%@", self.initials,
                       self.initials.length < 3 ? @"_" : @""];
    NSDictionary *initialsAttrs = @{ NSFontAttributeName: [NSFont fontWithName:@"Menlo-Bold" size:64],
                                     NSForegroundColorAttributeName: [NSColor cyanColor] };
    y += 80;
    CGSize entrySize = [entry sizeWithAttributes:initialsAttrs];
    [entry drawAtPoint:NSMakePoint(centerX - entrySize.width / 2, y)
        withAttributes:initialsAttrs];
}

@end
