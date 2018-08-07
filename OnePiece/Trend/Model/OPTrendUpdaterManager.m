//
//  OPTrendUpdaterManager.m
//  OnePiece
//
//  Created by Duanwwu on 2016/12/15.
//  Copyright © 2016年 DZH. All rights reserved.
//

#import "OPTrendUpdaterManager.h"
#import "OPMarketNetBase.h"
#import "NSTimer+Util.h"

@implementation OPTrendUpdaterManagerContext

- (instancetype)init
{
    if (self = [super init])
    {
        _groupPackage                           = [[OPMarketRequestPackageGroup alloc] init];
    }
    return self;
}

- (void)allReady
{
    __strong typeof(self) strongSelf            = self;
    _groupPackage.responseSuccess               = ^(OPResponseStatus status, id<OPRequestPackageProtocol> package){
        
        if ([strongSelf.delegate respondsToSelector:@selector(updateCompletedWithContext:)])
            [strongSelf.delegate updateCompletedWithContext:strongSelf];
    };
    [_groupPackage sendRequest];
}

@end

@implementation OPTrendUpdaterManager
{
    NSTimer                                     *_timer;
}

- (instancetype)init
{
    if (self = [super init])
    {
        _timer                                  = [NSTimer scheduledTimerWithTimeInterval:5. target:self selector:@selector(_updateData) userInfo:nil repeats:YES];
    }
    return self;
}

- (OPTrendUpdaterManagerContext *)buildContext
{
    OPTrendUpdaterManagerContext *context       = [[OPTrendUpdaterManagerContext alloc] init];
    return context;
}

- (void)setTimerInterval:(NSTimeInterval)timerInterval
{
    if (_timerInterval != timerInterval)
    {
        _timerInterval                          = timerInterval;
        
        if ([_timer isValid])
        {
            [_timer invalidate];
            _timer                              = [NSTimer scheduledTimerWithTimeInterval:timerInterval target:self selector:@selector(_updateData) userInfo:nil repeats:YES];
        }
    }
}

- (void)resumeDataManager
{
    [_timer util_resume];
}

- (void)suspendDataManager
{
    [_timer util_suspend];
}

- (void)_updateData
{
    [self updateDataWithType:OPDataUpdate];
}

- (void)resetAndUpdate
{
    [_timer util_nextFire];
    [self updateDataWithType:OPDataResetUpdate];
}

@end
