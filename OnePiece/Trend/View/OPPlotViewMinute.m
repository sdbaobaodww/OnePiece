//
//  OPPlotViewMinute.m
//  OnePiece
//
//  Created by Duanwwu on 2016/12/22.
//  Copyright © 2016年 DZH. All rights reserved.
//

#import "OPPlotViewMinute.h"
#import "OPPlotSpacesMinute.h"
#import "OPTrendDataUpdater.h"

@interface OPPlotViewModelMinute () <UIGestureRecognizerDelegate>

@end

@implementation OPPlotViewModelMinute
{
    OPPlotSpacesMinute                          *_plotSpaces;
    OPPlotDataLayerMinute                       *_dataLayer;
    NSMutableArray                              *_dataObservers;
    
    UITapGestureRecognizer                      *_tapGesture;
    UILongPressGestureRecognizer                *_longGesture;
}

- (instancetype)initWithPlotSpacesContext:(OPPlotSpacesContext *)context
                           updaterManager:(OPTrendUpdaterManager *)updaterManager
                            securityModel:(OPMarketSecurityModel *)securityModel
{
    if (self = [super initWithPlotSpacesContext:context updaterManager:updaterManager securityModel:securityModel])
    {
        self.securityModel                      = securityModel;
        _dataLayer                              = [[OPPlotDataLayerMinute alloc] init];
        _dataLayer.decimal                      = 2;
        
        OPPlotSpacesMinute *minutePlotSpaces    = [[OPPlotSpacesMinute alloc] init];
        minutePlotSpaces.frameModel             = [OPFrameModel full];
        minutePlotSpaces.context                = context;
        minutePlotSpaces.dataLayer              = _dataLayer;
        [self addPlotSpaces:minutePlotSpaces];
        _plotSpaces                             = minutePlotSpaces;
        
        __weak typeof(self) wself               = self;
        //静态数据请求
        OPDataUpdaterBase *updater              = [[OPDataUpdaterStatic alloc] initWithSecurityModel:securityModel];
        updater.updateCompleted                 = ^(OPDataUpdaterStatic *updater){
            
            [wself _receiveStaicData:updater.staticData];
        };
        [updaterManager addDateUpdater:updater];
        
        //动态数据请求
        updater                                 = [[OPDataUpdaterDynamic alloc] initWithSecurityModel:securityModel];
        updater.updateCompleted                 = ^(OPDataUpdaterDynamic *updater){
            
            [wself _receiveDynamicData:updater.dynamicData];
        };
        [updaterManager addDateUpdater:updater];
        
        //分时数据请求
        OPDataUpdaterMinute *minuteUpdater      = [[OPDataUpdaterMinute alloc] initWithSecurityModel:securityModel];
        minuteUpdater.updateCompleted           = ^(OPDataUpdaterMinute *updater){
            
            [wself _receiveMinuteData:updater];
        };
        [updaterManager addDateUpdater:minuteUpdater];
        
        _dataObservers                          = [[NSMutableArray alloc] init];
        _tapGesture                             = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_tapView:)];
        _tapGesture.delegate                    = self;
        
        _longGesture                            = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(_longPressView:)];
        _longGesture.delegate                   = self;
        _longGesture.minimumPressDuration       = .2;
        [_tapGesture requireGestureRecognizerToFail:_longGesture];
    }
    return self;
}

- (void)addToView:(UIView *)view
{
    [view addGestureRecognizer:_tapGesture];
    [view addGestureRecognizer:_longGesture];
}

- (void)removeFromView:(UIView *)view
{
    [view removeGestureRecognizer:_tapGesture];
    [view removeGestureRecognizer:_longGesture];
}

- (void)_tapView:(UITapGestureRecognizer *)gesture
{
    
}

- (void)_longPressView:(UILongPressGestureRecognizer *)gesture
{
    
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return [NSStringFromClass([touch.view class]) isEqualToString:@"UIButton"] ? NO : YES;
}

- (void)setLastClose:(int)lastClose decimal:(int)decimal
{
    _dataLayer.baseValue                        = lastClose;
    _dataLayer.decimal                          = decimal;
}

- (void)setMax:(int)max min:(int)min
{
    _dataLayer.max                              = max;
    _dataLayer.min                              = min;
}

- (void)_receiveStaicData:(OPResponsePackage2939 *)staticData
{
    [self.securityModel updateWithStaticData:staticData];
    [self setLastClose:staticData.lastClose decimal:staticData.decimal];
}

