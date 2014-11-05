//
//  ColorHelper.m
//  BoxFit
//
//  Created by Bodo Junglas on 31.10.14.
//  Copyright (c) 2014 Leanovate. All rights reserved.
//

#import "ColorHelper.h"
#import <ScreenSaver/ScreenSaver.h>

const int MAXPOINTS = 50;

@implementation ColorHelper

+ (NSArray *)smoothColormap:(int)nColors {
    int npoints;
    int loop = 0;
    CGFloat h[MAXPOINTS];
    CGFloat s[MAXPOINTS];
    CGFloat v[MAXPOINTS];
    CGFloat total_s = 0;
    CGFloat total_v = 0;
    
    int n = SSRandomIntBetween(0, 19);
    
    if      (n <= 5)  npoints = 2;
    else if (n <= 15) npoints = 3;
    else if (n <= 18) npoints = 4;
    else              npoints = 5;

    do {
        total_s = 0;
        total_v = 0;
        for (int i = 0; i < npoints; i++) {
            if (++loop > 10000) break;
            h[i] = SSRandomFloatBetween(0, 1.0);
            s[i] = SSRandomFloatBetween(0, 1.0);
            v[i] = SSRandomFloatBetween(0.2, 1.0);
        
            if (i > 0) {
                int j = i - 1;
                CGFloat dh = h[j] - h[i];
                CGFloat distance;
            
                if (dh < 0) dh = -dh;
                if (dh > 0.5) dh = 0.5 - (dh - 0.5);
            
                distance = sqrt((dh * dh) +
                                ((s[j] - s[i]) * (s[j] - s[i])) +
                                ((v[j] - v[i]) * (v[j] - v[i])));
                
                if (distance < 0.2) {
                    i--;
                    continue;
                }
            }
            total_s += s[i];
            total_v += v[i];
        }
    } while (loop < 10000 && (total_s / npoints < 0.2 || total_v / npoints < 0.3));

    return [self makeColorPath:nColors npoints:npoints h:h s:s v:v];
}

+ (NSArray *)makeColorPath:(int)nColors npoints:(int)npoints h:(CGFloat *)h s:(CGFloat *)s v:(CGFloat *)v {
    int total_ncolors = nColors;
    int ncolors[MAXPOINTS];
    int i;
    CGFloat dh[MAXPOINTS];
    CGFloat ds[MAXPOINTS];
    CGFloat dv[MAXPOINTS];
    CGFloat edge[MAXPOINTS];
    CGFloat ratio[MAXPOINTS];
    NSMutableArray *colors = [NSMutableArray array];
    
    if ( npoints == 0 ) {
        return [NSArray array];
    } else if ( npoints == 2 ) {
        return [self makeColorRamp:nColors h1:h[0] s1:s[0] v1:v[0] h2:h[1] s2:s[1] v2:v[1] closed:YES];
    } else if ( npoints >= MAXPOINTS ) {
        npoints = MAXPOINTS - 1;
    }
    
    for (i = 0; i < npoints; i++)
        ncolors[i] = 0;
    
    while (total_ncolors > 0) {
        CGFloat circum = 0;
        CGFloat one_point_oh = 0;
        
        for (i = 0; i < npoints; i++) {
            int j = (i + 1) % npoints;
            edge[i] = sqrt(((h[j] - h[i]) * (h[j] - h[i])) +
                           ((s[j] - s[i]) * (s[j] - s[i])) +
                           ((v[j] - v[i]) * (v[j] - v[i])));
            circum += edge[i];
        }
        
        for (i = 0; i < npoints; i++) {
            ratio[i] = edge[i] / circum;
            one_point_oh += ratio[i];
        }

        if (one_point_oh < 0.99999 || one_point_oh > 1.00001)
            return colors;
        
        if (circum > 0.0001)
            break;

        total_ncolors = (total_ncolors > 170 ? total_ncolors - 20 :
                         total_ncolors > 100 ? total_ncolors - 10 :
                         total_ncolors >  75 ? total_ncolors -  5 :
                         total_ncolors >  25 ? total_ncolors -  3 :
                         total_ncolors >  10 ? total_ncolors -  2 :
                         total_ncolors >   2 ? total_ncolors -  1 :
                         0);
    }

    for (i = 0; i < npoints; i++)
        ncolors[i] = total_ncolors * ratio[i];
    
    for (i = 0; i < npoints; i++) {
        int j = (i+1) % npoints;
        
        if (ncolors[i] > 0) {
            dh[i] = (h[j] - h[i]) / ncolors[i];
            ds[i] = (s[j] - s[i]) / ncolors[i];
            dv[i] = (v[j] - v[i]) / ncolors[i];
        }
    }
    
    for (i = 0; i < npoints; i++) {
        for (int j = 0; j < ncolors[i]; j++) {
            [colors addObject:[NSColor colorWithCalibratedHue:(h[i] + (j * dh[i])) saturation:(s[i] + (j * ds[i])) brightness:(v[i] + (j * dv[i])) alpha:1.0f]];
        }
    }
    
    return colors;
}

+ (NSArray *)makeColorRamp:(int)nColors h1:(CGFloat)h1 s1:(CGFloat)s1 v1:(CGFloat)v1 h2:(CGFloat)h2 s2:(CGFloat)s2 v2:(CGFloat)v2 closed:(BOOL)closed {
    int total_ncolors = nColors;
    int i;
    int wanted;
    CGFloat dh, ds, dv;
    NSMutableArray *colors = [NSMutableArray array];
    
    wanted = total_ncolors;
    if (closed)
        wanted = (wanted / 2) + 1;
    
    dh = (h2 - h1) / wanted;
    ds = (s2 - s1) / wanted;
    dv = (v2 - v1) / wanted;

    for (i = 0; i < wanted; i++) {
        [colors addObject:[NSColor colorWithCalibratedHue:(h1 + i*dh) saturation:(s1 + (i*ds)) brightness:(v1 + (i*dv)) alpha:1.0f]];
    }
    
    if (closed)
        for (i = wanted; i < nColors; i++)
            [colors addObject:colors[nColors - i]];
    
    return colors;
}

@end
