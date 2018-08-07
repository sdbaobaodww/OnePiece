//
//  OPPlotSpacesKLine.m
//  OnePiece
//
//  Created by Duanwwu on 2017/1/18.
//  Copyright © 2017年 DZH. All rights reserved.
//

#import "OPPlotSpacesKLine.h"
#import "NSString+NumberFormat.h"
#import "OPTrendConstant.h"
#import "NSString+FastDrawing.h"
#import "UIColor+Hex.h"
#import "OPPlotModelBase.h"
#import "OPMarketDataModel.h"

#pragma mark -------K线绘制--------------

@implementation OPPlotDataLayerKLine

@end

@implementation OPPlotAxisYKLine

@end

@implementation OPPlotLayerKLine

- (void)layoutFrame:(CGRect)frame dataLayer:(OPPlotDataLayerKLine *)dataLayer context:(OPPlotSpacesContext *)context
{
    
}

- (void)processMaxMinValueWithDataLayer:(OPPlotDataLayerKLine *)dataLayer context:(OPPlotSpacesContext *)context
{
    long long max                           = 0;
    long long min                           = 0;
    NSInteger fromIndex                     = context.fromIndex;
    NSInteger toIndex                       = context.toIndex;
    OPSecurityTimeModel *model              = nil;
    NSArray *datas                          = dataLayer.datas;
    for (NSInteger i = fromIndex; i <= toIndex; i ++)
    {
        model                               = [datas objectAtIndex:i];
        if (model.highPrice > max)
            max                             = model.highPrice;
        if (model.lowPrice < min)
            min                             = model.lowPrice;
    }
    dataLayer.max                           = max;
    dataLayer.min                           = min;
}

- (void)processFromToIndexWithDataLayer:(OPPlotDataLayerKLine *)dataLayer context:(OPPlotSpacesContext *)context
{
    CGFloat space                           = 1 / context.plotArea;
    int drawCount                           = round(CGRectGetWidth(self.frame) * space);
    context.toIndex                         = MIN(drawCount, [dataLayer.datas count] - 1);
    context.fromIndex                       = MAX(context.toIndex - drawCount, 0);
}

- (NSArray *)buildPlotDataWithDataLayer:(OPPlotDataLayerKLine *)dataLayer context:(OPPlotSpacesContext *)context
{
    if ([dataLayer.datas count] == 0 || context.toIndex == 0)
        return nil;
    
    CGRect rect                             = self.frame;
    CGFloat top                             = CGRectGetMinY(rect);
    CGFloat bottom                          = CGRectGetMaxY(rect);
    long long max                           = dataLayer.max;
    long long min                           = dataLayer.min;
    NSInteger fromIndex                     = context.fromIndex;
    NSInteger toIndex                       = context.toIndex;
    NSArray *datas                          = dataLayer.datas;
    CGFloat x,y;
    OPSecurityTimeModel *model;
    
    //分时均线
    OPPlotPathModel *average                = [[OPPlotPathModel alloc] init];
    average.zIndex                          = OPZIndex_Curve;
    average.lineWidth                       = context.plotWidth;
    average.strokeColor                     = [UIColor hex_colorFromRGB:0xff8800];
    int count                               = (int)(toIndex - fromIndex + 1);
    CGPoint *points                         = malloc(sizeof(CGPoint) * (toIndex - fromIndex + 1));
    CGMutablePathRef averagePath            = CGPathCreateMutable();
    for (NSInteger i = fromIndex; i <= toIndex; i ++)
    {
        model                               = [datas objectAtIndex:i];
        x                                   = [self leftLocationForIndex:i context:context];
        y                                   = [self locationYForValue:model.average withMax:max min:min top:top bottom:bottom];
        
        points[i]                           = CGPointMake(x, y);
    }
    [self _loadCurve:points count:count isBezier:NO path:averagePath];
    free(points);
    average.path                            = averagePath;
    CGPathRelease(averagePath);
    
    //分时线
    OPPlotPathModel *curve                  = [[OPPlotPathModel alloc] init];
    curve.zIndex                            = OPZIndex_Curve + 1;
    curve.lineWidth                         = context.plotWidth;
    curve.strokeColor                       = [UIColor hex_colorFromRGB:0x3e6ac5];
    count                                   = (int)(toIndex - fromIndex + 1);
    points                                  = malloc(sizeof(CGPoint) * (toIndex - fromIndex + 1));
    CGMutablePathRef path                   = CGPathCreateMutable();
    for (NSInteger i = fromIndex; i <= toIndex; i ++)
    {
        model                               = [dataLayer.datas objectAtIndex:i];
        x                                   = [self leftLocationForIndex:i context:context];
        y                                   = [self locationYForValue:model.closePrice withMax:max min:min top:top bottom:bottom];
        
        points[i]                           = CGPointMake(x, y);
    }
    [self _loadCurve:points count:count isBezier:NO path:path];
    curve.path                              = path;
    CGPathRelease(path);
    
    return @[average, curve];
}

