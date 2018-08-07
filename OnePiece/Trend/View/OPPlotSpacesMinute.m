//
//  OPPlotSpacesMinute.m
//  OnePiece
//
//  Created by Duanwwu on 2016/11/22.
//  Copyright © 2016年 DZH. All rights reserved.
//

#import "OPPlotSpacesMinute.h"
#import "OPMarketPackageImpl.h"
#import "NSString+NumberFormat.h"
#import "OPTrendConstant.h"
#import "NSString+FastDrawing.h"
#import "OPPlotModelBase.h"
#import "UIColor+Hex.h"

@implementation OPPlotDataLayerMinute

@end

#pragma mark -------分时绘制--------------

@implementation OPPlotAxisYMinute

@end

@implementation OPPlotLayerMinute

- (void)layoutFrame:(CGRect)frame dataLayer:(OPPlotDataLayerMinute *)dataLayer context:(OPPlotSpacesContext *)context
{
    if (context)
        context.plotPadding                 = frame.size.width / (dataLayer.totalNum - 1) - context.plotWidth;
}

- (void)processMaxMinValueWithDataLayer:(OPPlotDataLayerMinute *)dataLayer context:(OPPlotSpacesContext *)context
{
    int max                                 = dataLayer.max;
    int min                                 = dataLayer.min;
    int lastClose                           = dataLayer.baseValue;
    int value                               = MAX(ABS(max - lastClose), ABS(min - lastClose));
    
    if (max == 0 && max == 0 && value == lastClose)
        value                               = 28;
    
    if (value < 2)
        value                               = 2;
    
    max                                     = lastClose + value;
    min                                     = lastClose - value;
    
    if (max == min)//如果最大值与最小值相等(停牌或者集合竞价情况)，则涨跌设置为昨收*0.1
    {
        max                                 = roundf(lastClose * 1.1);//lastClose + lastClose * .1
        min                                 = roundf(lastClose * 0.9);//lastClose - lastClose * .1
    }
    dataLayer.max                           = MAX(dataLayer.max, max);
    dataLayer.min                           = MIN(dataLayer.min, min);
}

- (void)processFromToIndexWithDataLayer:(OPPlotDataLayerMinute *)dataLayer context:(OPPlotSpacesContext *)context
{
//    CGFloat space                           = 1 / context.plotArea;
//    int drawCount                           = round(CGRectGetWidth(self.frame) * space);
//    context.toIndex                         = MIN(drawCount, [context.datas count] - 1);
//    context.fromIndex                       = MAX(context.toIndex - drawCount, 0);
    
    context.toIndex                         = MIN(dataLayer.totalNum - 1, [dataLayer.datas count] - 1);
    context.fromIndex                       = 0;
}

- (NSArray *)buildPlotDataWithDataLayer:(OPPlotDataLayerMinute *)dataLayer context:(OPPlotSpacesContext *)context
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
        model                               = [dataLayer.datas objectAtIndex:i];
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
    
    //渐变
    CGColorRef color                        = [UIColor hex_colorFromARGB:0x4d90b7e8].CGColor;
    OPPlotGradientModel *gradient           = [[OPPlotGradientModel alloc] init];
    gradient.zIndex                         = OPZIndex_Curve + 2;
    gradient.gradientColors                 = @[(__bridge id)color, (__bridge id)color];
    gradient.startPoint                     = rect.origin;
    gradient.endPoint                       = CGPointMake(rect.origin.x, bottom);
    CGMutablePathRef gradientPath           = CGPathCreateMutable();
    [self _loadCurve:points count:count isBezier:NO path:gradientPath];
    CGPathAddLineToPoint(gradientPath, NULL, points[count - 1].x, bottom);
    CGPathAddLineToPoint(gradientPath, NULL, points[0].x, bottom);
    CGPathCloseSubpath(gradientPath);
    gradient.gradientPath                   = gradientPath;
    CGPathRelease(gradientPath);
    free(points);
    
    return @[average, curve, gradient];
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

@implementation OPPlotAxisGridMinute

