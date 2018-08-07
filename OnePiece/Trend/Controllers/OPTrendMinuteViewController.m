//
//  OPTrendMinuteViewController.m
//  OnePiece
//
//  Created by Duanwwu on 2016/11/22.
//  Copyright © 2016年 DZH. All rights reserved.
//

#import "OPTrendMinuteViewController.h"
#import "OPMarketPackageImpl.h"
#import "OPPlotSpacesMinute.h"
#import "OPTrendConstant.h"
#import "OPTrendUpdaterManager.h"
#import "OPTrendDataUpdater.h"
#import "OPConstant.h"
#import "OPPlotViewMinute.h"

@interface OPTrendMinuteViewController ()<OPDataUpdaterManagerDelegate>

@property (nonatomic, strong) OPMarketSecurityModel *securityModel;//证券数据
@property (nonatomic, strong) OPPlotViewMinute *minute;
@property (nonatomic, strong) OPPlotViewMinuteVolume *volume;
@property (nonatomic, strong) OPPlotViewMinuteVolumeCombine *combine;
@property (nonatomic, strong) OPPlotViewMinuteLevel2 *level2;

@end

@implementation OPTrendMinuteViewController
{
    //视图模型
    OPPlotViewModelMinute                       *_minuteModel;
    OPPlotViewModelMinuteVolume                 *_volumeModel;
    OPPlotViewModelCombine                      *_combineModel;
    OPPlotViewModelMinuteLevel2                 *_level2Model;
    
    //数据更新管理管理
    OPTrendUpdaterManager                       *_updaterManager;
    
    //绘制上下文
    OPPlotSpacesContext                         *_context;
}

- (instancetype)init
{
    if (self = [super init])
    {
        OPMarketSecurityModel *model            = [[OPMarketSecurityModel alloc] init];
        model.code                              = @"SZ300195";
        model.decimal                           = 2;
        self.securityModel                      = model;
        
        _updaterManager                         = [[OPTrendUpdaterManager alloc] init];
        _updaterManager.delegate                = self;
        
        _context                                = [[OPPlotSpacesContext alloc] init];
        _context.plotWidth                      = 1.;
        
        _minuteModel                            = [[OPPlotViewModelMinute alloc] initWithPlotSpacesContext:_context updaterManager:_updaterManager securityModel:model];
        _volumeModel                            = [[OPPlotViewModelMinuteVolume alloc] initWithPlotSpacesContext:_context updaterManager:_updaterManager securityModel:model];
        _combineModel                           = [[OPPlotViewModelCombine alloc] initWithPlotSpacesContext:_context updaterManager:_updaterManager securityModel:model];
        _level2Model                            = [[OPPlotViewModelMinuteLevel2 alloc] initWithPlotSpacesContext:_context updaterManager:_updaterManager securityModel:model];
        [_minuteModel addMinuteObserver:_volumeModel];
        [_minuteModel addMinuteObserver:_level2Model];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectSuccess:) name:OPMarketConnectedNotification object:nil];
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    
    self.title                                  = @"分时";
    self.view.backgroundColor                   = [UIColor whiteColor];
    
    CGSize size                                 = [[UIScreen mainScreen] bounds].size;
    CGFloat width                               = 300.;
    CGRect frame                                = CGRectMake((size.width - width) * .5, 74., width, 200.);
    self.minute                                 = [[OPPlotViewMinute alloc] initWithFrame:frame plotViewModel:_minuteModel];
    self.minute.layer.borderColor               = [UIColor blackColor].CGColor;
    self.minute.layer.borderWidth               = 1.;
    [self.view addSubview:self.minute];
    
    frame                                       = CGRectMake((size.width - width) * .5, CGRectGetMaxY(frame) - 1, width, 80.);
    self.volume                                 = [[OPPlotViewMinuteVolume alloc] initWithFrame:frame plotViewModel:_volumeModel];
    self.volume.layer.borderColor               = [UIColor blackColor].CGColor;
    self.volume.layer.borderWidth               = 1.;
    [self.view addSubview:self.volume];
    
    frame                                       = CGRectMake((size.width - width) * .5, CGRectGetMaxY(frame) + 10., width, 200.);
    self.combine                                = [[OPPlotViewMinuteVolumeCombine alloc] initWithFrame:frame plotViewModel:_combineModel];
    self.combine.layer.borderColor              = [UIColor blackColor].CGColor;
    self.combine.layer.borderWidth              = 1.;
    [self.view addSubview:self.combine];
    
    frame                                       = CGRectMake((size.width - width) * .5, CGRectGetMaxY(frame) + 10., width, 80.);
    self.level2                                 = [[OPPlotViewMinuteLevel2 alloc] initWithFrame:frame plotViewModel:_level2Model];
    self.level2.layer.borderColor               = [UIColor blackColor].CGColor;
    self.level2.layer.borderWidth               = 1.;
    [self.view addSubview:self.level2];
}

- (void)connectSuccess:(NSNotification *)notify
{
    [_updaterManager resumeDataManager];
}

- (void)updateCompleted:(OPDataUpdaterManager *)updaterManager context:(OPUpdaterManagerContext *)context
{
    [_minuteModel drawPlot];
    [_volumeModel drawPlot];
    [_combineModel drawPlot];
    [_level2Model drawPlot];
}

@end