- (void)_loadCurve:(CGPoint *)pts count:(int)count isBezier:(BOOL)isBezier path:(CGMutablePathRef)path
{
    if (isBezier)     //平滑曲线，如移动平均线
    {
        int end                             = count - 1;
        CGPathMoveToPoint(path, NULL, pts[0].x, pts[0].y);
        for (int i = 0; i < end; i++)
        {
            CGPathAddQuadCurveToPoint(path, NULL, pts[i].x, pts[i].y, (pts[i].x + pts[i+1].x) * 0.5, (pts[i].y + pts[i+1].y) * 0.5);
        }
        if (end > 0)
            CGPathAddLineToPoint(path, NULL, pts[end].x, pts[end].y);
    }
    else        //非平滑曲线，如KDJ等指标
        CGPathAddLines(path, NULL, pts, count);
}

@end

@implementation OPPlotAxisGridKLine

- (NSArray *)buildPlotDataWithDataLayer:(OPPlotDataLayerKLine *)dataLayer context:(OPPlotSpacesContext *)context
{
    CGRect frame                            = self.frame;
    UIColor *color                          = [UIColor hex_colorFromRGB:0xd6d6d6];
    NSArray *dashPattern                    = @[[NSNumber numberWithFloat:2.], [NSNumber numberWithFloat:2.]];
    //两边横向分割线 虚线
    CGFloat itemHeight                      = frame.size.height * .2;
    OPPlotPathModel *horLine                = [[OPPlotPathModel alloc] init];
    horLine.zIndex                          = OPZIndex_Axis_Line;
    horLine.lineWidth                       = 1.;
    horLine.strokeColor                     = color;
    
    CGMutablePathRef path                   = CGPathCreateMutable();
    for (int i = 1; i <= 4; i ++)
    {
        CGPathAddLines(path, NULL, (CGPoint[]){CGPointMake(CGRectGetMinX(frame), CGRectGetMinY(frame) + itemHeight * i), CGPointMake(CGRectGetMaxX(frame), CGRectGetMinY(frame) + itemHeight * i)}, 2);
    }
    horLine.dashPattern                     = dashPattern;
    horLine.path                            = path;
    
    return @[horLine];
}

@end

@implementation OPPlotSpacesKLine

- (instancetype)init
{
    if (self = [super init])
    {
        UIFont *font                        = [UIFont systemFontOfSize:OPTrend_AxisY_Font];
        OPPlotAxisYKLine *valueAxis         = [[OPPlotAxisYKLine alloc] init];
        valueAxis.axisType                  = OPAxisTypeValue;
        valueAxis.axisLocation              = OPPlotAxisYRightInner;
        valueAxis.labelCount                = 5;
        valueAxis.textFont                  = font;
        self.axesY                          = @[valueAxis];
        
        self.axisGrid                       = [[OPPlotAxisGridKLine alloc] init];
        self.primaryLayer                   = [[OPPlotLayerKLine alloc] init];
    }
    return self;
}

@end