- (NSArray *)buildPlotDataWithDataLayer:(OPPlotDataLayerMinute *)dataLayer context:(OPPlotSpacesContext *)context
{
    CGRect frame                            = self.frame;
    UIColor *color                          = [UIColor hex_colorFromRGB:0xd6d6d6];
    
    //中间横向分割线 实线
    OPPlotPathModel *midHorLine             = [[OPPlotPathModel alloc] init];
    midHorLine.zIndex                       = OPZIndex_Axis_Line;
    midHorLine.lineWidth                    = 1.;
    midHorLine.strokeColor                  = color;
    CGMutablePathRef path                   = CGPathCreateMutable();
    CGPathAddLines(path, NULL, (CGPoint[]){CGPointMake(CGRectGetMinX(frame), CGRectGetMidY(frame)), CGPointMake(CGRectGetMaxX(frame), CGRectGetMidY(frame))}, 2);
    midHorLine.path                         = path;
    CGPathRelease(path);
    
    NSArray *dashPattern                    = @[[NSNumber numberWithFloat:2.], [NSNumber numberWithFloat:2.]];
    //两边横向分割线 虚线
    CGFloat itemHeight                      = frame.size.height * .25;
    OPPlotPathModel *otherHorLine           = [[OPPlotPathModel alloc] init];
    otherHorLine.zIndex                     = OPZIndex_Axis_Line;
    otherHorLine.lineWidth                  = 1.;
    otherHorLine.strokeColor                = color;
    path                                    = CGPathCreateMutable();
    CGPathAddLines(path, NULL, (CGPoint[]){CGPointMake(CGRectGetMinX(frame), CGRectGetMinY(frame) + itemHeight), CGPointMake(CGRectGetMaxX(frame), CGRectGetMinY(frame) + itemHeight)}, 2);
    CGPathAddLines(path, NULL, (CGPoint[]){CGPointMake(CGRectGetMinX(frame), CGRectGetMaxY(frame) - itemHeight), CGPointMake(CGRectGetMaxX(frame), CGRectGetMaxY(frame) - itemHeight)}, 2);
    otherHorLine.dashPattern                = dashPattern;
    otherHorLine.path                       = path;
    
    //纵向分割线
    CGFloat itemWidth                       = frame.size.width * .25;
    OPPlotPathModel *verticalLine           = [[OPPlotPathModel alloc] init];
    verticalLine.zIndex                     = OPZIndex_Axis_Line;
    verticalLine.lineWidth                  = 1.;
    verticalLine.strokeColor                = color;
    path                                    = CGPathCreateMutable();
    CGPathAddLines(path, NULL, (CGPoint[]){CGPointMake(CGRectGetMinX(frame) + itemWidth, CGRectGetMinY(frame)), CGPointMake(CGRectGetMinX(frame) + itemWidth, CGRectGetMaxY(frame))}, 2);
    CGPathAddLines(path, NULL, (CGPoint[]){CGPointMake(CGRectGetMidX(frame), CGRectGetMinY(frame)), CGPointMake(CGRectGetMidX(frame), CGRectGetMaxY(frame))}, 2);
    CGPathAddLines(path, NULL, (CGPoint[]){CGPointMake(CGRectGetMidX(frame) + itemWidth, CGRectGetMinY(frame)), CGPointMake(CGRectGetMidX(frame) + itemWidth, CGRectGetMaxY(frame))}, 2);
    verticalLine.dashPattern                = dashPattern;
    verticalLine.path                       = path;
    return @[midHorLine,otherHorLine,verticalLine];
}

@end

@implementation OPPlotSpacesMinute

- (instancetype)init
{
    if (self = [super init])
    {
        UIFont *font                        = [UIFont systemFontOfSize:OPTrend_AxisY_Font];
        
        OPPlotAxisYMinute *percentageAxis   = [[OPPlotAxisYMinute alloc] init];
        percentageAxis.axisType             = OPAxisTypePercentage;
        percentageAxis.axisLocation         = OPPlotAxisYLeftInner;
        percentageAxis.labelCount           = 2;
        percentageAxis.textFont             = font;
        
        OPPlotAxisYMinute *valueAxis        = [[OPPlotAxisYMinute alloc] init];
        valueAxis.axisType                  = OPAxisTypeValue;
        valueAxis.axisLocation              = OPPlotAxisYRightInner;
        valueAxis.labelCount                = 5;
        valueAxis.textFont                  = font;
        self.axesY                          = @[percentageAxis, valueAxis];
        
        self.axisGrid                       = [[OPPlotAxisGridMinute alloc] init];
        self.primaryLayer                   = [[OPPlotLayerMinute alloc] init];
    }
    return self;
}

