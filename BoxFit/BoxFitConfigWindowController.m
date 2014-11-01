//
//  BoxFitConfigWindowController.m
//  BoxFit
//
//  Created by Bodo Junglas on 01.11.14.
//  Copyright (c) 2014 Leanovate. All rights reserved.
//

#import "BoxFitConfigWindowController.h"

@implementation BoxFitConfigWindowController {
    ScreenSaverDefaults *_defaults;
}

@synthesize lifeBoxCount;
@synthesize maxBoxCount;
@synthesize growBy;
@synthesize spacing;
@synthesize borderSize;
@synthesize colors;

- (instancetype)initWithDefaults:(ScreenSaverDefaults *)defaults {
    self = [super init];
    if ( self ) {
        _defaults = defaults;
    }
    return self;
}

- (NSString *)windowNibName {
    return @"BoxFitConfigWindow";
}

- (void)awakeFromNib {
    self.lifeBoxCount = [_defaults objectForKey:@"lifeBoxCount"];
    self.maxBoxCount = [_defaults objectForKey:@"maxBoxCount"];
    self.growBy = [_defaults objectForKey:@"growBy"];
    self.spacing = [_defaults objectForKey:@"spacing"];
    self.borderSize = [_defaults objectForKey:@"borderSize"];
    self.colors = [_defaults objectForKey:@"colors"];
}

- (IBAction)saveAndClose:(id)sender {
    [_defaults setObject:self.lifeBoxCount forKey:@"lifeBoxCount"];
    [_defaults setObject:self.maxBoxCount forKey:@"maxBoxCount"];
    [_defaults setObject:self.growBy forKey:@"growBy"];
    [_defaults setObject:self.spacing forKey:@"spacing"];
    [_defaults setObject:self.borderSize forKey:@"borderSize"];
    [_defaults setObject:self.colors forKey:@"colors"];
    [self.window.sheetParent endSheet:self.window returnCode:NSModalResponseOK];
}

- (IBAction)cancelAndClose:(id)sender {
    [self.window.sheetParent endSheet:self.window returnCode:NSModalResponseAbort];
}

- (void)setLifeBoxCount:(NSNumber *)_lifeBoxCount {
    lifeBoxCount = @(_lifeBoxCount.intValue);
}

- (void)setMaxBoxCount:(NSNumber *)_maxBoxCount {
    maxBoxCount = @(_maxBoxCount.intValue);
}

- (void)setGrowBy:(NSNumber *)_growBy {
    growBy = @(_growBy.intValue);
}

- (void)setSpacing:(NSNumber *)_spacing {
    spacing = @(_spacing.intValue);
}

- (void)setBorderSize:(NSNumber *)_borderSize {
    borderSize = @(_borderSize.intValue);
}

- (void)setColors:(NSNumber *)_colors {
    colors = @(_colors.intValue);
}

@end
