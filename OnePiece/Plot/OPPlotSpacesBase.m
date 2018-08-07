//
//  OPPlotSpacesBase.m
//  OnePiece
//
//  Created by Duanwwu on 2016/11/21.
//  Copyright © 2016年 DZH. All rights reserved.
//

#import "OPPlotSpacesBase.h"
#import "OPPlotModelBase.h"

@implementation OPPlotSpacesContext

- (void)setPlotWidth:(CGFloat)plotWidth
{
    _plotWidth                              = plotWidth;
    _plotArea                               = plotWidth + _plotPadding;
}

- (void)setPlotPadding:(CGFloat)plotPadding
{
    _plotPadding                            = plotPadding;
    _plotArea                               = _plotWidth + plotPadding;
}

@end

@implementation OPPlotDataLayer

@end

@implementation OPPlotBase

- (NSArray *)buildPlotDataWithDataLayer:(OPPlotDataLayer *)dataLayer context:(OPPlotSpacesContext *)context
{
    return nil;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%p %@", self, NSStringFromCGRect(self.frame)];
}

@end

@implementation OPPlotAxis

- (UIEdgeInsets)processAxisWithDataLayer:(OPPlotDataLayer *)dataLayer context:(OPPlotSpacesContext *)context plotSpacesFrame:(CGRect)frame
{
    return UIEdgeInsetsZero;
}

@end

@implementation OPPlotAxisX

@end

@implementation OPPlotAxisY

@end

@implementation OPPlotAxisGrid


@end

#pragma mark -------绘制层-------

@implementation OPPlotLayer

- (void)processMaxMinValueWithDataLayer:(OPPlotDataLayer *)dataLayer context:(OPPlotSpacesContext *)context
{
    
}

- (void)layoutFrame:(CGRect)frame dataLayer:(OPPlotDataLayer *)dataLayer context:(OPPlotSpacesContext *)context
{
    
}

#pragma mark -------数据与坐标转换方法--------------

- (CGFloat)widthForDataCount:(NSUInteger)count context:(OPPlotSpacesContext *)context
{
    return count * context.plotArea;
}

- (CGFloat)leftLocationForIndex:(NSUInteger)index context:(OPPlotSpacesContext *)context
{
    return CGRectGetMinX(self.frame) + index * context.plotArea;
}

- (CGFloat)centerLocationForIndex:(NSUInteger)index context:(OPPlotSpacesContext *)context
{
    return CGRectGetMinX(self.frame) + index * context.plotArea + context.plotWidth * .5;
}

- (CGFloat)rightLocationForIndex:(NSUInteger)index context:(OPPlotSpacesContext *)context
{
    return CGRectGetMinX(self.frame) + (index + 1) * context.plotArea;
}

- (NSUInteger)nearIndexForLocation:(CGFloat)position context:(OPPlotSpacesContext *)context
{
    return MAX(context.fromIndex, MIN((position - CGRectGetMinX(self.frame)) / context.plotArea, context.toIndex));
}

- (CGFloat)locationYForValue:(long long)v withMax:(long long)max min:(long long)min top:(CGFloat)top bottom:(CGFloat)bottom
{
    if (max == min)
        return bottom;
    else if (v <= max && v >= min)
        return bottom - (v - min) * (bottom - top) / (max - min);
    else if (v < min)
        return bottom;
    else
        return top;
}

@end

@implementation OPPlotLayerPrimary

- (void)processMaxMinValueWithDataLayer:(OPPlotDataLayer *)dataLayer context:(OPPlotSpacesContext *)context
{
    
}

- (void)processFromToIndexWithDataLayer:(OPPlotDataLayer *)dataLayer context:(OPPlotSpacesContext *)context
{
    
}

@end

@interface OPPlotSpacesBase ()

@property (nonatomic, strong) NSArray *plotDatas;//最终的绘制数据
@property (nonatomic, strong) NSMutableDictionary *plotLayers;//绘制层集合@[plotLayerKey:OPPlotLayer]

@end

@implementation OPPlotSpacesBase

