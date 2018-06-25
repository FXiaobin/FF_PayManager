//
//  AppDelegate.m
//  pay
//
//  Created by mac on 2018/6/21.
//  Copyright © 2018年 healifeGroup. All rights reserved.
//

#import "AppDelegate.h"
#import "PayManager.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    //wx3c3cd65767f5a563
    //
    [WXApi registerApp:@"wxb4ba3c02aa476ea1"];
    
    
    
    return YES;
}

///iOS9.0以后
-(BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options{
    
    if ([WXApi handleOpenURL:url delegate:[PayManager shareInstance]]) {
        return [WXApi handleOpenURL:url delegate:[PayManager shareInstance]];
        
    }else{
        if ([url.host isEqualToString:@"safepay"]){
            [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
                NSLog(@"result = %@",resultDic);
                NSInteger resultStatus = [resultDic[@"resultStatus"] integerValue];
                
                if (resultStatus == 6001) {
                    //用户取消支付
                    if ([PayManager shareInstance].PayManagerPayResultCallBack) {
                        [PayManager shareInstance].PayManagerPayResultCallBack(PayManagerPayResultCodeUserCancel);
                    }
                    
                }else if (resultStatus == 9000){
                    ///支付成功
                    if ([PayManager shareInstance].PayManagerPayResultCallBack) {
                        [PayManager shareInstance].PayManagerPayResultCallBack(PayManagerPayResultCodeSuccess);
                    }
                    
                }else{
                    ///支付失败
                    if ([PayManager shareInstance].PayManagerPayResultCallBack) {
                        [PayManager shareInstance].PayManagerPayResultCallBack(PayManagerPayResultCodeFail);
                    }
                }
                
            }];
        }
    }
    return YES;
}

-(BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url{
    
    if ([WXApi handleOpenURL:url delegate:[PayManager shareInstance]]) {
        return [WXApi handleOpenURL:url delegate:[PayManager shareInstance]];
        
    }else{
        if ([url.host isEqualToString:@"safepay"]){
            [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
                NSLog(@"result = %@",resultDic);
            }];
        }
    }
    return YES;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url sourceApplication:(nullable NSString *)sourceApplication annotation:(nonnull id)annotation{
   
    if ([WXApi handleOpenURL:url delegate:[PayManager shareInstance]]) {
        return [WXApi handleOpenURL:url delegate:[PayManager shareInstance]];
        
    }else{
        if ([url.host isEqualToString:@"safepay"]){
            [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
                NSLog(@"result = %@",resultDic);
            }];
        }
    }
    return YES;
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