- (void)setTotalNum:(int)totalNum
{
    [(OPPlotDataLayerMinute *)self.dataLayer setTotalNum:totalNum];
    [self layoutPlotSpaces];
}

@end

#pragma mark -------分时成交量绘制--------------

@implementation OPPlotAxisYMinuteVolume

- (NSString *)textWithValue:(long long)value baseValue:(long long)baseValue decimal:(short)decimal axisType:(OPAxisType)axisType
{
    return [NSString nf_stringNoZeroWithVolume:value decimal:2];
}

@end

@implementation OPPlotLayerMinuteVolume

- (void)processMaxMinValueWithDataLayer:(OPPlotDataLayerMinute *)dataLayer context:(OPPlotSpacesContext *)context
{
    NSArray *datas                          = dataLayer.datas;
    if ([datas count] == 0)
        return;
    
    NSInteger fromIndex                     = context.fromIndex;
    NSInteger toIndex                       = context.toIndex;
    int max,min;
    max = min                               = [(OPSecurityTimeModel *)[datas objectAtIndex:fromIndex] volume];
    OPSecurityTimeModel *model;
    
    for (NSInteger i = fromIndex + 1; i <= toIndex; i ++)
    {
        model                               = [datas objectAtIndex:i];
        
        if (model.volume > max)
            max                             = model.volume;
        else if (model.volume < min)
            min                             = model.volume;
    }
    
    dataLayer.max                           = max;
    dataLayer.min                           = min;
}

- (NSArray *)buildPlotDataWithDataLayer:(OPPlotDataLayerMinute *)dataLayer context:(OPPlotSpacesContext *)context
{
    if ([dataLayer.datas count] == 0 || context.toIndex == 0)
        return nil;
    
    CGRect rect                             = self.frame;
    CGFloat top                             = CGRectGetMinY(rect);
    CGFloat bottom                          = CGRectGetMaxY(rect);
    int max                                 = dataLayer.max;
    int min                                 = dataLayer.min;
    NSInteger fromIndex                     = context.fromIndex;
    NSInteger toIndex                       = context.toIndex;
    CGFloat x,y;
    OPSecurityTimeModel *model;
    
    int lastPrice                           = dataLayer.baseValue;
    OPPlotPathModel *volumeUp               = [[OPPlotPathModel alloc] init];
    volumeUp.zIndex                         = OPZIndex_Bar;
    volumeUp.lineWidth                      = context.plotWidth;
    volumeUp.strokeColor                    = [UIColor hex_colorFromRGB:0xee2c2c];
    
    OPPlotPathModel *volumeDown             = [[OPPlotPathModel alloc] init];
    volumeDown.zIndex                       = OPZIndex_Bar;
    volumeDown.lineWidth                    = context.plotWidth;
    volumeDown.strokeColor                  = [UIColor hex_colorFromRGB:0x1ca049];
    
    CGMutablePathRef volumeUpPath           = CGPathCreateMutable();
    CGMutablePathRef volumeDownPath         = CGPathCreateMutable();
    for (NSInteger i = fromIndex; i <= toIndex; i ++)
    {
        model                               = [dataLayer.datas objectAtIndex:i];
        x                                   = [self leftLocationForIndex:i context:context];
        y                                   = [self locationYForValue:model.volume withMax:max min:min top:top bottom:bottom];
        if (y != bottom)
        {
            if (model.closePrice >= lastPrice)
                CGPathAddLines(volumeUpPath, NULL, (CGPoint[]){CGPointMake(x, y), CGPointMake(x, bottom)}, 2);
            else
                CGPathAddLines(volumeDownPath, NULL, (CGPoint[]){CGPointMake(x, y), CGPointMake(x, bottom)}, 2);
        }
        lastPrice                           = model.closePrice;
    }
    volumeUp.path                           = volumeUpPath;
    volumeDown.path                         = volumeDownPath;
    CGPathRelease(volumeUpPath);
    CGPathRelease(volumeDownPath);
    
    return @[volumeUp, volumeDown];
}

