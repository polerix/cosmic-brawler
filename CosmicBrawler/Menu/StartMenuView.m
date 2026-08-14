//
//  StartMenuView.m
//  CosmicBrawler
//
//  Created by polerix on 2025-05-18.
//

#import <Foundation/Foundation.h>
#import "StartMenuView.h"

@interface StartMenuView ()
@property (nonatomic, strong) NSImage* titleImage;
@end

@implementation StartMenuView

- (instancetype)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.wantsLayer = NO;
        self.titleImage = [NSImage imageNamed:@"titlescreen"];
        NSLog(@"[StartMenuView] initWithFrame: %@", NSStringFromRect(frame));
    }
    return self;
}

- (BOOL)acceptsFirstResponder {
    return YES;
}

- (void)viewDidMoveToWindow {
    [self.window makeFirstResponder:self];
    NSLog(@"[StartMenuView] viewDidMoveToWindow called");
}

- (void)mouseDown:(NSEvent *)event {
    NSLog(@"[StartMenuView] mouseDown event received");
    [self start];
}

- (void)keyDown:(NSEvent *)event {
    NSLog(@"[StartMenuView] keyDown event received: %@", event.charactersIgnoringModifiers);
    [self start];
}

- (void)start {
    NSLog(@"[StartMenuView] start method called");
    if ([self.delegate respondsToSelector:@selector(startMenuDidRequestStartGame:)]) {
        [self.delegate startMenuDidRequestStartGame:self];
    } else {
        NSLog(@"[StartMenuView] delegate does not respond to startMenuDidRequestStartGame:");
    }
}

- (void)drawRect:(NSRect)dirtyRect {
    NSLog(@"[StartMenuView] drawRect called");

    // Fill background
    [[NSColor colorWithCalibratedRed:0.12 green:0.16 blue:0.2 alpha:1] setFill];
    NSRectFill(self.bounds);

    // Draw full-screen image
    if (self.titleImage && self.titleImage.size.width > 0) {
        NSSize imgSize = self.titleImage.size;
        CGFloat scale = MAX(self.bounds.size.width / imgSize.width,
                            self.bounds.size.height / imgSize.height);

        CGFloat drawW = imgSize.width * scale;
        CGFloat drawH = imgSize.height * scale;
        CGFloat x = (self.bounds.size.width - drawW) / 2;
        CGFloat y = (self.bounds.size.height - drawH) / 2;

        [self.titleImage drawInRect:NSMakeRect(x, y, drawW, drawH)
                           fromRect:NSZeroRect
                          operation:NSCompositingOperationSourceOver
                           fraction:1.0
                     respectFlipped:YES
                              hints:nil];
    }

    // Subtitle at the bottom
    NSString *subtitle = @"Press any key or click to start";
    NSDictionary *attrs = @{
        NSFontAttributeName: [NSFont systemFontOfSize:32],
        NSForegroundColorAttributeName: [NSColor colorWithCalibratedRed:0.702 green:0.278 blue:0.075 alpha:1.0]
    };
    CGSize subtitleSize = [subtitle sizeWithAttributes:attrs];
    CGFloat subtitleX = (self.bounds.size.width - subtitleSize.width) / 2;
    CGFloat subtitleY = 40;
    [subtitle drawAtPoint:NSMakePoint(subtitleX, subtitleY) withAttributes:attrs];
}

@end
