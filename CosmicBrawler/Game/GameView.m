//
//  GameView.m
//  CosmicBrawler
//
//  Created by polerix on 2025-05-17.
//

#import "GameView.h"

typedef NS_ENUM(NSInteger, EnemySide) {
    EnemySideLeft,
    EnemySideRight
};
typedef NS_ENUM(NSInteger, CharPose) {
    CharPoseIdle,
    CharPosePunchLeft,
    CharPosePunchRight
};

@interface GameView ()
@property (nonatomic, strong) NSTimer *gameTimer;
@property (nonatomic, strong) NSTimer *spawnTimer;
@property (nonatomic, strong) NSTimer *poseTimer;
@property (nonatomic, strong) NSMutableArray *enemies;
@property (nonatomic) BOOL isGameOver;
@property (nonatomic) NSInteger score;
@property (nonatomic) CharPose pose;

@property (nonatomic, strong) NSImage *idleImage;
@property (nonatomic, strong) NSImage *punchLeftImage;
@property (nonatomic, strong) NSImage *punchRightImage;
@property (nonatomic, strong) NSImage *enemyImage;
@end

@implementation GameView

- (instancetype)initWithFrame:(NSRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self loadImages];
        [self startGame];
    }
    return self;
}

- (BOOL)isFlipped { return YES; }

- (void)loadImages {
    self.idleImage = [NSImage imageNamed:@"mainchar"];
    self.punchLeftImage = [NSImage imageNamed:@"punchleft"];
    self.punchRightImage = [NSImage imageNamed:@"punchright"];
    self.enemyImage = [NSImage imageNamed:@"enemy"];
}

- (void)startGame {
    self.enemies = [NSMutableArray array];
    self.isGameOver = NO;
    self.score = 0;
    self.pose = CharPoseIdle;

    [self.gameTimer invalidate];
    [self.spawnTimer invalidate];

    self.gameTimer = [NSTimer scheduledTimerWithTimeInterval:0.02
                                                      target:self
                                                    selector:@selector(gameLoop)
                                                    userInfo:nil
                                                     repeats:YES];
    [self startSpawnTimerWithInterval:1.2];
    [self spawnEnemy];
    [self setNeedsDisplay:YES];
}

- (void)endGame {
    self.isGameOver = YES;
    [self.gameTimer invalidate];
    [self.spawnTimer invalidate];
    [self.poseTimer invalidate];
    self.pose = CharPoseIdle;
    [self setNeedsDisplay:YES];

    if ([self.delegate respondsToSelector:@selector(gameViewDidEndGameWithScore:)]) {
        [self.delegate gameViewDidEndGameWithScore:self.score];
    } else {
        NSLog(@"[GameView] WARNING: Delegate is nil or does not respond to gameViewDidEndGameWithScore:");
    }
}

- (void)startSpawnTimerWithInterval:(float)interval {
    [self.spawnTimer invalidate];
    self.spawnTimer = [NSTimer scheduledTimerWithTimeInterval:interval
                                                       target:self
                                                     selector:@selector(spawnEnemy)
                                                     userInfo:nil
                                                      repeats:YES];
}

- (void)spawnEnemy {
    if (self.isGameOver) return;
    EnemySide side = (arc4random_uniform(2) == 0) ? EnemySideLeft : EnemySideRight;
    float pos = (side == EnemySideLeft) ? 0.0 : 1.0;
    [self.enemies addObject:[@{@"side": @(side), @"pos": @(pos)} mutableCopy]];

    float newInterval = MAX(0.45, 1.2 - self.score * 0.07);
    [self startSpawnTimerWithInterval:newInterval];
}

- (void)gameLoop {
    if (self.isGameOver) return;
    float speed = 0.008 + self.score * 0.0005;
    NSMutableArray *toRemove = [NSMutableArray array];

    for (NSMutableDictionary *enemy in self.enemies) {
        float pos = [enemy[@"pos"] floatValue];
        EnemySide side = [enemy[@"side"] integerValue];
        pos += (side == EnemySideLeft) ? speed : -speed;
        enemy[@"pos"] = @(pos);

        if ((side == EnemySideLeft && pos >= 0.5) ||
            (side == EnemySideRight && pos <= 0.5)) {
            [self endGame];
            return;
        }
        if ((side == EnemySideLeft && pos > 1.1) ||
            (side == EnemySideRight && pos < -0.1)) {
            [toRemove addObject:enemy];
        }
    }

    [self.enemies removeObjectsInArray:toRemove];
    [self setNeedsDisplay:YES];
}

#pragma mark - Input

- (void)mouseDown:(NSEvent *)event {
    if (self.isGameOver) { [self startGame]; return; }
    NSPoint pt = [self convertPoint:event.locationInWindow fromView:nil];
    CGFloat center = self.bounds.size.width / 2;
    EnemySide side = (pt.x < center) ? EnemySideLeft : EnemySideRight;
    [self handlePunch:side];
}