@end

@implementation OPPlotAxisGridMinuteVolume

- (NSArray *)buildPlotDataWithDataLayer:(OPPlotDataLayer *)dataLayer context:(OPPlotSpacesContext *)context
{
    CGRect frame                            = self.frame;
    
    //横向分割线 虚线
    OPPlotPathModel *horizonLine            = [[OPPlotPathModel alloc] init];
    horizonLine.zIndex                      = OPZIndex_Axis_Line;
    horizonLine.lineWidth                   = 1.;
    horizonLine.strokeColor                 = [UIColor hex_colorFromRGB:0xd6d6d6];
    CGMutablePathRef path                   = CGPathCreateMutable();
    CGPathAddLines(path, NULL, (CGPoint[]){CGPointMake(CGRectGetMinX(frame), CGRectGetMidY(frame)), CGPointMake(CGRectGetMaxX(frame), CGRectGetMidY(frame))}, 2);
    horizonLine.dashPattern                 = @[[NSNumber numberWithFloat:2.], [NSNumber numberWithFloat:2.]];
    horizonLine.path                        = path;
    CGPathRelease(path);
    
    return @[horizonLine];
}

@end

@implementation OPPlotSpacesMinuteVolume

- (instancetype)init
{
    if (self = [super init])
    {
        OPPlotAxisYMinuteVolume *valueAxis  = [[OPPlotAxisYMinuteVolume alloc] init];
        valueAxis.axisType                  = OPAxisTypeValue;
        valueAxis.axisLocation              = OPPlotAxisYRightInner;
        valueAxis.labelCount                = 1;
        valueAxis.textFont                  = [UIFont systemFontOfSize:OPTrend_AxisY_Font];
        self.axesY                          = @[valueAxis];
        
        self.axisGrid                       = [[OPPlotAxisGridMinuteVolume alloc] init];
        self.primaryLayer                   = [[OPPlotLayerMinuteVolume alloc] init];
    }
    return self;
}

@end

#pragma mark -------分时DDX绘制--------------

#define kLevel2HeaderHeight                 20.

@implementation OPPlotLayerMinuteDDX
{
    OPPlotLabelModel                        *_leftDDXLabel;
    OPPlotLabelModel                        *_rightDDXLabel;
}

- (instancetype)init
{
    if (self = [super init])
    {
        UIFont *font                        = [UIFont systemFontOfSize:OPTrend_AxisY_Font];
        UIColor *color                      = [UIColor hex_colorFromRGB:0x9aa4ad];
        
        OPPlotLabelModel *ddxLabel          = [[OPPlotLabelModel alloc] init];
        ddxLabel.zIndex                     = OPZIndex_Axis_Label;
        ddxLabel.textFont                   = font;
        ddxLabel.textColor                  = color;
        ddxLabel.textAlignment              = NSTextAlignmentLeft;
        _leftDDXLabel                       = ddxLabel;
        
        ddxLabel                            = [[OPPlotLabelModel alloc] init];
        ddxLabel.zIndex                     = OPZIndex_Axis_Label;
        ddxLabel.textFont                   = font;
        ddxLabel.textColor                  = color;
        ddxLabel.textAlignment              = NSTextAlignmentLeft;
        _rightDDXLabel                      = ddxLabel;
    }
    return self;
}

- (void)processMaxMinValueWithDataLayer:(OPPlotDataLayer *)dataLayer context:(OPPlotSpacesContext *)context
{
    NSArray *datas                          = dataLayer.datas;
    if ([datas count] == 0)
        return;
    
    NSInteger fromIndex                     = context.fromIndex;
    NSInteger toIndex                       = context.toIndex;
    OPSecurityDDXModel *model               = [datas objectAtIndex:fromIndex];
    int max,min;
    max = min                               = [model ddx];
    
    for (NSInteger i = fromIndex + 1; i <= toIndex; i ++)
    {
        model                               = [datas objectAtIndex:i];
        
        if (model.ddx > max)
            max                             = model.ddx;
        else if (model.ddx < min)
            min                             = model.ddx;
    }
    
    dataLayer.max                           = max;
    dataLayer.min                           = min;
}

