//
//  SlashView.m
//  CosmicBrawler
//
//  Created by polerix on 2025-05-18.
//

#import "SplashView.h"

@interface SplashView ()
@property (nonatomic, strong) NSImage *splashImage;
@end

@implementation SplashView

- (instancetype)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.wantsLayer = NO;
        self.splashImage = [NSImage imageNamed:@"paul2"];

        NSLog(@"[SplashView] initWithFrame called with frame: %@", NSStringFromRect(frame));
        [NSTimer scheduledTimerWithTimeInterval:1.5
                                         target:self
                                       selector:@selector(finish)
                                       userInfo:nil
                                        repeats:NO];
        NSLog(@"[SplashView] scheduling finish timer for 1.5 seconds");
    }
    return self;
}

- (void)finish {
    NSLog(@"[SplashView] finish called - calling onFinish block if set");
    if (self.onFinish) {
        self.onFinish();
    }
}

- (void)drawRect:(NSRect)dirtyRect {
    NSLog(@"[SplashView] drawRect called with dirtyRect: %@", NSStringFromRect(dirtyRect));

    [[NSColor blackColor] setFill];
    NSRectFill(self.bounds);

    if (self.splashImage && self.splashImage.size.width > 0) {
        CGFloat maxW = self.bounds.size.width * 0.6;
        CGFloat maxH = self.bounds.size.height * 0.45;
        CGFloat scale = MIN(maxW / self.splashImage.size.width,
                            maxH / self.splashImage.size.height);
        CGFloat drawW = self.splashImage.size.width * scale;
        CGFloat drawH = self.splashImage.size.height * scale;
        CGFloat x = (self.bounds.size.width - drawW) / 2;
        CGFloat y = (self.bounds.size.height - drawH) / 2;

        NSLog(@"[SplashView] Drawing logo at (%.1f, %.1f) size (%.1f x %.1f)", x, y, drawW, drawH);

        [self.splashImage drawInRect:NSMakeRect(x, y, drawW, drawH)
                            fromRect:NSZeroRect
                           operation:NSCompositingOperationSourceOver
                            fraction:1.0
                      respectFlipped:YES
                               hints:nil];
    } else {
        NSString *fallback = @"Paul² Games";
        NSDictionary *attrs = @{
            NSFontAttributeName: [NSFont boldSystemFontOfSize:48],
            NSForegroundColorAttributeName: [NSColor whiteColor]
        };
        CGSize size = [fallback sizeWithAttributes:attrs];
        CGFloat x = (self.bounds.size.width - size.width) / 2;
        CGFloat y = (self.bounds.size.height - size.height) / 2;
        [fallback drawAtPoint:NSMakePoint(x, y) withAttributes:attrs];
    }
}

@end
