//
//  AppDelegate.h
//  BoxFitApp
//
//  Created by Bodo Junglas on 30.10.14.
//  Copyright (c) 2014 Leanovate. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BoxFitView.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (nonatomic, weak) IBOutlet NSWindow *window;
@property BoxFitView *screensaver;
@property NSTimer *animationTimer;

- (void)startAnimation;

@end