- (NSArray *)buildPlotDataWithDataLayer:(OPPlotDataLayer *)dataLayer context:(OPPlotSpacesContext *)context
{
    CGRect rect                             = self.frame;
    _leftDDXLabel.textRect                  = CGRectMake(3., rect.origin.y, rect.size.width * .5 - 3., kLevel2HeaderHeight);
    _rightDDXLabel.textRect                 = CGRectMake(CGRectGetMidX(rect), rect.origin.y, rect.size.width * .5, kLevel2HeaderHeight);
    
    if ([dataLayer.datas count] == 0 || context.toIndex == 0)//无数据时的处理
    {
        _leftDDXLabel.text                  = [NSString stringWithFormat:@"DDX：%@",[NSString nf_stringNoZeroWithPrice:0 decimal:3]];
        _rightDDXLabel.text                 = [NSString stringWithFormat:@"累积：%@",[NSString nf_stringNoZeroWithPrice:0 decimal:3]];
        return @[_leftDDXLabel, _rightDDXLabel];
    }
    
    CGFloat top                             = CGRectGetMinY(rect) + kLevel2HeaderHeight;
    CGFloat bottom                          = CGRectGetMaxY(rect);
    int max                                 = dataLayer.max;
    int min                                 = dataLayer.min;
    NSInteger fromIndex                     = context.fromIndex;
    NSInteger toIndex                       = context.toIndex;
    CGFloat x,y;
    OPSecurityDDXModel *model;
    
    OPPlotPathModel *ddxUp                  = [[OPPlotPathModel alloc] init];
    ddxUp.zIndex                            = OPZIndex_Bar;
    ddxUp.lineWidth                         = context.plotWidth;
    ddxUp.strokeColor                       = [UIColor hex_colorFromRGB:0xee2c2c];
    
    OPPlotPathModel *ddxDown                = [[OPPlotPathModel alloc] init];
    ddxDown.zIndex                          = OPZIndex_Bar;
    ddxDown.lineWidth                       = context.plotWidth;
    ddxDown.strokeColor                     = [UIColor hex_colorFromRGB:0x1ca049];
    
    CGMutablePathRef ddxUpPath              = CGPathCreateMutable();
    CGMutablePathRef ddxDownPath            = CGPathCreateMutable();
    CGFloat y0                              = (top + bottom) * .5;
    for (NSInteger i = fromIndex; i <= toIndex; i ++)
    {
        model                               = [dataLayer.datas objectAtIndex:i];
        x                                   = [self leftLocationForIndex:i context:context];
        if (model.ddx > 0)
        {
            y                           = [self locationYForValue:model.ddx withMax:max min:0 top:top bottom:y0];
            CGPathAddLines(ddxUpPath, NULL, (CGPoint[]){CGPointMake(x, y), CGPointMake(x, y0)}, 2);
        }
        else if (model.ddx < 0)
        {
            y                           = [self locationYForValue:model.ddx withMax:0 min:min top:y0 bottom:bottom];
            CGPathAddLines(ddxDownPath, NULL, (CGPoint[]){CGPointMake(x, y), CGPointMake(x, y0)}, 2);
        }
    }
    ddxUp.path                              = ddxUpPath;
    ddxDown.path                            = ddxDownPath;
    CGPathRelease(ddxUpPath);
    CGPathRelease(ddxDownPath);
    
    _leftDDXLabel.text                      = [NSString stringWithFormat:@"DDX：%@",[NSString nf_stringNoZeroWithPrice:model.ddx decimal:3]];
    _rightDDXLabel.text                     = [NSString stringWithFormat:@"累积：%@",[NSString nf_stringNoZeroWithPrice:model.ddxSum decimal:3]];
    
    return @[ddxUp, ddxDown, _leftDDXLabel, _rightDDXLabel];
}

@end

