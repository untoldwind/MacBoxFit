//
//  AppDelegate.m
//  BoxFitApp
//
//  Created by Bodo Junglas on 30.10.14.
//  Copyright (c) 2014 Leanovate. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

@synthesize window;
@synthesize screensaver;
@synthesize animationTimer;

- (instancetype)init {
    self = [super init];
    if (self) {
        self.screensaver = [[BoxFitView alloc] initWithFrame:NSZeroRect isPreview:NO];
    }
    return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    self.screensaver.frame = [self.window.contentView bounds];
    self.screensaver.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    [self.window.contentView addSubview:self.screensaver];

    [self startAnimation];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (void)startAnimation {
    if (self.animationTimer != nil) {
        return;
    }
    
    [self.screensaver startAnimation];
    self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:self.screensaver.animationTimeInterval target:self.screensaver selector:NSSelectorFromString(@"_oneStep:") userInfo:nil repeats:YES];
}

- (void)stopAnimation {
    if (self.animationTimer == nil) {
        return;
    }
    [self.animationTimer invalidate];
    self.animationTimer = nil;
    
    [self.screensaver stopAnimation];
}

- (IBAction)openConfiguration:(id)sender {
    if ( !self.screensaver.hasConfigureSheet )
        return;

    [self stopAnimation];
    
    [self.window beginSheet:self.screensaver.configureSheet completionHandler:^(NSModalResponse returnCode) {
        [self.window.contentView setNeedsDisplay:YES];
        [self startAnimation];
    } ];
}

@end
