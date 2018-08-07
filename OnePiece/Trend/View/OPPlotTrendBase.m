//
//  OPPlotTrendBase.m
//  OnePiece
//
//  Created by Duanwwu on 2017/1/18.
//  Copyright © 2017年 DZH. All rights reserved.
//

#import "OPPlotTrendBase.h"
#import "NSString+NumberFormat.h"
#import "OPPlotModelBase.h"
#import "UIColor+Hex.h"
#import "NSString+FastDrawing.h"
#import "OPTrendConstant.h"

@implementation OPPlotViewModelTrend

- (instancetype)initWithPlotSpacesContext:(OPPlotSpacesContext *)context
                           updaterManager:(OPTrendUpdaterManager *)updaterManager
                            securityModel:(OPMarketSecurityModel *)securityModel
{
    if (self = [super init])
    {
        self.context                        = context;
        self.updaterManager                 = updaterManager;
        self.securityModel                  = securityModel;
    }
    return self;
}

@end

@implementation OPPlotDataLayerTrend


@end

@implementation OPPlotAxisYTrend

- (UIEdgeInsets)processAxisWithDataLayer:(OPPlotDataLayerTrend *)dataLayer context:(OPPlotSpacesContext *)context plotSpacesFrame:(CGRect)frame
{
    long long max                           = dataLayer.max;
    long long min                           = dataLayer.min;
    short decimal                           = dataLayer.decimal;
    int baseValue                           = dataLayer.baseValue;
    OPAxisType axisType                     = self.axisType;
    
    UIEdgeInsets insets                     = UIEdgeInsetsZero;
    UIFont *axisFont                        = self.textFont;
    
    CGSize axisSize                         = [self axisTextSizeWithMax:max min:min baseValue:baseValue decimal:decimal axisFont:axisFont axisType:axisType];
    CGFloat axisWidth                       = self.fixedWidth != 0 ? self.fixedWidth : axisSize.width + 5.;//判断使用固定宽度还是动态宽度
    NSTextAlignment alignment               = NSTextAlignmentCenter;
    switch (self.axisLocation)
    {
        case OPPlotAxisYLeftOuter:
            self.frame                      = CGRectMake(frame.origin.x, frame.origin.y, axisWidth, frame.size.height);
            insets.left                     = axisWidth;
            alignment                       = NSTextAlignmentRight;
            break;
        case OPPlotAxisYRightOuter:
            self.frame                      = CGRectMake(CGRectGetMaxX(frame) - axisWidth, frame.origin.y, axisWidth, frame.size.height);
            insets.right                    = axisWidth;
            alignment                       = NSTextAlignmentLeft;
            break;
        case OPPlotAxisYRightOuterReverse:
            self.frame                      = CGRectMake(CGRectGetMaxX(frame) - axisWidth, frame.origin.y, axisWidth, frame.size.height);
            insets.right                    = axisWidth;
            alignment                       = NSTextAlignmentRight;
            break;
        case OPPlotAxisYLeftInner:
            self.frame                      = CGRectMake(frame.origin.x, frame.origin.y, axisWidth, frame.size.height);
            alignment                       = NSTextAlignmentLeft;
            break;
        case OPPlotAxisYRightInner:
            self.frame                      = CGRectMake(CGRectGetMaxX(frame) - axisWidth, frame.origin.y, axisWidth, frame.size.height);
            alignment                       = NSTextAlignmentRight;
            break;
        default:
            break;
    }
    
    int count                               = self.labelCount;
    long long strid                         = count == 1 ? 0 : (max - min) / (count - 1);//每一个坐标轴值的跨度
    NSMutableArray *labels                  = [NSMutableArray arrayWithCapacity:count];
    OPPlotLabelModel *label                 = nil;
    for (int i = 0; i < count; i ++)
    {
        label                               = [[OPPlotLabelModel alloc] init];
        label.zIndex                        = OPZIndex_Axis_Label;
        long long value                     = 0;
        if (i == 0)
            value                           = max;
        else if (i == count - 1)
            value                           = min;
        else
            value                           = max - strid * i;
        
        label.textAlignment                 = alignment;
        label.text                          = [self textWithValue:value baseValue:baseValue decimal:decimal axisType:axisType];
        label.textRect                      = CGRectMake(.0, .0, axisWidth, axisSize.height);
        label.textFont                      = axisFont;
        label.textColor                     = ColorWithPriceChange(baseValue, value);
        [labels addObject:label];
    }
    self.labels                             = labels;
    return insets;
}

- (NSArray *)buildPlotDataWithDataLayer:(OPPlotDataLayer *)dataLayer context:(OPPlotSpacesContext *)context
{
    CGFloat y                               = .0;
    CGRect frame                            = self.frame;
    int count                               = self.labelCount;
    int strid                               = frame.size.height / (count - 1);//每一个坐标轴值的跨度
    CGRect textRect;
    for (int i = 0; i < count; i ++)
    {
        OPPlotLabelModel *label             = [self.labels objectAtIndex:i];
        textRect                            = label.textRect;
        if (i == 0)
            y                               = CGRectGetMinY(frame);
        else if (i == count - 1)
            y                               = CGRectGetMaxY(frame) - textRect.size.height;
        else
            y                               = CGRectGetMinY(frame) + strid * i - textRect.size.height * .5;
        
        textRect.origin.x                   = frame.origin.x;
        textRect.origin.y                   = y;
        label.textRect                      = textRect;
    }
    return self.labels;
}

#pragma mark - 坐标文本生成和计算尺寸

- (CGSize)axisTextSizeWithMax:(long long)max min:(long long)min baseValue:(long long)baseValue decimal:(short)decimal axisFont:(UIFont *)axisFont axisType:(OPAxisType)axisType
{
    CGSize maxValueSize                     = [[self textWithValue:max baseValue:baseValue decimal:decimal axisType:axisType] fd_sizeWithFont:axisFont];
    CGSize minValueSize                     = [[self textWithValue:min baseValue:baseValue decimal:decimal axisType:axisType] fd_sizeWithFont:axisFont];
    return maxValueSize.width > minValueSize.width ? maxValueSize : minValueSize;
}

- (NSString *)textWithValue:(long long)value baseValue:(long long)baseValue decimal:(short)decimal axisType:(OPAxisType)axisType
{
    return axisType == OPAxisTypePercentage ? [NSString nf_stringPercentageWithValue:value baseValue:baseValue decimal:decimal] : [NSString nf_stringNoZeroWithPrice:value decimal:decimal];
}

@end
