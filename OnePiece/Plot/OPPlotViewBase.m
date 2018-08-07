//
//  OPPlotViewBase.m
//  OnePiece
//
//  Created by Duanwwu on 2016/12/21.
//  Copyright © 2016年 DZH. All rights reserved.
//

#import "OPPlotViewBase.h"
#import <objc/runtime.h>

@implementation OPFrameModel

- (instancetype)initWithX:(OPFrameValue)x y:(OPFrameValue)y width:(OPFrameValue)width height:(OPFrameValue)height
{
    if (self = [super init])
    {
        self.x                              = x;
        self.y                              = y;
        self.width                          = width;
        self.height                         = height;
    }
    return self;
}

+ (instancetype)full
{
    OPFrameModel *model                     = [[OPFrameModel alloc] initWithX:OPFrameValueMake(YES, 0.) y:OPFrameValueMake(YES, 0.) width:OPFrameValueMake(NO, 1.) height:OPFrameValueMake(NO, 1.)];
    return model;
}

- (CGRect)frameWithParentBounds:(CGRect)bounds
{
    CGRect region                           = CGRectZero;
    OPFrameValue value                      = self.x;
    region.origin.x                         = value.fix ? value.value : bounds.size.width * value.value;
 
    value                                   = self.y;
    region.origin.y                         = value.fix ? value.value : bounds.size.height * value.value;
    
    value                                   = self.width;
    region.size.width                       = value.fix ? value.value : bounds.size.width * value.value;
    
    value                                   = self.height;
    region.size.height                      = value.fix ? value.value : bounds.size.height * value.value;
    
    return region;
}

@end

@implementation OPPlotSpacesBase (Autoresize)

- (OPFrameModel *)frameModel
{
    return objc_getAssociatedObject(self, @selector(frameModel));
}

- (void)setFrameModel:(OPFrameModel *)frameModel
{
    objc_setAssociatedObject(self, @selector(frameModel), frameModel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

@implementation OPPlotViewModelBase
{
    NSMutableArray                          *_plotSpaceses;
}

@synthesize plotSpaceses                    = _plotSpaceses;

- (instancetype)init
{
    if (self = [super init])
    {
        _plotSpaceses                       = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)drawPlot
{
    for (OPPlotSpacesBase *plotSpaces in _plotSpaceses)
    {
        [plotSpaces processingData];
        [plotSpaces buildPlotDatas];
    }
    
    if ([NSThread isMainThread])
    {
        [self.view setNeedsDisplay];
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.view setNeedsDisplay];
        });
    }
}

- (void)addPlotSpacesArray:(NSArray *)plotSpaces
{
    [_plotSpaceses addObjectsFromArray:plotSpaces];
    [self drawPlot];
}

- (void)addPlotSpaces:(OPPlotSpacesBase *)plotSpaces
{
    [_plotSpaceses addObject:plotSpaces];
    [self drawPlot];
}

- (void)removePlotSpaces:(OPPlotSpacesBase *)plotSpaces
{
    [_plotSpaceses removeObject:plotSpaces];
    [self drawPlot];
}

- (void)replacePlotSpaces:(OPPlotSpacesBase *)plotSpaces withPlotSpaces:(OPPlotSpacesBase *)otherPlotSpaces
{
    NSInteger idx                           = [_plotSpaceses indexOfObject:plotSpaces];
    if (idx != NSNotFound)
    {
        [_plotSpaceses replaceObjectAtIndex:idx withObject:otherPlotSpaces];
        [self drawPlot];
    }
}

- (void)resizeViewBounds:(CGRect)bounds
{
    for (OPPlotSpacesBase *plotSpaces in _plotSpaceses)
    {
        if (plotSpaces.frameModel)
        {
            plotSpaces.frame                = [plotSpaces.frameModel frameWithParentBounds:bounds];
        }
    }
}

- (void)addToView:(UIView *)view
{
    
}

- (void)removeFromView:(UIView *)view
{
    
}

@end

@implementation OPPlotViewBase

- (instancetype)initWithFrame:(CGRect)frame plotViewModel:(OPPlotViewModelBase *)viewModel
{
    if (self = [super initWithFrame:frame])
    {
        self.viewModel                      = viewModel;
        self.clearsContextBeforeDrawing     = YES;
        self.backgroundColor                = [UIColor clearColor];
    }
    return self;
}

- (void)setViewModel:(OPPlotViewModelBase *)viewModel
{
    if (_viewModel != viewModel)
    {
         [_viewModel removeFromView:self];
        
        _viewModel                          = viewModel;
        viewModel.view                      = self;
        
        [viewModel addToView:self];
        [self.viewModel resizeViewBounds:self.bounds];
    }
}

- (void)setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
    [self.viewModel resizeViewBounds:bounds];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context                    = UIGraphicsGetCurrentContext();
    [self.viewModel.plotSpaceses enumerateObjectsUsingBlock:^(OPPlotSpacesBase *plot, NSUInteger idx, BOOL * _Nonnull stop) {
        [plot drawRect:rect withContext:context];
    }];
}

@end