- (instancetype)init
{
    if (self = [super init])
    {
        self.padding                        = UIEdgeInsetsMake(1., 1., 1., 1.);
        self.plotLayers                     = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    OPPlotSpacesBase *base                  = [self init];
    base.frame                              = frame;
    return base;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%p %@", self, NSStringFromCGRect(self.frame)];
}

- (void)drawRect:(CGRect)rect withContext:(CGContextRef)context
{
    for (OPPlotModelBase *data in self.plotDatas)
    {
        [data drawWithContext:context];
    }
}

#pragma mark --------------图表布局--------------

- (void)setFrame:(CGRect)frame
{
    if (!CGRectEqualToRect(_frame, frame))
    {
        _frame                              = frame;
        [self layoutPlotSpaces];
    }
}

- (void)setAxisInsets:(UIEdgeInsets)axisInsets
{
    if (!UIEdgeInsetsEqualToEdgeInsets(_axisInsets, axisInsets))
    {
        _axisInsets                         = axisInsets;
        [self layoutPlotSpaces];
    }
}

- (void)setPadding:(UIEdgeInsets)padding
{
    if (!UIEdgeInsetsEqualToEdgeInsets(_padding, padding))
    {
        _padding                            = padding;
        [self layoutPlotSpaces];
    }
}

- (void)setPrimaryLayer:(OPPlotLayerPrimary *)primaryLayer
{
    if (_primaryLayer != primaryLayer)
    {
        _primaryLayer                       = primaryLayer;
        [self layoutPlotSpaces];
    }
}

- (void)setAxesX:(NSArray *)axesX
{
    if (_axesX != axesX)
    {
        _axesX                              = axesX;
        [self layoutPlotSpaces];
    }
}

- (void)setAxesY:(NSArray *)axesY
{
    if (_axesY != axesY)
    {
        _axesY                              = axesY;
        [self layoutPlotSpaces];
    }
}

- (void)setAxisGrid:(OPPlotAxisGrid *)axisGrid
{
    if (_axisGrid != axisGrid)
    {
        _axisGrid                           = axisGrid;
        [self layoutPlotSpaces];
    }
}

- (void)addPlotLayer:(OPPlotLayer *)plotLayer forKey:(NSString *)key
{
    [self.plotLayers setObject:plotLayer forKey:key];
    [self layoutPlotSpaces];
}

- (void)removePlotLayerForKey:(NSString *)key
{
    [self.plotLayers removeObjectForKey:key];
    [self layoutPlotSpaces];
}

- (void)layoutPlotSpaces
{
    OPPlotSpacesContext *context            = self.context;
    OPPlotDataLayer *dataLayer              = self.dataLayer;
    
    CGRect frame                            = self.frame;
    UIEdgeInsets axis                       = self.axisInsets;
    UIEdgeInsets padding                    = self.padding;
    CGRect drawingFrame                     = CGRectMake(frame.origin.x + axis.left + padding.left, frame.origin.y + axis.top + padding.top, frame.size.width - axis.left - padding.left - axis.right - padding.right, frame.size.height - axis.top - padding.top - axis.bottom - padding.bottom);
    
    [self.primaryLayer layoutFrame:drawingFrame dataLayer:dataLayer context:context];
    self.primaryLayer.frame                 = drawingFrame;
    
    self.axisGrid.frame                     = frame;
    self.axisGrid.axisInsets                = axis;
    [self.plotLayers enumerateKeysAndObjectsUsingBlock:^(NSString *key, OPPlotLayer *layer, BOOL * _Nonnull stop) {
        
        [layer layoutFrame:drawingFrame dataLayer:dataLayer context:context];
        layer.frame                         = drawingFrame;
    }];
}

#pragma mark --------------数据预处理过程--------------

- (void)processingData
{
    //计算开始索引、结束索引
    [self processIndexRange];
    
    //计算最大值、最小值
    [self processMaxMin];
    
    //计算X坐标轴数据
    [self processAxesXData];
    
    //计算Y坐标轴数据
    [self processAxesYData];
    
    //计算坐标轴网格
    [self processAxisGrid];
    
    //计算绘制层数据
    [self processPlotLayer];
}

//计算绘制的索引范围，会调用[self.primaryDrawing calculateFromToIndex]
- (void)processIndexRange
{
    [self.primaryLayer processFromToIndexWithDataLayer:self.dataLayer context:self.context];
}

//计算最大值最小值，会先调用主体绘制层计算出初步的最大值最小值，再遍历绘制层看有无需要进行校准。
- (void)processMaxMin
{
    OPPlotSpacesContext *context            = self.context;
    OPPlotDataLayer *dataLayer              = self.dataLayer;
    [self.primaryLayer processMaxMinValueWithDataLayer:dataLayer context:context];
    
    [self.plotLayers enumerateKeysAndObjectsUsingBlock:^(NSString *key, OPPlotLayer *layer, BOOL * _Nonnull stop) {
        
        [layer processMaxMinValueWithDataLayer:dataLayer context:context];
    }];
    
    if ([self.delegate respondsToSelector:@selector(afterProcessMaxMin:)])
        [self.delegate afterProcessMaxMin:dataLayer];
}

//计算x轴数据
- (void)processAxesXData
{
    
}

//计算y轴数据
- (void)processAxesYData
{
    if ([self.axesY count] == 0)
        return;
    
    OPPlotSpacesContext *context            = self.context;
    OPPlotDataLayer *dataLayer              = self.dataLayer;
    CGRect frame                            = self.frame;
    UIEdgeInsets axisInsets                 = UIEdgeInsetsZero;
    for (OPPlotAxisY *axis in self.axesY)
    {@autoreleasepool{
        UIEdgeInsets insets                 = [axis processAxisWithDataLayer:dataLayer context:context plotSpacesFrame:frame];
        axisInsets                          = UIEdgeInsetsMake(MAX(axisInsets.top, insets.top), MAX(axisInsets.left, insets.left), MAX(axisInsets.bottom, insets.bottom), MAX(axisInsets.right, insets.right));
    }}
    //调整坐标轴区域
    self.axisInsets                         = axisInsets;
}

- (void)processAxisGrid
{
    
}

//计算绘制层数据
- (void)processPlotLayer
{
    
}

#pragma mark -------数据转换过程--------------

- (void)buildPlotDatas
{
    OPPlotSpacesContext *spacesContext      = self.context;
    OPPlotDataLayer *dataLayer              = self.dataLayer;
    NSMutableArray *plots                   = [NSMutableArray array];
    NSArray *arr                            = nil;
    
    //x轴
    for (OPPlotAxisX *axisX in self.axesX)
    {
        arr                                 = [axisX buildPlotDataWithDataLayer:dataLayer context:spacesContext];
        if ([arr count] > 0)
            [plots addObjectsFromArray:arr];
    }
    
    //y轴
    for (OPPlotAxisY *axisY in self.axesY)
    {
        arr                                 = [axisY buildPlotDataWithDataLayer:dataLayer context:spacesContext];
        if ([arr count] > 0)
            [plots addObjectsFromArray:arr];
    }
    
    //坐标轴
    arr                                     = [self.axisGrid buildPlotDataWithDataLayer:dataLayer context:spacesContext];
    if ([arr count] > 0)
        [plots addObjectsFromArray:arr];
    
    //主体绘制层
    arr                                     = [self.primaryLayer buildPlotDataWithDataLayer:dataLayer context:spacesContext];
    if ([arr count] > 0)
            [plots addObjectsFromArray:arr];
    
    //其它绘制层
    for (OPPlotLayer *plotLayer in self.plotLayers)
    {
        arr                                 = [plotLayer buildPlotDataWithDataLayer:dataLayer context:spacesContext];
        if ([arr count] > 0)
            [plots addObjectsFromArray:arr];
    }
    
    //按zIndex进行排序
    [arr sortedArrayUsingComparator:^NSComparisonResult(OPPlotModelBase *obj1, OPPlotModelBase *obj2) {
        
        return obj1.zIndex > obj2.zIndex ? NSOrderedDescending : (obj1.zIndex == obj2.zIndex ? NSOrderedSame : NSOrderedAscending);
    }];
    self.plotDatas                          = plots;
}

@end
