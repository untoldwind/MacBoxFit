//
//  BoxFitConfig.m
//  BoxFit
//
//  Created by Bodo Junglas on 30.10.14.
//  Copyright (c) 2014 Leanovate. All rights reserved.
//

#import "BoxFitConfig.h"

@implementation BoxFitConfig

@synthesize boxCount;
@synthesize growBy;
@synthesize colors;

- (instancetype)init {
    self = [super init];
    if ( self ) {
        self.boxCount = 50;
        self.growBy = 1;
        self.colors = 64;
    }
    return self;
}

@end
