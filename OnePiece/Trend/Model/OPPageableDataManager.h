//
//  OPPageableDataManager.h
//  OnePiece
//
//  Created by Duanwwu on 2016/11/21.
//  Copyright © 2016年 DZH. All rights reserved.
//

#import "OPMarketNetBase.h"

typedef OPMarketRequestPackage *(^ContructRequestBlock)(int beginPos, int numberPerPage);//根据起始位置和一页请求的数据个数创建请求包
typedef int (^GetPositionBlock)(OPResponsePackage *response);//根据返回的数据获取下一次请求的起始位置
typedef void (^ReceivePageHandle)(OPResponseStatus status, OPMarketRequestPackage *package);//接收一页数据的处理

/**
 * 分页请求帮助类
 */
@interface OPPageableRequestHelper : NSObject

@property (nonatomic) int numberPerPage;//每页请求个数

/**
 * 分页请求方法，返回的请求包不可在外部设置responseSuccess和responseFailure方法，否则会导致分页请求失败
 * @param total 总共需要的数据个数
 * @param position 起始请求位置
 * @param contructorBlock 创建请求包
 * @param positionBlock 获取下一次请求起始位置
 * @param receivePageHandle 接收一页数据的处理
 * @param completion 分页请求结束
 * @returns OPMarketRequestPackage 第一次请求包
 */
- (OPMarketRequestPackage *)requestNumber:(int)total
                                 position:(int)position
                        requestContructor:(ContructRequestBlock)contructorBlock
                              getPosition:(GetPositionBlock)positionBlock
                        receivePageHandle:(ReceivePageHandle)receivePageHandle
                               completion:(void(^)(BOOL success))completion;

@end

/**
 * 增量请求帮助类
 */
@interface OPIncrementRequestHelper : NSObject

@property (nonatomic) int position;//当前位置
@property (nonatomic, copy) ContructRequestBlock contructorBlock;//创建请求block
@property (nonatomic, copy) GetPositionBlock positionBlock;//计算请求位置block
@property (nonatomic, copy) ReceivePageHandle receivePageHandle;//每收到一次数据调用一次

- (instancetype)initWithContructor:(ContructRequestBlock)contructorBlock
                       getPosition:(GetPositionBlock)positionBlock
                 receivePageHandle:(ReceivePageHandle)receivePageHandle;

/**
 * 将请求位置重置
 */
- (void)resetPosition;

/**
 * 返回的请求包不可在外部设置responseSuccess和responseFailure方法，否则会导致后续请求出问题
 * @returns 请求包
 */
- (OPMarketRequestPackage *)nextRequestWithContructor:(ContructRequestBlock)contructorBlock
                                          getPosition:(GetPositionBlock)positionBlock
                                    receivePageHandle:(ReceivePageHandle)receivePageHandle;

@end
