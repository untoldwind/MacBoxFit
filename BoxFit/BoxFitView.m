//
//  BoxFitView.m
//  BoxFit
//
//  Created by Bodo Junglas on 30.10.14.
//  Copyright (c) 2014 Leanovate. All rights reserved.
//

#import "BoxFitView.h"

typedef NS_OPTIONS(UInt8, BoxFlags) {
    ALIVE = 1,
    CHANGED = 2,
    UNDEAD = 4,
};

typedef struct {
    UInt32 fill_color;
    int32_t x, y, w, h;
    BoxFlags flags;
} Box;

@implementation BoxFitView {
    UInt16 nboxes;
    UInt16 boxesSize;
    Box *boxes;
    BOOL growing;
    BOOL circles;
    UInt16 inc;
    UInt16 spacing;
    UInt16 borderSize;
    UInt16 lifeBoxCount;
    UInt16 maxBoxCount;
    NSColor *background;
}

- (instancetype)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
    self = [super initWithFrame:frame isPreview:isPreview];
    if (self) {
        ScreenSaverDefaults *defaults;
        
        defaults = [ScreenSaverDefaults defaultsForModuleWithName:@"BoxFit"];
        
        [defaults registerDefaults:@{@"lifeBoxCount":@50, @"maxBoxCount":@650, @"growBy":@1, @"spacing":@0, @"boderSize":@0}];
        
        self.animationTimeInterval = 1/30.0;
    }
    return self;
}

- (void)startAnimation
{
    [super startAnimation];
    
    ScreenSaverDefaults *defaults;
    
    defaults = [ScreenSaverDefaults defaultsForModuleWithName:@"BoxFit"];

    background = [NSColor blackColor];
    lifeBoxCount = [defaults integerForKey:@"lifeBoxCount"];
    maxBoxCount = [defaults integerForKey:@"maxBoxCount"];
    boxesSize = lifeBoxCount * 2;
    inc = [defaults integerForKey:@"growBy"];
    spacing = [defaults integerForKey:@"spacing"];
    borderSize = [defaults integerForKey:@"borderSize"];
    boxes = calloc(boxesSize, sizeof(Box));

    [self resetBoxes];
}

- (void)stopAnimation
{
    [super stopAnimation];
    
    free(boxes);
}

- (void)drawRect:(NSRect)rect
{
    [super drawRect:rect];
}

- (void)animateOneFrame
{
    if ( growing )
        [self growBoxes];
    else
        [self shrinkBoxes];
    
    [self drawBoxes];
}

- (BOOL)hasConfigureSheet
{
    return NO;
}

- (NSWindow*)configureSheet
{
    return nil;
}

- (void)drawBoxes {
    for (UInt16 i = 0; i < nboxes; i++) {
        Box *b = &boxes[i];
        
        if (b->flags & UNDEAD) continue;
        if (!(b->flags & CHANGED)) continue;
        b->flags &= ~CHANGED;

        if (!growing) {
            int margin = inc + borderSize;
            [background set];
            
            NSRect rect = NSMakeRect(b->x - margin, b->y - margin, b->w + margin * 2, b->h + margin * 2);
            if (circles) {
                [[NSBezierPath bezierPathWithOvalInRect:rect] fill];
            } else {
                [[NSBezierPath bezierPathWithRect:rect] fill];
            }
        }
        
        [[NSColor blueColor] set];
        
        NSRect rect = NSMakeRect(b->x, b->y, b->w, b->h);
        NSBezierPath *path;
        
        if (circles) {
            path = [NSBezierPath bezierPathWithOvalInRect:rect];
        } else {
            path = [NSBezierPath bezierPathWithRect:rect];
        }
        [path fill];
        
        if ( borderSize > 0 ) {
            [[NSColor whiteColor] set];
            
            path.lineWidth = borderSize;
            [path stroke];
        }
    }
}

- (BOOL)boxesOverlap:(Box *)box other:(Box *)otherBox pad:(UInt16)pad {
    int32_t maxleft = MAX(box->x - pad, otherBox->x);
    int32_t maxtop = MAX(box->y - pad, otherBox->y);
    int32_t minright = MIN(box->x + box->w + pad + pad - 1, otherBox->x + otherBox->w);
    int32_t minbottom = MIN(box->y + box->h + pad + pad - 1, otherBox->y + otherBox->h);
    
    return (maxtop < minbottom && maxleft < minright);
}

