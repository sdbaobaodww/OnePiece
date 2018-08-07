//
//  OPTrendDataUpdater.m
//  OnePiece
//
//  Created by Duanwwu on 2016/12/16.
//  Copyright © 2016年 DZH. All rights reserved.
//

#import "OPTrendDataUpdater.h"
#import "OPPageableDataManager.h"

@implementation OPDataUpdaterStatic

- (void)updateDataWithType:(OPDataUpdateType)updateType context:(OPTrendUpdaterManagerContext *)context
{
    if (updateType == OPDataUpdate)
    {
        if (!self.staticData)
            [context.groupPackage addPackage:[self _requestDataWithSecurityModel:self.securityModel]];
    }
    else if (updateType == OPDataResetUpdate)
    {
        [context.groupPackage addPackage:[self _requestDataWithSecurityModel:self.securityModel]];
    }
}

- (OPRequestPackage *)_requestDataWithSecurityModel:(OPMarketSecurityModel *)securityModel
{
    OPRequestPackage2939 *request               = [[OPRequestPackage2939 alloc] initWithCode:securityModel.code];
    request.responseSuccess                     = ^(OPResponseStatus status, OPRequestPackage2939 *package){
        
        self.staticData                         = (OPResponsePackage2939 *)package.response;
        [securityModel updateWithStaticData:self.staticData];
        [self onReceiveDataComplete:self];
    };
    return request;
}

@end

@implementation OPDataUpdaterDynamic

- (void)updateDataWithType:(OPDataUpdateType)updateType context:(OPTrendUpdaterManagerContext *)context
{
    [context.groupPackage addPackage:[self _requestDataWithSecurityModel:self.securityModel]];
}

- (OPRequestPackage *)_requestDataWithSecurityModel:(OPMarketSecurityModel *)securityModel
{
    OPRequestPackage2940 *request               = [[OPRequestPackage2940 alloc] initWithCode:securityModel.code];
    request.responseSuccess                     = ^(OPResponseStatus status, OPRequestPackage2939 *package){
        
        self.dynamicData                        = (OPResponsePackage2940 *)package.response;
        [securityModel updateWithDynamicData:self.dynamicData];
        [self onReceiveDataComplete:self];
    };
    return request;
}

@end

@implementation OPDataUpdaterMinute
{
    OPIncrementRequestHelper                    *_requestHelper;
    NSMutableArray                              *_minutes;
    short                                       _pos;
}

@synthesize minutes                             = _minutes;