- (void)_receiveDynamicData:(OPResponsePackage2940 *)dynamicData
{
    [self.securityModel updateWithDynamicData:dynamicData];
    [self setMax:dynamicData.high min:dynamicData.low];
}

- (void)_receiveMinuteData:(OPDataUpdaterMinute *)minuteData
{
    if (minuteData.totalNum != 0)
        _plotSpaces.totalNum                    = minuteData.totalNum;
    
    NSArray *minutes                            = minuteData.minutes;
    _dataLayer.datas                            = minutes;
    
    if (minuteData.isReset)//分时重置
    {
        for (id<OPPlotViewModelMinuteObserver> observer in _dataObservers)
            [observer resetMinuteData];
    }
    
    for (id<OPPlotViewModelMinuteObserver> observer in _dataObservers)
        [observer receiveMinuteData:minutes];
}

- (void)addMinuteObserver:(id<OPPlotViewModelMinuteObserver>)dataObserver
{
    [_dataObservers addObject:dataObserver];
}

- (void)removeMinuteObserver:(id<OPPlotViewModelMinuteObserver>)dataObserver
{
    [_dataObservers removeObject:dataObserver];
}

@end

@implementation OPPlotViewMinute

@end

@interface OPPlotViewModelMinuteVolume () <UIGestureRecognizerDelegate>

@end

@implementation OPPlotViewModelMinuteVolume
{
    OPPlotSpacesMinuteVolume                    *_plotSpaces;
    OPPlotDataLayerMinute                       *_dataLayer;
    UITapGestureRecognizer                      *_tapGesture;
}

- (instancetype)initWithPlotSpacesContext:(OPPlotSpacesContext *)context
                           updaterManager:(OPTrendUpdaterManager *)updaterManager
                            securityModel:(OPMarketSecurityModel *)securityModel
{
    if (self = [super initWithPlotSpacesContext:context updaterManager:updaterManager securityModel:securityModel])
    {
        _dataLayer                              = [[OPPlotDataLayerMinute alloc] init];
        
        OPPlotSpacesMinuteVolume *plotSpaces    = [[OPPlotSpacesMinuteVolume alloc] init];
        plotSpaces.frameModel                   = [OPFrameModel full];
        plotSpaces.context                      = context;
        plotSpaces.dataLayer                    = _dataLayer;
        [self addPlotSpaces:plotSpaces];
        _plotSpaces                             = plotSpaces;
        
        _tapGesture                             = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_tapView:)];
        _tapGesture.delegate                    = self;
    }
    return self;
}

- (void)addToView:(UIView *)view
{
    [view addGestureRecognizer:_tapGesture];
}

- (void)removeFromView:(UIView *)view
{
    [view removeGestureRecognizer:_tapGesture];
}

- (void)_tapView:(UITapGestureRecognizer *)gesture
{
    
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return [NSStringFromClass([touch.view class]) isEqualToString:@"UIButton"] ? NO : YES;
}

- (void)setLastClose:(int)lastClose
{
    _dataLayer.baseValue                        = lastClose;
}

#pragma mark - OPPlotViewModelMinuteDataObserver

- (void)resetMinuteData
{
    
}

- (void)receiveMinuteData:(NSArray *)minutes
{
    _dataLayer.datas                            = minutes;
}

@end

@implementation OPPlotViewMinuteVolume

@end

@implementation OPPlotViewModelCombine
{
    OPPlotSpacesMinute                          *_minutePlotSpaces;
    OPPlotDataLayerMinute                       *_minuteDataLayer;
    
    OPPlotSpacesMinuteVolume                    *_volumePlotSpaces;
    OPPlotDataLayerMinute                       *_volumeDataLayer;
}