- (BOOL)circlesOverlap:(Box *)box other:(Box *)otherBox pad:(UInt16)pad {
    int32_t ar = box->w/2;	/* radius */
    int32_t br = otherBox->w/2;
    int32_t ax = box->x + ar;	/* center */
    int32_t ay = box->y + ar;
    int32_t bx = otherBox->x + br;
    int32_t by = otherBox->y + br;
    int32_t d2 = (((bx - ax) * (bx - ax)) +	/* distance between centers squared */
              ((by - ay) * (by - ay)));
    int32_t r2 = ((ar + br + pad) *		/* sum of radii squared */
              (ar + br + pad));
    return (d2 < r2);
}

- (BOOL)boxCollides:(Box *)box pad:(UInt16)pad {
    NSSize size = self.bounds.size;
    
    if (box->x - pad < 0 ||
        box->y - pad < 0 ||
        box->x + box->w + pad + pad >= size.width ||
        box->y + box->h + pad + pad >= size.height)
        return YES;

    for (UInt16 i = 0; i < nboxes; i++) {
        Box *b = &boxes[i];
        if ( box != b && (circles ? [self circlesOverlap:box other:b pad:pad] : [self boxesOverlap:box other:b pad:pad]))
            return YES;
    }

    return NO;
}

- (void)growBoxes {
    NSSize size = self.bounds.size;
    UInt16 inc2 = inc + spacing + borderSize;
    UInt16 i;
    UInt16 live_count = 0;
    
    /* check box collisions, and grow if none.
     */
    for (i = 0; i < nboxes; i++) {
        Box *a = &boxes[i];
        if (!(a->flags & ALIVE)) continue;
        
        if ([self boxCollides:a pad:inc2]) {
            a->flags &= ~ALIVE;
            continue;
        }
        
        live_count++;
        a->x -= inc;
        a->y -= inc;
        a->w += inc + inc;
        a->h += inc + inc;
        a->flags |= CHANGED;
    }
    
    /* Add more boxes.
     */
    while (live_count < lifeBoxCount) {
        Box *a;
        nboxes++;
        if (boxesSize <= nboxes) {
            boxesSize = (boxesSize * 1.2) + nboxes;
            boxes = realloc (boxes, boxesSize * sizeof(Box));
            if (!boxes) {
                NSLog(@"out of memory (%d boxes)", boxesSize);
                return;
            }
        }
        
        a = &boxes[nboxes - 1];
        a->flags = CHANGED;
        
        for (i = 0; i < 100; i++) {
            a->x = SSRandomIntBetween(inc2, size.width - inc2);
            a->y = SSRandomIntBetween(inc2, size.height - inc2);
            a->w = 0;
            a->h = 0;
            
            if(![self boxCollides:a pad:inc2]) {
                a->flags |= ALIVE;
                live_count++;
                break;
            }
        }
        
        if (! (a->flags & ALIVE) ||	/* too many retries; */
            nboxes > maxBoxCount)		/* that's about 1MB of box structs. */
        {
            nboxes--;			/* go into "fade out" mode now. */
            growing = NO;
            return;
        }
    }
}

- (void)shrinkBoxes {
    UInt16 i;
    UInt16 remaining = 0;
    
    for (i = 0; i < nboxes; i++) {
        Box *a = &boxes[i];
        
        if (a->w <= 0 || a->h <= 0) continue;
        
        a->x += inc;
        a->y += inc;
        a->w -= inc + inc;
        a->h -= inc + inc;
        a->flags |= CHANGED;
        
        if (a->w < 0) a->w = 0;
        if (a->h < 0) a->h = 0;
        
        if (a->w > 0 && a->h > 0)
            remaining++;
    }
    
    if (remaining == 0) {
        [self resetBoxes];
    }
}

- (void)resetBoxes {
    circles = SSRandomIntBetween(0, 1);
    nboxes = 0;
    growing = YES;
}

@end
