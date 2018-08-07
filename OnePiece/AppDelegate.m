//
//  AppDelegate.m
//  OnePiece
//
//  Created by Duanwwu on 16/10/18.
//  Copyright © 2016年 DZH. All rights reserved.
//

#import "AppDelegate.h"
#import "OPSocketManager.h"
#import "OPMarketPackageImpl.h"
#import "OPMarketNetManager.h"
#import "OPMarketPackageImpl3010.h"
#import "OPPageableDataManager.h"
#import "OPTrendMinuteViewController.h"
#import "OPConstant.h"

@interface AppDelegate ()

@property (nonatomic, strong) NSMutableArray *datas;

@end

@implementation AppDelegate
{
//    OPPageableDataManager                           *_pageableManager;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectSuccess:) name:OPMarketConnectedNotification object:nil];
    
    self.window                                     = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    OPTrendMinuteViewController *ctr                = [[OPTrendMinuteViewController alloc] init];
    UINavigationController *nav                     = [[UINavigationController alloc] initWithRootViewController:ctr];
    self.window.rootViewController                  = nav;
    [self.window makeKeyAndVisible];
    
//    self.datas                                      = [NSMutableArray array];
//    _pageableManager                                = [[OPPageableDataManager alloc] init];
//    _pageableManager.numberPerPage                  = 200;
    
    [[OPMarketNetManager instance] buildNetwork];
    return YES;
}

- (void)connectSuccess:(NSNotification *)notification
{
//    OPRequestPackage1000 *package1000               = [[OPRequestPackage1000 alloc] init];
//    [package1000 sendRequest:^(OPResponseStatus status, id<OPRequestPackageProtocol> package) {
//        OPLOG_INFO(OPLogModuleCommon, @"请求完成");
//    } success:^(OPResponseStatus status, id<OPRequestPackageProtocol> package) {
//        OPLOG_INFO(OPLogModuleCommon, @"请求成功");
//    } failure:^(OPResponseStatus status, id<OPRequestPackageProtocol> package) {
//        OPLOG_INFO(OPLogModuleCommon, @"请求失败");
//    }];
    
//    OPRequestPackage2978 *package2978               = [[OPRequestPackage2978 alloc] initWithCodes:@[@"SZ300195"] filed1:4096 field2:4096];
//    [package2978 registerPush:^(OPResponseStatus status, id<OPRequestPackageProtocol> package) {
//        OPLOG_INFO(OPLogModuleCommon, @"接收推送数据");
//    }];
    
//    OPMarketRequestPackageGroup *group              = [[OPMarketRequestPackageGroup alloc] init];
//    OPRequestPackage1000 *p1                        = [[OPRequestPackage1000 alloc] init];
//    p1.responseCompletion                           = ^(OPResponseStatus status, id<OPRequestPackageProtocol> package){
//        
//        OPLOG_INFO(OPLogModuleCommon, @"请求完成");
//    };
//    [group addPackage:p1];
//
//    group.responseCompletion                        = ^(OPResponseStatus status, OPMarketRequestPackageGroup *groupPackage){
//        
//        OPLOG_INFO(OPLogModuleCommon, @"组包请求完成");
//    };
//
//    [group sendRequest];
    
//    OPRequestPackage3010Sub1000 *p2                 = [[OPRequestPackage3010Sub1000 alloc] initWithCode:@"SZ300195" date:0 time:0 subAttr:1];
//    p2.responseCompletion                           = ^(OPResponseStatus status, id<OPRequestPackageProtocol> package){
//        
//        OPLOG_INFO(OPLogModuleCommon, @"请求完成");
//    };
//    [p2 sendRequest];

    
//    OPRequestPackage3010Sub1001 *p1001              = [[OPRequestPackage3010Sub1001 alloc] initWithCode:@"SZ300195" date:0 time:0 subAttr:1];
//    p1001.responseCompletion                        = ^(OPResponseStatus status, id<OPRequestPackageProtocol> package){
//        
//        OPLOG_INFO(OPLogModuleCommon, @"请求完成");
//    };
//    [p1001 sendRequest];
//    
//    OPRequestPackage2942 *reqeust2942               = [[OPRequestPackage2942 alloc] initWithCode:@"SZ300195" beginPos:0];
//    reqeust2942.responseCompletion                  = ^(OPResponseStatus status, OPRequestPackage2942 *package){
//        
//        OPResponsePackage2942 *response             = package.response;
//        OPLOG_INFO(OPLogModuleCommon, @"请求完成:%@", response.minutes);
//    };
//    [reqeust2942 sendRequest];
//    
//    OPRequestPackage2944 *reqeust2944               = [[OPRequestPackage2944 alloc] initWithCode:@"SZ300195" klineType:OPSecurityKlineDay endDate:0 reqNum:200 exRights:OPEXRightsER];
//    reqeust2944.responseCompletion                  = ^(OPResponseStatus status, OPRequestPackage2944 *package){
//        
//        OPResponsePackage2944 *response             = package.response;
//        OPLOG_INFO(OPLogModuleCommon, @"请求完成:%@", response.klines);
//    };
//    [reqeust2944 sendRequest];
//
//    OPRequestPackage2985 *reqeust2985               = [[OPRequestPackage2985 alloc] initWithCode:@"SZ300195" offset:0 stride:0 mask:7 pos:0 reqNum:0];
//    reqeust2985.responseCompletion                  = ^(OPResponseStatus status, OPRequestPackage2985 *package){
//        
//        OPResponsePackage2985 *response             = package.response;
//        OPLOG_INFO(OPLogModuleCommon, @"请求完成:%@", response.minutes);
//    };
//    [reqeust2985 sendRequest];
    
//    [NSThread detachNewThreadSelector:@selector(thread1) toTarget:self withObject:nil];
//    [NSThread detachNewThreadSelector:@selector(thread2) toTarget:self withObject:nil];
//    [NSThread detachNewThreadSelector:@selector(thread3) toTarget:self withObject:nil];
    
//    [_pageableManager requestNumber:700 beginPos:0 contructRequest:^OPMarketRequestPackage *(int beginPos, int numberPerPage) {
//        
//        OPRequestPackage2944 *reqeust2944           = [[OPRequestPackage2944 alloc] initWithCode:@"SZ300195" klineType:OPSecurityKlineDay endDate:beginPos reqNum:numberPerPage exRights:OPEXRightsER];
//        return reqeust2944;
//        
//    } getPosition:^int(OPResponsePackage *response) {
//        
//        return [(OPSecurityTimeModel *)[((OPResponsePackage2944 *)response).klines firstObject] time];
//        
//    } receivePageHandle:^BOOL(OPResponseStatus status, OPMarketRequestPackage *package) {
//        
//        if ([package.response isEmptyResponse])
//            return NO;
//        
//        NSArray *klines                             = ((OPResponsePackage2944 *)package.response).klines;
//        [self.datas insertObjects:klines atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, klines.count)]];
//        OPLOG_INFO(OPLogModuleCommon, @"分页总数据个数:%d 当前叶个数:%d",[self.datas count], [klines count]);
//        return YES;
//        
//    } completion:^(BOOL success) {
//        
//        if (success)
//            OPLOG_INFO(OPLogModuleCommon, @"分页请求成功！！！！！");
//        else
//            OPLOG_INFO(OPLogModuleCommon, @"分页请求失败！！！！！");
//        
//    }];
}