@implementation OPPlotAxisGridMinuteDDX

- (NSArray *)buildPlotDataWithDataLayer:(OPPlotDataLayer *)dataLayer context:(OPPlotSpacesContext *)context
{
    CGRect frame                            = self.frame;
    frame.origin.y                          += kLevel2HeaderHeight;
    frame.size.height                       -= kLevel2HeaderHeight;
    
    //横向分割线 虚线
    OPPlotPathModel *horizonLine            = [[OPPlotPathModel alloc] init];
    horizonLine.zIndex                      = OPZIndex_Axis_Line;
    horizonLine.lineWidth                   = 1.;
    horizonLine.strokeColor                 = [UIColor hex_colorFromRGB:0xd6d6d6];
    CGMutablePathRef path                   = CGPathCreateMutable();
    CGPathAddLines(path, NULL, (CGPoint[]){CGPointMake(CGRectGetMinX(frame), CGRectGetMidY(frame)), CGPointMake(CGRectGetMaxX(frame), CGRectGetMidY(frame))}, 2);
    horizonLine.dashPattern                 = @[[NSNumber numberWithFloat:2.], [NSNumber numberWithFloat:2.]];
    horizonLine.path                        = path;
    CGPathRelease(path);
    
    return @[horizonLine];
}

@end

@implementation OPPlotSpacesMinuteDDX

- (instancetype)init
{
    if (self = [super init])
    {
        self.axisGrid                       = [[OPPlotAxisGridMinuteDDX alloc] init];
        self.primaryLayer                   = [[OPPlotLayerMinuteDDX alloc] init];
    }
    return self;
}

@end

#pragma mark -------分时成交单数差--------------

@implementation OPPlotLayerOrderDiffer
{
    OPPlotLabelModel                        *_leftLabel;
}

- (instancetype)init
{
    if (self = [super init])
    {
        UIFont *font                        = [UIFont systemFontOfSize:OPTrend_AxisY_Font];
        UIColor *color                      = [UIColor hex_colorFromRGB:0x9aa4ad];
        
        OPPlotLabelModel *label             = [[OPPlotLabelModel alloc] init];
        label.zIndex                        = OPZIndex_Axis_Label;
        label.textFont                      = font;
        label.textColor                     = color;
        label.textAlignment                 = NSTextAlignmentLeft;
        label.text                          = @"主力动向";
        _leftLabel                          = label;
    }
    return self;
}

- (void)processMaxMinValueWithDataLayer:(OPPlotDataLayer *)dataLayer context:(OPPlotSpacesContext *)context
{
    NSArray *datas                          = dataLayer.datas;
    if ([datas count] == 0)
        return;
    
    NSInteger fromIndex                     = context.fromIndex;
    NSInteger toIndex                       = context.toIndex;
    int max,min;
    max = min                               = [[datas objectAtIndex:fromIndex] intValue];
    int value                               = 0;
    
    for (NSInteger i = fromIndex + 1; i <= toIndex; i ++)
    {
        value                               = [[datas objectAtIndex:i] intValue];
        
        if (value > max)
            max                             = value;
        else if (value < min)
            min                             = value;
    }
    
    dataLayer.max                           = max;
    dataLayer.min                           = min;
}

