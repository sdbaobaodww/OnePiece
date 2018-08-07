//
//  OPPageableDataManager.m
//  OnePiece
//
//  Created by Duanwwu on 2016/11/21.
//  Copyright © 2016年 DZH. All rights reserved.
//

#import "OPPageableDataManager.h"
#import <objc/runtime.h>

@interface OPPageableConfig : NSObject

@property (nonatomic) int reqCount;//请求次数
@property (nonatomic) int totalNum;//请求总数
@property (nonatomic, copy) ContructRequestBlock contructorBlock;//创建请求block
@property (nonatomic, copy) GetPositionBlock positionBlock;//计算请求位置block
@property (nonatomic, copy) ReceivePageHandle receivePageHandle;//每收到一次数据调用一次
@property (nonatomic, copy) void(^completion)(BOOL success);//数据请求完成后的回调

@end

@implementation OPPageableConfig

@end

@interface OPMarketRequestPackage (PageableRequest)

@property (nonatomic, strong) OPPageableConfig *pr_pageableConfig;

@end

@implementation OPMarketRequestPackage (PageableRequest)

- (void)setPr_pageableConfig:(OPPageableConfig *)pr_pageableConfig
{
    objc_setAssociatedObject(self, @selector(pr_pageableConfig), pr_pageableConfig, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (OPPageableConfig *)pr_pageableConfig
{
    return objc_getAssociatedObject(self, @selector(pr_pageableConfig));
}

@end

@implementation OPPageableRequestHelper

- (OPMarketRequestPackage *)requestNumber:(int)total
                                 position:(int)position
                        requestContructor:(ContructRequestBlock)contructorBlock
                              getPosition:(GetPositionBlock)positionBlock
                        receivePageHandle:(ReceivePageHandle)receivePageHandle
                               completion:(void(^)(BOOL success))completion
{
    if (self.numberPerPage == 0 || contructorBlock == nil || positionBlock == nil)
        return nil;
    
    OPPageableConfig *config            = [[OPPageableConfig alloc] init];
    config.totalNum                     = total;
    config.contructorBlock              = contructorBlock;
    config.positionBlock                = positionBlock;
    config.receivePageHandle            = receivePageHandle;
    config.completion                   = completion;
    config.reqCount                     = total / self.numberPerPage + 1;
    
    return [self _requestFromPos:position number:self.numberPerPage config:config completion:completion];
}

- (OPMarketRequestPackage *)_requestFromPos:(int)pos number:(int)number config:(OPPageableConfig *)config completion:(void(^)(BOOL))completion
{
    __weak typeof(self) wself           = self;
    OPMarketRequestPackage *request     = config.contructorBlock(pos, number);
    request.responseSuccess             = ^(OPResponseStatus status, OPMarketRequestPackage *package){
        
        if (config.receivePageHandle)
            config.receivePageHandle(status, package);
        
        config.reqCount --;
        if (config.reqCount == 0)//全部请求完成
            completion(YES);
        else if (wself == nil)//对象被释放，结束后续处理
            completion(NO);
        else
        {
            int position                = config.positionBlock(package.response);
            [wself _requestFromPos:position number:number config:config completion:completion];
        }
    };
    request.responseFailure             = ^(OPResponseStatus status, OPMarketRequestPackage *package){
        
        completion(NO);
    };
    return request;
}

@end

@implementation OPIncrementRequestHelper

- (instancetype)initWithContructor:(ContructRequestBlock)contructorBlock
                       getPosition:(GetPositionBlock)positionBlock
                 receivePageHandle:(ReceivePageHandle)receivePageHandle
{
    if (self = [super init])
    {
        self.contructorBlock            = contructorBlock;
        self.positionBlock              = positionBlock;
        self.receivePageHandle          = receivePageHandle;
    }
    return self;
}

- (void)resetPosition
{
    self.position                       = 0;
}

- (OPMarketRequestPackage *)nextRequestWithContructor:(ContructRequestBlock)contructorBlock
                                          getPosition:(GetPositionBlock)positionBlock
                                    receivePageHandle:(ReceivePageHandle)receivePageHandle
{
    return [self _requestWithRequestContructor:contructorBlock getPosition:positionBlock receivePageHandle:receivePageHandle];
}

/**
 * 增量请求方法
 * @param contructorBlock 创建请求包
 * @param positionBlock 获取下一次请求起始位置
 * @param receivePageHandle 接收数据的处理
 * @returns OPMarketRequestPackage 第一次请求包
 */
- (OPMarketRequestPackage *)_requestWithRequestContructor:(ContructRequestBlock)contructorBlock
                                              getPosition:(GetPositionBlock)positionBlock
                                        receivePageHandle:(ReceivePageHandle)receivePageHandle
{
    if (contructorBlock == nil || positionBlock == nil)
        return nil;
    
    OPMarketRequestPackage *request     = contructorBlock(self.position, 0);
    request.responseSuccess             = ^(OPResponseStatus status, OPMarketRequestPackage *package){
        
        if (receivePageHandle)
            receivePageHandle(status, package);
        
        self.position                   = positionBlock(package.response);
    };
    return request;
}

@end