- (void)thread1
{
    while (true)
    {
        int tag                                     = arc4random() % 4;
        
        OPRequestPackage *package                   = [self _generatePackageWithTag:tag];
        [package sendRequest];
        
        [NSThread sleepForTimeInterval:1.];
    }
}

- (void)thread2
{
    while (true)
    {
        int tag                                     = arc4random() % 4;
        
        OPRequestPackage *package                   = [self _generatePackageWithTag:tag];
        [package sendRequest];
        
        [NSThread sleepForTimeInterval:1.];
    }
}

- (void)thread3
{
    while (true)
    {
        int tag                                     = arc4random() % 4;
        
        OPRequestPackage *package                   = [self _generatePackageWithTag:tag];
        [package sendRequest];
        
        [NSThread sleepForTimeInterval:1.];
    }
}

- (OPRequestPackage *)_generatePackageWithTag:(int)tag
{
    OPRequestPackage *package                       = nil;
    switch (tag)
    {
        case 0:
        {
            package                                 = [[OPRequestPackage1000 alloc] init];
            package.responseCompletion              = ^(OPResponseStatus status, id<OPRequestPackageProtocol> package){
                
                OPLOG_INFO(OPLogModuleCommon, @"请求完成");
            };
        }
            break;
        case 1:
        {
            package                                 = [[OPRequestPackage1000 alloc] init];
            package.responseCompletion              = ^(OPResponseStatus status, id<OPRequestPackageProtocol> package){
                
                OPLOG_INFO(OPLogModuleCommon, @"请求完成");
            };
        }
            break;
        case 2:
        {
            OPMarketRequestPackageGroup *group      = [[OPMarketRequestPackageGroup alloc] init];
            
            OPRequestPackage1000 *p1                = [[OPRequestPackage1000 alloc] init];
            p1.responseCompletion                   = ^(OPResponseStatus status, id<OPRequestPackageProtocol> package){
                
                OPLOG_INFO(OPLogModuleCommon, @"请求完成");
            };
            [group addPackage:p1];
            
            group.responseCompletion                = ^(OPResponseStatus status, id<OPRequestPackageProtocol> package){
                
                OPLOG_INFO(OPLogModuleCommon, @"组包请求完成");
            };
            
            package                                 = group;
        }
            break;
        case 3:
        {
            OPMarketRequestPackageGroup *group      = [[OPMarketRequestPackageGroup alloc] init];
            
            OPRequestPackage1000 *p1                = [[OPRequestPackage1000 alloc] init];
            p1.responseCompletion                   = ^(OPResponseStatus status, id<OPRequestPackageProtocol> package){
                
                OPLOG_INFO(OPLogModuleCommon, @"请求完成");
            };
            [group addPackage:p1];
            
            
            group.responseCompletion                = ^(OPResponseStatus status, id<OPRequestPackageProtocol> package){
                
                OPLOG_INFO(OPLogModuleCommon, @"组包请求完成");
            };
            
            package                                 = group;
        }
            break;
        default:
        {
            package                                 = [[OPRequestPackage1000 alloc] init];
            package.responseCompletion              = ^(OPResponseStatus status, id<OPRequestPackageProtocol> package){
                
                OPLOG_INFO(OPLogModuleCommon, @"请求完成");
            };
        }
            break;
    }
    return package;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