- (instancetype)initWithPlotSpacesContext:(OPPlotSpacesContext *)context
                           updaterManager:(OPTrendUpdaterManager *)updaterManager
                            securityModel:(OPMarketSecurityModel *)securityModel
{
    if (self = [super initWithPlotSpacesContext:context updaterManager:updaterManager securityModel:securityModel])
    {
        _minuteDataLayer                        = [[OPPlotDataLayerMinute alloc] init];
        _minuteDataLayer.decimal                = 2;
        
        OPPlotSpacesMinute *minutePlotSpaces    = [[OPPlotSpacesMinute alloc] init];
        minutePlotSpaces.frameModel             = [OPFrameModel full];
        minutePlotSpaces.context                = context;
        minutePlotSpaces.dataLayer              = _minuteDataLayer;
        [self addPlotSpaces:minutePlotSpaces];
        _minutePlotSpaces                       = minutePlotSpaces;
        
        _volumeDataLayer                        = [[OPPlotDataLayerMinute alloc] init];
        
        OPPlotSpacesMinuteVolume *volume        = [[OPPlotSpacesMinuteVolume alloc] init];
        volume.axesY                            = nil;
        volume.frameModel                       = [[OPFrameModel alloc] initWithX:OPFrameValueMake(YES, .0) y:OPFrameValueMake(NO, .5) width:OPFrameValueMake(NO, 1.) height:OPFrameValueMake(NO, .5)];
        volume.context                          = context;
        volume.dataLayer                        = _volumeDataLayer;
        [self addPlotSpaces:volume];
        _volumePlotSpaces                       = volume;
        
        __weak typeof(self) wself               = self;
        //静态数据请求
        OPDataUpdaterBase *updater              = [[OPDataUpdaterStatic alloc] initWithSecurityModel:securityModel];
        updater.updateCompleted                 = ^(OPDataUpdaterStatic *updater){
            
            [wself _receiveStaicData:updater.staticData];
        };
        [updaterManager addDateUpdater:updater];
        
        //动态数据请求
        updater                                 = [[OPDataUpdaterDynamic alloc] initWithSecurityModel:securityModel];
        updater.updateCompleted                 = ^(OPDataUpdaterDynamic *updater){
            
            [wself _receiveDynamicData:updater.dynamicData];
        };
        [updaterManager addDateUpdater:updater];
        
        OPDataUpdaterMinute *minuteUpdater      = [[OPDataUpdaterMinute alloc] initWithSecurityModel:securityModel];
        minuteUpdater.updateCompleted           = ^(OPDataUpdaterMinute *updater){
            
            [wself _receiveMinuteData:updater];
        };
        [updaterManager addDateUpdater:minuteUpdater];
    }
    return self;
}

- (void)_receiveMinuteData:(OPDataUpdaterMinute *)minuteData
{
    if (minuteData.totalNum != 0)
        _minutePlotSpaces.totalNum              = minuteData.totalNum;
    
    NSArray *minutes                            = minuteData.minutes;
    _minuteDataLayer.datas                      = minutes;
    _volumeDataLayer.datas                      = minutes;
}

- (void)setLastClose:(int)lastClose decimal:(int)decimal
{
    _minuteDataLayer.baseValue                  = lastClose;
    _minuteDataLayer.decimal                    = decimal;
    _volumeDataLayer.baseValue                  = lastClose;
}

- (void)setMax:(int)max min:(int)min
{
    _minuteDataLayer.max                        = max;
    _minuteDataLayer.min                        = min;
}

- (void)_receiveStaicData:(OPResponsePackage2939 *)staticData
{
    [self.securityModel updateWithStaticData:staticData];
    [self setLastClose:staticData.lastClose decimal:staticData.decimal];
}

- (void)_receiveDynamicData:(OPResponsePackage2940 *)dynamicData
{
    [self.securityModel updateWithDynamicData:dynamicData];
    [self setMax:dynamicData.high min:dynamicData.low];
}

@end

@implementation OPPlotViewMinuteVolumeCombine


@end

@implementation OPPlotViewModelMinuteLevel2
{
    OPPlotSpacesBase                            *_currentPlotSpaces;
    OPDataUpdaterMinuteLevel2                   *_currentDataUpdater;
    OPMinuteLevel2Type                          _type;
}

- (instancetype)initWithPlotSpacesContext:(OPPlotSpacesContext *)context
                           updaterManager:(OPTrendUpdaterManager *)updaterManager
                            securityModel:(OPMarketSecurityModel *)securityModel
{
    if (self = [super initWithPlotSpacesContext:context updaterManager:updaterManager securityModel:securityModel])
    {
        [self switchLevel2WithType:OPMinuteLevel2DDX];
    }
    return self;
}