- (instancetype)init
{
    if (self = [super init])
    {
        _requestHelper                          = [[OPIncrementRequestHelper alloc] init];
        _minutes                                = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)updateDataWithType:(OPDataUpdateType)updateType context:(OPTrendUpdaterManagerContext *)context
{
    if (updateType == OPDataResetUpdate)
        [_requestHelper resetPosition];
    
    [context.groupPackage addPackage:[self _nextRequestWithCode:self.securityModel.code context:context]];
}

- (OPMarketRequestPackage *)_nextRequestWithCode:(NSString *)code context:(OPTrendUpdaterManagerContext *)context
{
    return [_requestHelper nextRequestWithContructor:^OPMarketRequestPackage *(int beginPos, int numberPerPage) {
        
        OPRequestPackage2942 *reqeust2942       = [[OPRequestPackage2942 alloc] initWithCode:code beginPos:beginPos];
        OPLOG_INFO(OPLogModuleModel, @"开始位置:%d",beginPos);
        return reqeust2942;
        
    } getPosition:^int(OPResponsePackage *response) {
        
        OPResponsePackage2942 *res              = (OPResponsePackage2942 *)response;
        return res.pos <= 2 ? 0 : res.pos;
        
    } receivePageHandle:^(OPResponseStatus status, OPMarketRequestPackage *package) {
        
        [self _receiveData:(OPResponsePackage2942 *)package.response context:context];
        [self onReceiveDataComplete:self];
    }];
}

- (void)_receiveData:(OPResponsePackage2942 *)data context:(OPTrendUpdaterManagerContext *)context
{
    if (data.totalNum != 0)
        self.totalNum                           = data.totalNum;
    
    NSMutableArray *minutes                     = _minutes;
    if (data.pos < _pos)////9点10分数据重置
    {
        [minutes removeAllObjects];
        self.isReset                            = YES;
        [_requestHelper resetPosition];
    }
    else
        self.isReset                            = NO;
    
    NSArray *recentMinutes                      = data.minutes;//最新的数据
    NSInteger count                             = [minutes count];
    
    int fromTime                                = [recentMinutes.firstObject time];//新数据的开始时间
    if (count == 0 || fromTime > [(OPSecurityTimeModel *)[minutes lastObject] time])//全部新增数据，包括第一次请求和增量新数据两种情况
    {
        //校准分时点的收盘价、均价、成交量
        OPSecurityTimeModel *lastModel          = [minutes lastObject];
        int lastCose                            = lastModel ? [lastModel closePrice] : self.securityModel.lastClose;
        int lastAverage                         = lastCose;
        long long lastTotalVolume               = lastModel ? [lastModel totalVolume] : 0;
        for (OPSecurityTimeModel *model in recentMinutes)
        {
            if (model.closePrice == 0)
                model.closePrice                = lastCose;
            
            if (model.average == 0)
                model.average                   = lastAverage;
            
            if (model.totalVolume == 0)
                model.totalVolume               = lastTotalVolume;
            
            model.volume                        = (int)(model.totalVolume - lastTotalVolume);
            lastTotalVolume                     = model.totalVolume;
            lastCose                            = model.closePrice;
            lastAverage                         = model.average;
        }
        [minutes addObjectsFromArray:recentMinutes];
    }
    else//需判断数据更新和新增
    {
        NSInteger matchIndex                    = -1;//新数据开始更新的位置
        //查找开始更新位置
        for (NSInteger i = count - 1; i >= 0; i --)
        {
            OPSecurityTimeModel *model          = [minutes objectAtIndex:i];
            if (model.time == fromTime)
            {
                matchIndex                      = i;
                break;
            }
        }
        if (matchIndex == -1)//异常数据
        {
            OPLOG_INFO(OPLogModuleModel, @"分时数据异常，新数据开始时间:%d",fromTime);
        }
        else//数据至少有一部分需要进行更新处理
        {
            //校准分时点的收盘价、均价、成交量
            OPSecurityTimeModel *lastModel      = matchIndex == 0 ? nil : [minutes objectAtIndex:matchIndex - 1];
            int lastCose                        = lastModel ? [lastModel closePrice] : self.securityModel.lastClose;
            int lastAverage                     = lastCose;
            long long lastTotalVolume           = lastModel ? [lastModel totalVolume] : 0;
            NSInteger idx                       = 0;
            
            for (NSInteger i = matchIndex; i < count; i ++)
            {
                OPSecurityTimeModel *model      = [minutes objectAtIndex:i];
                OPSecurityTimeModel *rModel     = [recentMinutes objectAtIndex:idx];
                if (model.time == rModel.time)
                {
                    if (rModel.closePrice == 0)
                        rModel.closePrice       = lastCose;
                    
                    if (rModel.average == 0)
                        rModel.average          = lastAverage;
                    
                    if (rModel.totalVolume == 0)
                        rModel.totalVolume      = lastTotalVolume;
                    
                    rModel.volume               = (int)(rModel.totalVolume - lastTotalVolume);
                    lastTotalVolume             = rModel.totalVolume;
                    lastCose                    = rModel.closePrice;
                    lastAverage                 = rModel.average;
                    
                    [minutes replaceObjectAtIndex:i withObject:rModel];
                    idx++;
                }
            }
            
            if (idx != [recentMinutes count] - 1)//剩余部分数据新增
            {
                for (NSInteger i = idx; i < [recentMinutes count] - 1; i ++)
                {
                    [minutes addObject:[recentMinutes objectAtIndex:i]];
                }
            }
        }
    }
    _pos                                        = data.pos;
}

@end

@implementation OPDataUpdaterMinuteLevel2
{
    NSMutableArray                              *_level2Data;
}

- (instancetype)init
{
    if (self = [super init])
    {
        _level2Data                             = [[NSMutableArray alloc] init];
        _requestHelper                          = [[OPIncrementRequestHelper alloc] init];
    }
    return self;
}

- (void)updateDataWithType:(OPDataUpdateType)updateType context:(OPTrendUpdaterManagerContext *)context
{
    if (updateType == OPDataResetUpdate)
        [_requestHelper resetPosition];
    
    [context.groupPackage addPackage:[self _nextRequestWithCode:self.securityModel.code context:context]];
}

- (OPMarketRequestPackage *)_nextRequestWithCode:(NSString *)code context:(OPTrendUpdaterManagerContext *)context
{
    return [_requestHelper nextRequestWithContructor:^OPMarketRequestPackage *(int beginPos, int numberPerPage) {
        
        return [self level2RequestWithCode:code beginPos:beginPos];
    } getPosition:^int(OPResponsePackage *response) {
        
        OPResponsePackageMinuteLevel2 *res      = (OPResponsePackageMinuteLevel2 *)response;
        int pos                                 = (int)[res.resultArray count] - 1;
        return pos <= 2 ? 0 : pos;
    } receivePageHandle:^(OPResponseStatus status, OPMarketRequestPackage *package) {
        
        [self _receiveData:package.response context:context];
        [self onReceiveDataComplete:self];
    }];
}

- (void)onResetMinuteData
{
    [_level2Data removeAllObjects];
    [_requestHelper resetPosition];
}

- (void)_receiveData:(OPResponsePackageMinuteLevel2 *)data context:(OPTrendUpdaterManagerContext *)context
{
    NSMutableArray *level2                      = _level2Data;
    NSArray *recentLevel2                       = data.resultArray;//最新的数据
    NSInteger oldLevel2Count                    = [level2 count];//原有的level2数据个数
    NSInteger minutesCount                      = [self.minutes count];//分时数据个数
    NSInteger recentCount                       = [recentLevel2 count];//新收到的level2数据
    
    if (minutesCount > oldLevel2Count)//新增level2数据
    {
        [self updateRecentLevel2Data:recentLevel2 lastModel:[level2 lastObject]];
        
        if (minutesCount - oldLevel2Count >= recentCount)//返回的ddx数据少于等于所需的level2数据
        {
            [level2 addObjectsFromArray:recentLevel2];
        }
        else//返回的level2数据多于所需的level2数据
        {
            [level2 addObjectsFromArray:[recentLevel2 subarrayWithRange:NSMakeRange(0, minutesCount - oldLevel2Count)]];
        }
    }
    else if (minutesCount == oldLevel2Count)//更新level2数据
    {
        NSInteger idx                           = oldLevel2Count - recentCount;//开始更新索引
        NSInteger c                             = MIN(recentCount, minutesCount);//防止全量返回的数据比现有数据多，导致越界
        //切换level2的时候，有几率返回的数据比分时数据多，此时需进行特殊处理，忽略掉多出来的数据
        idx                                     = MAX(idx, 0);
        
        [self replaceLevel2Data:level2 startIndex:idx recentLevel2:recentLevel2 limitCount:c];
    }
    else//分数数据比原有的level2数据还少，属于重置失败，异常情况，暂不处理
    {
        
    }
}

- (OPMarketRequestPackage *)level2RequestWithCode:(NSString *)code beginPos:(int)beginPos
{
    return nil;
}

- (void)updateRecentLevel2Data:(NSArray *)recentLevel2 lastModel:(id)model
{
    
}

- (void)replaceLevel2Data:(NSMutableArray *)level2 startIndex:(NSInteger)index recentLevel2:(NSArray *)recentLevel2 limitCount:(NSInteger)limitCount
{
    id item                                     = nil;
    for (NSInteger i = 0; i < limitCount; i ++, index ++)
    {
        item                                    = [recentLevel2 objectAtIndex:i];
        [level2 replaceObjectAtIndex:index withObject:item];
    }
}

@end

@implementation OPDataUpdaterMinuteDDX

- (OPMarketRequestPackage *)level2RequestWithCode:(NSString *)code beginPos:(int)beginPos
{
    OPRequestPackage2922 *request               = [[OPRequestPackage2922 alloc] initWithCode:code pos:beginPos];
    return request;
}

- (void)updateRecentLevel2Data:(NSArray *)recentLevel2 lastModel:(id)model
{
    int lastDDXSum                              = [(OPSecurityDDXModel *)model ddxSum];
    for (OPSecurityDDXModel *item in recentLevel2)
    {
        item.ddx                                = item.ddxSum - lastDDXSum;
        lastDDXSum                              = item.ddxSum;
    }
}

- (void)replaceLevel2Data:(NSMutableArray *)level2 startIndex:(NSInteger)index recentLevel2:(NSArray *)recentLevel2 limitCount:(NSInteger)limitCount
{
    OPSecurityDDXModel *item                    = nil;
    int oldDDXSum                               = index - 1 <= 0 ? 0 : [[level2 objectAtIndex:index - 1] ddxSum];
    for (NSInteger i = 0; i < limitCount; i ++, index ++)
    {
        item                                    = [recentLevel2 objectAtIndex:i];
        item.ddx                                = item.ddxSum - oldDDXSum;
        oldDDXSum                               = item.ddxSum;
        
        [level2 replaceObjectAtIndex:index withObject:item];
    }
}

@end

@implementation OPDataUpdaterOrderDiffer

- (OPMarketRequestPackage *)level2RequestWithCode:(NSString *)code beginPos:(int)beginPos
{
    OPRequestPackage2923 *request               = [[OPRequestPackage2923 alloc] initWithCode:code pos:beginPos];
    return request;
}

@end

@implementation OPDataUpdaterTotalAskBid

- (OPMarketRequestPackage *)level2RequestWithCode:(NSString *)code beginPos:(int)beginPos
{
    OPRequestPackage2924 *request               = [[OPRequestPackage2924 alloc] initWithCode:code pos:beginPos];
    return request;
}

@end
