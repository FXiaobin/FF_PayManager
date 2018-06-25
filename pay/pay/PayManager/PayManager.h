//
//  PayManager.h
//  FFPayManager
//
//  Created by mac on 2018/6/20.
//  Copyright © 2018年 healifeGroup. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <WXApi.h>

///支付结果状态
typedef NS_ENUM(NSInteger,PayManagerPayResultCode) {
    PayManagerPayResultCodeSuccess = 0, //支付成功
    PayManagerPayResultCodeUserCancel,  //用户取消
    PayManagerPayResultCodeFail         //支付失败
};

@interface PayManager : NSObject<WXApiDelegate>

+ (PayManager *)shareInstance;

///支付宝支付
+ (void)goAliPay;

///微信支付
+ (void)goWxPay;

///支付宝和微信支付结果回调
@property (nonatomic,copy) void (^PayManagerPayResultCallBack) (PayManagerPayResultCode resultCode);


@end



/*
 步骤：
 
 pod添加库：
 
 pod 'WechatOpenSDK'
 pod 'AliPay'
 
 微信：
 
 APPdelegate注册微信APPID
 URLscheme ：     申请的微信APPID
 白名单： weixin wechat
 APPdelegate openURL 回调 有的尽量都写上
 
 
 支付宝：
 
 关闭bitcode
 URLscheme： 自己来定义一个字符串
 支付宝白名单 ： alipay
  APPdelegate openURL 回调 有的尽量都写上
 
 
 常用平台白名单：
 https://blog.csdn.net/hou3035/article/details/50843217
 
 */