- (void)keyDown:(NSEvent *)event {
    if (self.isGameOver) { [self startGame]; return; }
    NSString *charStr = event.charactersIgnoringModifiers.lowercaseString;
    if ([charStr isEqualToString:@"a"] || event.keyCode == 123) {
        [self handlePunch:EnemySideLeft];
    } else if ([charStr isEqualToString:@"l"] || event.keyCode == 124) {
        [self handlePunch:EnemySideRight];
    } else if ([charStr isEqualToString:@" "]) {
        [self punchClosestEnemy];
    }
}

- (void)punchClosestEnemy {
    float closestDist = 10.0;
    NSMutableDictionary *closestEnemy = nil;
    EnemySide closestSide = EnemySideLeft;

    for (NSMutableDictionary *enemy in self.enemies) {
        float pos = [enemy[@"pos"] floatValue];
        float dist = fabs(pos - 0.5);
        if (dist < closestDist) {
            closestDist = dist;
            closestEnemy = enemy;
            closestSide = [enemy[@"side"] integerValue];
        }
    }

    if (closestEnemy) [self handlePunch:closestSide];
}

- (void)handlePunch:(EnemySide)side {
    self.pose = (side == EnemySideLeft) ? CharPosePunchLeft : CharPosePunchRight;
    [self.poseTimer invalidate];
    self.poseTimer = [NSTimer scheduledTimerWithTimeInterval:0.18
                                                      target:self
                                                    selector:@selector(returnToIdlePose)
                                                    userInfo:nil
                                                     repeats:NO];

    for (NSMutableDictionary *enemy in self.enemies) {
        if ([enemy[@"side"] integerValue] == side &&
            fabs([enemy[@"pos"] floatValue] - 0.5) < 0.17) {
            self.score++;
            [self.enemies removeObject:enemy];
            [self setNeedsDisplay:YES];
            return;
        }
    }

    [self endGame];
}

- (void)returnToIdlePose {
    self.pose = CharPoseIdle;
    [self setNeedsDisplay:YES];
}

#pragma mark - Drawing

- (void)drawRect:(NSRect)dirtyRect {
    [[NSColor blackColor] setFill];
    NSRectFill(self.bounds);
    CGFloat w = self.bounds.size.width, h = self.bounds.size.height;
    CGFloat centerX = w / 2, centerY = h / 2;

    CGFloat enemyW = 72, enemyH = 72;
    CGContextRef ctx = [[NSGraphicsContext currentContext] CGContext];

    for (NSDictionary *enemy in self.enemies) {
        EnemySide side = [enemy[@"side"] integerValue];
        float pos = [enemy[@"pos"] floatValue];
        CGFloat x = (side == EnemySideLeft)
            ? -enemyW + (centerX + enemyW) * (pos / 0.5)
            : w + enemyW - (centerX + enemyW) * ((1.0 - pos) / 0.5);
        CGFloat drawY = h - centerY - enemyH/2;

        CGContextSaveGState(ctx);
        CGContextTranslateCTM(ctx, 0, h);
        CGContextScaleCTM(ctx, 1.0, -1.0);
        if (side == EnemySideLeft) {
            CGContextTranslateCTM(ctx, x, drawY + enemyH/2);
            CGContextScaleCTM(ctx, -1.0, 1.0);
            CGContextTranslateCTM(ctx, -x, -(drawY + enemyH/2));
        }
        [self.enemyImage drawInRect:NSMakeRect(x - enemyW/2, drawY, enemyW, enemyH)
                           fromRect:NSZeroRect
                          operation:NSCompositingOperationSourceOver
                           fraction:1.0];
        CGContextRestoreGState(ctx);
    }

    NSImage *img = (self.pose == CharPosePunchLeft) ? self.punchLeftImage :
                    (self.pose == CharPosePunchRight) ? self.punchRightImage : self.idleImage;

    CGFloat charW = 96, charH = 96;
    CGFloat imgX = centerX - charW/2, imgY = centerY - charH/2;

    CGContextSaveGState(ctx);
    CGContextTranslateCTM(ctx, 0, h);
    CGContextScaleCTM(ctx, 1.0, -1.0);

    [img drawInRect:NSMakeRect(imgX, h - imgY - charH, charW, charH)
           fromRect:NSZeroRect
          operation:NSCompositingOperationSourceOver
           fraction:1.0];
    CGContextRestoreGState(ctx);

    NSDictionary *scoreAttrs = @{ NSFontAttributeName: [NSFont fontWithName:@"Menlo-Bold" size:32],
                                  NSForegroundColorAttributeName: [NSColor whiteColor] };
    NSString *scoreStr = [NSString stringWithFormat:@"%ld", (long)self.score];
    [scoreStr drawAtPoint:NSMakePoint(centerX-12, 24) withAttributes:scoreAttrs];
}

@end
