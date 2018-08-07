//
//  OPSecurityDataCenter.h
//  OnePiece
//
//  Created by Duanwwu on 2017/2/21.
//  Copyright © 2017年 DZH. All rights reserved.
//

#import "OPMarketDataModel.h"
#import "OPTrendUpdaterManager.h"
#import "OPMarketPackageImpl.h"

@class OPSecurityDatabase;

typedef NS_OPTIONS(int, OPDataFetchMask)
{
    OPFetchMaskNone                         = 0,
    OPFetchMaskStaticInfo                   = 1 << 0,//证券基本信息。静态数据、财务数据、其它信息（个股期权行权日行权价）通常情况下只会请求一次
    OPFetchMaskDynamicInfo                  = 1 << 1,//证券动态信息，定时请求。包括动态数据、指数涨跌家数、分级基金扩展数据、港股熔断信息、2955的财务数据等
    
    OPFetchMaskMinute                       = 1 << 11,//分时数据、指数涨跌家数走势、level2委托队列
    OPFetchMaskMinutePan                    = 1 << 12,//分时买卖盘、level2扩展买卖盘数据
    OPFetchMaskMinuteMing                   = 1 << 13,//分时成交数据
    OPFetchMaskMinuteDDX                    = 1 << 14,//分时DDX
    OPFetchMaskMinuteDiffer                 = 1 << 15,//分时单差
    OPFetchMaskMinuteTotal                  = 1 << 16,//分时总买总卖量
    
    OPFetchMaskKline                        = 1 << 21,//K线数据
    OPFetchMaskKlineDDX                     = 1 << 22,//K线DDX
    OPFetchMaskKlineDDY                     = 1 << 23,//K线DDY
    OPFetchMaskKlineDDZ                     = 1 << 24,//K线DDZ
    OPFetchMaskKlineBS                      = 1 << 25,//K线BS点
    OPFetchMaskKlineMainmem                 = 1 << 26,//主力资金线
    OPFetchMaskKlineHisMinute               = 1 << 27,//k线历史分时
};

typedef void(^OPFetchDataSuccess)(OPDataFetchMask dataMask, OPSecurityDatabase *dataCenter);

@interface OPSecurityMinuteData : NSObject

@property (nonatomic, strong) NSMutableArray *minutes;//分时数据

@property (nonatomic, strong) NSMutableArray *updowns;//上证指数/深证指数涨跌家数走势数据

@end

@interface OPSecurityKlineData : NSObject

@property (nonatomic, strong) NSMutableArray *klines;//k线数据

@end

@interface OPSecurityDatabase : NSObject

@property (nonatomic, strong) OPTrendUpdaterManager *updaterManager;//数据刷新管理对象

@property (nonatomic, strong) OPMarketSecurityModel *securityModel;//证券数据模型

@property (nonatomic, strong) OPSecurityMinuteData *minuteData;//分时数据

@property (nonatomic, readonly) OPDataFetchMask dataMask;//当前注册的数据获取掩码

- (instancetype)initWithUpdaterManager:(OPTrendUpdaterManager *)updaterManager
                         securityModel:(OPMarketSecurityModel *)securityModel;

/**
 * 注册指定数据请求掩码的回调处理，target跟dataMask组合才能找到对应的callback
 * @param target 指定对象
 * @param callback 数据获取后的回调
 * @param dataMask 数据请求掩码
 */
- (void)registerCallback:(OPFetchDataSuccess)callback forTarget:(id)target dataMask:(OPDataFetchMask)dataMask;

/**
 * 移除指定对象和数据请求掩码相关的回调处理
 * @param target 指定对象
 * @param dataMask 数据请求掩码
 */
- (void)removeCallbackForTarget:(id)target dataMask:(OPDataFetchMask)dataMask;

/**
 * 注册需要刷新的数据请求掩码
 * @param dataMask 数据请求掩码
 */
- (void)registerDataMask:(OPDataFetchMask)dataMask;

/**
 * 移除需要刷新的数据请求掩码
 * @param dataMask 数据请求掩码
 */
- (void)removeRegistedDataMask:(OPDataFetchMask)dataMask;

/**
 * 使用指定数据请求掩码请求数据
 * @param dataMask 数据请求掩码
 */
- (void)fetchDataWithMask:(OPDataFetchMask)dataMask;

@end
