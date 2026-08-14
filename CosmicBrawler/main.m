//
//  main.m
//  CosmicBrawler
//
//  Created by polerix on 2025-05-17.
//

#import <Cocoa/Cocoa.h>
#import "AppDelegate.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSLog(@"%@",[NSColor lightGrayColor]);
        NSApplication * app = [NSApplication sharedApplication];
        AppDelegate * delegate = [[AppDelegate alloc] init];
        [app setDelegate:delegate];
        [app run];
    }
    return EXIT_SUCCESS;
}
