//
//  OPSecurityDataCenter.m
//  OnePiece
//
//  Created by Duanwwu on 2017/2/21.
//  Copyright © 2017年 DZH. All rights reserved.
//

#import "OPSecurityDatabase.h"
#import "OPTrendDataUpdater.h"

@implementation OPSecurityMinuteData

@end

@implementation OPSecurityKlineData

@end

@implementation OPSecurityDatabase
{
    NSMutableDictionary                     *_callbacks;
    NSMutableDictionary                     *_updaters;
    dispatch_queue_t                        _queue;
}

- (instancetype)initWithUpdaterManager:(OPTrendUpdaterManager *)updaterManager
                         securityModel:(OPMarketSecurityModel *)securityModel
{
    if (self = [super init])
    {
        self.updaterManager                 = updaterManager;
        self.securityModel                  = securityModel;
        _queue                              = dispatch_queue_create("com.duan.database", NULL);
    }
    return self;
}

- (void)registerCallback:(OPFetchDataSuccess)callback forTarget:(id)target dataMask:(OPDataFetchMask)dataMask
{
    dispatch_sync(_queue, ^{
        
        NSMutableDictionary *dic            = [_callbacks objectForKey:@(dataMask)];
        if (!dic)
            dic                             = [NSMutableDictionary dictionary];
        [dic setObject:[callback copy] forKey:target];
    });
}

- (void)removeCallbackForTarget:(id)target dataMask:(OPDataFetchMask)dataMask
{
    dispatch_sync(_queue, ^{
        
        NSMutableDictionary *dic            = [_callbacks objectForKey:@(dataMask)];
        if (dic)
            [dic removeObjectForKey:target];
    });
}

- (void)invokeCallbackForDataMask:(OPDataFetchMask)dataMask
{
    dispatch_sync(_queue, ^{
        
        NSMutableDictionary *dic            = [_callbacks objectForKey:@(dataMask)];
        [dic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
           
            ((OPFetchDataSuccess)obj)(dataMask, self);
        }];
    });
}

- (void)registerDataMask:(OPDataFetchMask)dataMask
{
    if (_dataMask != OPFetchMaskNone)
    {
        [self.updaterManager removeDateUpdaters:[self _updatersForDataMask:_dataMask]];
    }
    
    _dataMask                               = dataMask;
    [self.updaterManager addDateUpdaters:[self _updatersForDataMask:dataMask]];
}

- (void)removeRegistedDataMask:(OPDataFetchMask)dataMask
{
    NSArray *updaters                       = [_updaters objectForKey:@(dataMask)];
    if (updaters)
        [self.updaterManager removeDateUpdaters:updaters];
}

- (void)fetchDataWithMask:(OPDataFetchMask)dataMask
{
    [self.updaterManager updateDataWithType:OPDataUpdate updaters:[self _updatersForDataMask:dataMask]];
}

- (NSArray *)_updatersForDataMask:(OPDataFetchMask)dataMask
{
    NSMutableArray *groupUpdaters           = [NSMutableArray array];
    if ((dataMask & OPFetchMaskStaticInfo) == 1)//证券基本信息
    {
        [groupUpdaters addObjectsFromArray:[self _updatersForSingleDataMask:OPFetchMaskStaticInfo]];
    }
    
    if ((dataMask & OPFetchMaskDynamicInfo) == 1)//证券动态信息
    {
        [groupUpdaters addObjectsFromArray:[self _updatersForSingleDataMask:OPFetchMaskDynamicInfo]];
    }
    
    if ((dataMask & OPFetchMaskMinute) == 1)//证券分时信息
    {
        [groupUpdaters addObjectsFromArray:[self _updatersForSingleDataMask:OPFetchMaskMinute]];
    }
    
    return groupUpdaters;
}

- (NSArray *)_updatersForSingleDataMask:(OPDataFetchMask)dataMask
{
    NSArray *updaters                       = [_updaters objectForKey:@(dataMask)];
    if (updaters)
        return updaters;
    
    __weak typeof(self) weakSelf            = self;
    switch (dataMask)
    {
        case OPFetchMaskStaticInfo:
        {
            OPDataUpdaterStatic *updater    = [[OPDataUpdaterStatic alloc] initWithSecurityModel:self.securityModel];
            updater.updateCompleted         = ^(OPDataUpdaterStatic *updater) {
                
                [weakSelf invokeCallbackForDataMask:OPFetchMaskStaticInfo];
            };
            updaters                        = @[updater];
        }
            break;
        case OPFetchMaskDynamicInfo:
        {
            OPDataUpdaterDynamic *updater   = [[OPDataUpdaterDynamic alloc] initWithSecurityModel:self.securityModel];
            updater.updateCompleted         = ^(OPDataUpdaterDynamic *updater) {
                
                [weakSelf invokeCallbackForDataMask:OPFetchMaskDynamicInfo];
            };
            updaters                        = @[updater];
        }
            break;
        case OPFetchMaskMinute:
        {
            OPDataUpdaterMinute *updater    = [[OPDataUpdaterMinute alloc] initWithSecurityModel:self.securityModel];
            updater.updateCompleted         = ^(OPDataUpdaterMinute *updater) {
                
                [weakSelf invokeCallbackForDataMask:OPFetchMaskMinute];
            };
            updaters                        = @[updater];
        }
            break;
        default:
            break;
    }
    
    [_updaters setObject:updaters forKey:@(dataMask)];
    return updaters;
}

@end
