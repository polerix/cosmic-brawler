//
//  MainContentView.m
//  CosmicBrawler
//
//  Created by polerix on 2025-05-17.
//

#import "MainContentView.h"

@implementation MainContentView

- (instancetype)initWithFrame:(NSRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Explicitly disable layer backing for absolute safety
        self.wantsLayer = NO;
    }
    return self;
}

- (BOOL)wantsUpdateLayer {
    // Return NO to use drawRect for drawing, no layer updates
    return NO;
}

- (void)drawRect:(NSRect)dirtyRect {
    // Fill with solid black or any color to confirm it's drawing
    [[NSColor blackColor] setFill];
    NSRectFill(self.bounds);
}

@end