- (void)switchPlotSpaceWithType:(OPMinuteLevel2Type)type
{
    Class clazz                                 = NULL;
    switch (type) {
        case OPMinuteLevel2DDX:
            clazz                               = [OPPlotSpacesMinuteDDX class];
            break;
       case OPMinuteLevel2TotalAskBid:
            clazz                               = [OPPlotSpacesTotalAskBid class];
            break;
        case OPMinuteLevel2OrderDiffer:
            clazz                               = [OPPlotSpacesOrderDiffer class];
            break;
        default:
            break;
    }
    BOOL notFirst                               = _currentPlotSpaces != nil;//是否是非第一次调用
    if (notFirst)//移除上一次的图形绘制
        [self removePlotSpaces:_currentPlotSpaces];
    
    _currentPlotSpaces                          = [[clazz alloc] init];
    _currentPlotSpaces.context                  = self.context;
    _currentPlotSpaces.frameModel               = [OPFrameModel full];
    _currentPlotSpaces.dataLayer                = [[OPPlotDataLayer alloc] init];
    [self addPlotSpaces:_currentPlotSpaces];
    
    if (notFirst)
        [self resizeViewBounds:self.view.bounds];
}

- (void)switchDataUpdaterWithType:(OPMinuteLevel2Type)type
{
    Class clazz                                 = NULL;
    switch (type) {
        case OPMinuteLevel2DDX:
            clazz                               = [OPDataUpdaterMinuteDDX class];
            break;
        case OPMinuteLevel2TotalAskBid:
            clazz                               = [OPDataUpdaterTotalAskBid class];
            break;
        case OPMinuteLevel2OrderDiffer:
            clazz                               = [OPDataUpdaterOrderDiffer class];
            break;
        default:
            break;
    }
    
    BOOL notFirst                               = _currentDataUpdater != nil;//是否是非第一次调用
    NSArray *minutes                            = _currentDataUpdater.minutes;
    if (notFirst)//移除上一次的数据刷新器
        [self.updaterManager removeDateUpdater:_currentDataUpdater];
    
    __weak typeof(self) wself                   = self;
    _currentDataUpdater                         = [[clazz alloc] init];
    _currentDataUpdater.minutes                 = minutes;
    _currentDataUpdater.updateCompleted         = ^(OPDataUpdaterMinuteLevel2 *updater){
        
        [wself _receiveLevel2Data:updater];
    };
    [self.updaterManager addDateUpdater:_currentDataUpdater];
    
    if (notFirst)
        [self.updaterManager updateDataWithType:OPDataResetUpdate updater:_currentDataUpdater];
}

- (void)_receiveLevel2Data:(OPDataUpdaterMinuteLevel2 *)level2Data
{
    //校验数据
    if (([level2Data isKindOfClass:[OPDataUpdaterMinuteDDX class]] && _type == OPMinuteLevel2DDX) ||
        ([level2Data isKindOfClass:[OPDataUpdaterOrderDiffer class]] && _type == OPMinuteLevel2OrderDiffer) ||
        ([level2Data isKindOfClass:[OPDataUpdaterTotalAskBid class]] && _type == OPMinuteLevel2TotalAskBid))
    {
        _currentPlotSpaces.dataLayer.datas      = level2Data.level2Data;
        [self drawPlot];
    }
}

- (void)switchLevel2
{
    if (_type == OPMinuteLevel2OrderDiffer)
        _type                                   = OPMinuteLevel2DDX;
    else
        _type ++;
    
    [self switchLevel2WithType:_type];
}

- (void)switchLevel2WithType:(OPMinuteLevel2Type)type
{
    [self switchDataUpdaterWithType:type];
    [self switchPlotSpaceWithType:type];
}

#pragma mark - OPPlotViewModelMinuteDataObserver

- (void)resetMinuteData
{
    [_currentDataUpdater onResetMinuteData];
}

- (void)receiveMinuteData:(NSArray *)minutes
{
    _currentDataUpdater.minutes                 = minutes;
}

@end

@implementation OPPlotViewMinuteLevel2

- (instancetype)initWithFrame:(CGRect)frame plotViewModel:(OPPlotViewModelBase *)viewModel
{
    if (self = [super initWithFrame:frame plotViewModel:viewModel])
    {
        UITapGestureRecognizer *gesture         = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(switchLevel2)];
        [self addGestureRecognizer:gesture];
    }
    return self;
}

- (void)switchLevel2
{
    [(OPPlotViewModelMinuteLevel2 *)self.viewModel switchLevel2];//调用viewModel进行处理
}

@end