- (NSArray *)buildPlotDataWithDataLayer:(OPPlotDataLayer *)dataLayer context:(OPPlotSpacesContext *)context
{
    CGRect rect                             = self.frame;
    _leftLabel.textRect                     = CGRectMake(3., rect.origin.y, rect.size.width * .5 - 3., kLevel2HeaderHeight);
    
    if ([dataLayer.datas count] == 0 || context.toIndex == 0)//无数据时的处理
        return @[_leftLabel];
    
    CGFloat top                             = CGRectGetMinY(rect);
    CGFloat bottom                          = CGRectGetMaxY(rect);
    int max                                 = dataLayer.max;
    int min                                 = dataLayer.min;
    NSInteger fromIndex                     = context.fromIndex;
    NSInteger toIndex                       = context.toIndex;
    CGFloat x,y;
    
    OPPlotPathModel *upPathModel            = [[OPPlotPathModel alloc] init];
    upPathModel.zIndex                      = OPZIndex_Bar;
    upPathModel.lineWidth                   = context.plotWidth;
    upPathModel.strokeColor                 = [UIColor hex_colorFromRGB:0xee2c2c];
    
    OPPlotPathModel *downPathModel          = [[OPPlotPathModel alloc] init];
    downPathModel.zIndex                    = OPZIndex_Bar;
    downPathModel.lineWidth                 = context.plotWidth;
    downPathModel.strokeColor               = [UIColor hex_colorFromRGB:0x1ca049];
    
    CGMutablePathRef upPath                 = CGPathCreateMutable();
    CGMutablePathRef downPath               = CGPathCreateMutable();
    CGFloat y0                              = [self locationYForValue:0 withMax:max min:min top:top bottom:bottom];
    int value                               = 0;
    
    for (NSInteger i = fromIndex; i <= toIndex; i ++)
    {
        value                               = [[dataLayer.datas objectAtIndex:i] intValue];
        x                                   = [self leftLocationForIndex:i context:context];
        y                                   = [self locationYForValue:value withMax:max min:min top:top bottom:bottom];
        if (y != bottom)
        {
            if (value >= 0)//在0轴上方
                CGPathAddLines(upPath, NULL, (CGPoint[]){CGPointMake(x, y), CGPointMake(x, y0)}, 2);
            else//在0轴下方
                CGPathAddLines(downPath, NULL, (CGPoint[]){CGPointMake(x, y), CGPointMake(x, y0)}, 2);
        }
    }
    upPathModel.path                        = upPath;
    downPathModel.path                      = downPath;
    CGPathRelease(upPath);
    CGPathRelease(downPath);
    
    return @[upPathModel, downPathModel, _leftLabel];
}

@end

@implementation OPPlotSpacesOrderDiffer

- (instancetype)init
{
    if (self = [super init])
    {
        self.primaryLayer                   = [[OPPlotLayerOrderDiffer alloc] init];
    }
    return self;
}

@end

#pragma mark -------分时总买卖量绘制--------------

@implementation OPPlotLayerTotalAskBid
{
    OPPlotLabelModel                        *_leftLabel;
    OPPlotLabelModel                        *_rightLabel;
}

- (instancetype)init
{
    if (self = [super init])
    {
        UIFont *font                        = [UIFont systemFontOfSize:OPTrend_AxisY_Font];
        UIColor *color                      = [UIColor hex_colorFromRGB:0x9aa4ad];
        
        OPPlotLabelModel *label             = [[OPPlotLabelModel alloc] init];
        label.zIndex                        = OPZIndex_Axis_Label;
        label.textFont                      = font;
        label.textColor                     = color;
        label.textAlignment                 = NSTextAlignmentLeft;
        _leftLabel                          = label;
        
        label                               = [[OPPlotLabelModel alloc] init];
        label.zIndex                        = OPZIndex_Axis_Label;
        label.textFont                      = font;
        label.textColor                     = color;
        label.textAlignment                 = NSTextAlignmentLeft;
        _rightLabel                         = label;
    }
    return self;
}

- (void)processMaxMinValueWithDataLayer:(OPPlotDataLayer *)dataLayer context:(OPPlotSpacesContext *)context
{
    NSArray *datas                          = dataLayer.datas;
    if ([datas count] == 0)
        return;
    
    NSInteger fromIndex                     = context.fromIndex;
    NSInteger toIndex                       = context.toIndex;
    
    OPSecurityTotalAskBidModel *model       = [datas objectAtIndex:fromIndex];
    int max                                 = MAX(model.totalBid, model.totalAsk);
    int min                                 = MIN(model.totalBid, model.totalAsk);
    
    for (NSInteger i = fromIndex + 1; i <= toIndex; i ++)
    {
        model                               = [datas objectAtIndex:i];
        
        if (MAX(model.totalAsk, model.totalBid) > max)
            max                             = MAX(model.totalAsk, model.totalBid);
        
        if (MIN(model.totalAsk, model.totalBid) < min)
            min                             = MIN(model.totalAsk, model.totalBid);
    }
    
    dataLayer.max                           = max;
    dataLayer.min                           = min;
}

