//
//  OPPlotModelBase.m
//  OnePiece
//
//  Created by Duanwwu on 2016/12/8.
//  Copyright © 2016年 DZH. All rights reserved.
//

#import "OPPlotModelBase.h"
#import "NSString+FastDrawing.h"

@implementation OPPlotModelBase

- (void)drawWithContext:(CGContextRef)context;
{
    
}

@end

@implementation OPPlotLabelModel

- (void)drawWithContext:(CGContextRef)context
{
    if ([self.text length] == 0)
        return;
    
    CGContextSaveGState(context);
    
    [self.text fd_drawCenterInRect:self.textRect withFont:self.textFont fontColor:self.textColor alignment:self.textAlignment];
    
    CGContextRestoreGState(context);
}

@end

@implementation OPPlotPathModel

@synthesize path                        = _path;

- (instancetype)init
{
    if (self = [super init])
    {
        self.drawingMode                = kCGPathStroke;
    }
    return self;
}

-(void)dealloc
{
    if (_path)
        CGPathRelease(_path);
}

- (void)setPath:(CGPathRef)path
{
    if (_path != path)
    {
        CGPathRelease(_path);
        _path                           = CGPathRetain(path);
    }
}

- (void)drawWithContext:(CGContextRef)context
{
    if (self.path == NULL)
        return;
    
    CGContextSaveGState(context);
    
    if (self.strokeColor)
        CGContextSetStrokeColorWithColor(context, self.strokeColor.CGColor);
    if (self.fillColor)
        CGContextSetFillColorWithColor(context, self.fillColor.CGColor);
    if (self.dashPattern)
    {
        NSInteger count                 = [self.dashPattern count];
        CGFloat lenghts[count];
        for (int z = 0; z < count; z ++)
        {
            lenghts[z]                  = [[self.dashPattern objectAtIndex:z] floatValue];
        }
        CGContextSetLineDash(context, 0, lenghts, count);
    }
    
    CGContextSetLineWidth(context, self.lineWidth);
    CGContextAddPath(context, self.path);
    CGContextDrawPath(context, self.drawingMode);
    
    CGContextRestoreGState(context);
}

@end

@implementation OPPlotGradientModel

@synthesize gradientPath                = _gradientPath;

-(void)dealloc
{
    if (_gradientPath)
        CGPathRelease(_gradientPath);
}

- (void)setGradientPath:(CGPathRef)gradientPath
{
    if (_gradientPath != gradientPath)
    {
        CGPathRelease(_gradientPath);
        _gradientPath                   = CGPathRetain(gradientPath);
    }
}

- (void)drawWithContext:(CGContextRef)context
{
    if (self.gradientPath == NULL)
        return;
    
    CGContextSaveGState(context);
    
    CGContextAddPath(context, self.gradientPath);
    CGContextClip(context);
    CGGradientDrawingOptions options    = kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation;
    CGColorSpaceRef colorSpace          = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient              = CGGradientCreateWithColors(colorSpace, (CFArrayRef)self.gradientColors, NULL);
    CGColorSpaceRelease(colorSpace);
    CGContextDrawLinearGradient(context, gradient, self.startPoint, self.endPoint, options);
    CGGradientRelease(gradient);
    
    CGContextRestoreGState(context);
}

@end
