//
//  BoxFitConfigWindowController.h
//  BoxFit
//
//  Created by Bodo Junglas on 01.11.14.
//  Copyright (c) 2014 Leanovate. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
#import <ScreenSaver/ScreenSaver.h>

@interface BoxFitConfigWindowController : NSWindowController

@property (nonatomic) NSNumber *lifeBoxCount;
@property (nonatomic) NSNumber *maxBoxCount;
@property (nonatomic) NSNumber *growBy;
@property (nonatomic) NSNumber *spacing;
@property (nonatomic) NSNumber *borderSize;
@property (nonatomic) NSNumber *colors;

- (instancetype)initWithDefaults:(ScreenSaverDefaults *)defaults;

- (IBAction)saveAndClose:(id)sender;

- (IBAction)cancelAndClose:(id)sender;

@end