- (NSArray *)buildPlotDataWithDataLayer:(OPPlotDataLayer *)dataLayer context:(OPPlotSpacesContext *)context
{
    CGRect rect                             = self.frame;
    _leftLabel.textRect                     = CGRectMake(3., rect.origin.y, rect.size.width * .5 - 3., kLevel2HeaderHeight);
    _rightLabel.textRect                    = CGRectMake(CGRectGetMidX(rect), rect.origin.y, rect.size.width * .5, kLevel2HeaderHeight);
    
    if ([dataLayer.datas count] == 0 || context.toIndex == 0)//无数据时的处理
    {
        _leftLabel.text                     = [NSString stringWithFormat:@"总买 %@",[NSString nf_stringNoZeroWithPrice:0 decimal:3]];
        _rightLabel.text                    = [NSString stringWithFormat:@"总卖 %@",[NSString nf_stringNoZeroWithPrice:0 decimal:3]];
        return @[_leftLabel, _rightLabel];
    }
    
    CGFloat top                             = CGRectGetMinY(rect) + kLevel2HeaderHeight;
    CGFloat bottom                          = CGRectGetMaxY(rect) - kLevel2HeaderHeight;
    int max                                 = dataLayer.max;
    int min                                 = dataLayer.min;
    NSInteger fromIndex                     = context.fromIndex;
    NSInteger toIndex                       = context.toIndex;
    CGFloat x,askY,bidY;
    
    OPPlotPathModel *upPathModel            = [[OPPlotPathModel alloc] init];
    upPathModel.zIndex                      = OPZIndex_Bar;
    upPathModel.lineWidth                   = context.plotWidth;
    upPathModel.strokeColor                 = [UIColor hex_colorFromRGB:0xee2c2c];
    
    OPPlotPathModel *downPathModel          = [[OPPlotPathModel alloc] init];
    downPathModel.zIndex                    = OPZIndex_Bar;
    downPathModel.lineWidth                 = context.plotWidth;
    downPathModel.strokeColor               = [UIColor hex_colorFromRGB:0x1ca049];
    
    CGMutablePathRef upPath                 = CGPathCreateMutable();
    CGMutablePathRef downPath               = CGPathCreateMutable();
    OPSecurityTotalAskBidModel *model       = [dataLayer.datas objectAtIndex:fromIndex];
    if (model)
    {
        askY                                = [self locationYForValue:model.totalAsk withMax:max min:min top:top bottom:bottom];
        bidY                                = [self locationYForValue:model.totalBid withMax:max min:min top:top bottom:bottom];
        CGPathMoveToPoint(downPath, NULL, x, askY);
        CGPathMoveToPoint(upPath, NULL, x, bidY);
    }
    
    for (NSInteger i = fromIndex + 1; i <= toIndex; i ++)
    {
        model                               = [dataLayer.datas objectAtIndex:i];
        x                                   = [self leftLocationForIndex:i context:context];
        askY                                = [self locationYForValue:model.totalAsk withMax:max min:min top:top bottom:bottom];
        bidY                                = [self locationYForValue:model.totalBid withMax:max min:min top:top bottom:bottom];
        
        CGPathAddLineToPoint(downPath, NULL, x, askY);
        CGPathAddLineToPoint(upPath, NULL, x, bidY);
    }
    upPathModel.path                        = upPath;
    downPathModel.path                      = downPath;
    CGPathRelease(upPath);
    CGPathRelease(downPath);
    
    _leftLabel.text                         = [NSString stringWithFormat:@"总买 %@",[NSString nf_stringNoZeroWithPrice:model.totalBid decimal:3]];
    _rightLabel.text                        = [NSString stringWithFormat:@"总卖 %@",[NSString nf_stringNoZeroWithPrice:model.totalAsk decimal:3]];
    
    return @[upPathModel, downPathModel, _leftLabel, _rightLabel];
}

@end

@implementation OPPlotSpacesTotalAskBid

- (instancetype)init
{
    if (self = [super init])
    {
        self.primaryLayer                   = [[OPPlotLayerTotalAskBid alloc] init];
    }
    return self;
}

@end
