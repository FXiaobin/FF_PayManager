//
//  PayManager.m
//  FFPayManager
//
//  Created by mac on 2018/6/20.
//  Copyright © 2018年 healifeGroup. All rights reserved.
//

#import "PayManager.h"

@implementation PayManager

+ (PayManager *)shareInstance{
    static PayManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[PayManager alloc] init];
    });
    return manager;
}

+ (void)goAliPay{

    [self requestDataWithType:@"ALIPAY"];
}

+ (void)goWxPay{
    
    //请求自己后台 微信支付数据
    //[self requestDataWithType:@"WXPAY"];
    
    ///微信支付demo中的支付测试
    [self wxPayTest];
}

#pragma mark - <WXApiDelegate>

-(void)onReq:(BaseReq*)req{
    NSLog(@"------- wx request -------");
    
}

-(void)onResp:(BaseResp*)resp{
    //NSLog(@"------- wx response -------");
    if ([resp isKindOfClass:[PayResp class]]){
        PayResp *response=(PayResp*)resp;
        switch(response.errCode){
            case WXSuccess:{
                //服务器端查询支付通知或查询API返回的结果再提示成功
                //NSLog(@"支付成功");
                if (self.PayManagerPayResultCallBack) {
                    self.PayManagerPayResultCallBack(PayManagerPayResultCodeSuccess);
                }
                
            }   break;
                
            case WXErrCodeUserCancel:{
                //NSLog(@"用户取消");
                if (self.PayManagerPayResultCallBack) {
                    self.PayManagerPayResultCallBack(PayManagerPayResultCodeUserCancel);
                }
                
            }   break;
                
            default:{
                //NSLog(@"支付失败，retcode=%d",resp.errCode);
                if (self.PayManagerPayResultCallBack) {
                    self.PayManagerPayResultCallBack(PayManagerPayResultCodeFail);
                }
            }   break;
        }
    }
}

#pragma mark - <Requst Pay Data>
///请求自己后台支付信息来调起支付 实际开发中用这个就行了  //微信支付用这个 需要将微信的APPID换成 wx3c3cd65767f5a563
+(void)requestDataWithType:(NSString *)payType{
 
    NSString *url = @"http://api.medmeeting.com/v1/video/pay";
    NSDictionary *para = @{@"paymentChannel" : payType,
                           @"platformType" : @"APP",
                           @"videoId" : @"782"
                           };
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/plain", @"text/html",nil];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.requestSerializer.timeoutInterval = 20;
    // 开始设置请求头
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSString *aut = @"bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1bmlxdWVfbmFtZSI6IuiDoeaYpem-mS5KYWNrIiwidXNlcklkIjoiMjEiLCJyb2xlIjoiMSIsImNyZWF0ZWQiOjE1Mjk1NTE5OTE2ODcsImV4cCI6MTUyNzg0OTAyNDM5MSwiaXNzIjoiaGVhbGlmZSIsImF1ZCI6IjA5OGY2YmNkNDYyMWQzNzNjYWRlNGU4MzI2MjdiNGY2In0.OwnHHFjBF6AsaAYZqO5G6hUQwXpqh3DAm6zDBGM8C2M";
    [manager.requestSerializer setValue:aut forHTTPHeaderField:@"Authorization"];
    
    // 处理中文和空格问题
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    [manager POST:url parameters:para progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary *entity = responseObject[@"entity"];
        
        if ([payType isEqualToString:@"WXPAY"]) {
            ///微信支付
            
            NSDictionary *requestPay = entity[@"requestPay"];
            
            //NSString *appid = requestPay[@"appid"];
            NSString *noncestr = requestPay[@"noncestr"];
            NSString *package = requestPay[@"package"];
            NSString *partnerid = requestPay[@"partnerid"];
            NSString *prepayid = requestPay[@"prepayid"];
            NSString *sign = requestPay[@"sign"];
            NSString *timestamp = requestPay[@"timestamp"];
            
            
            PayReq *request = [[PayReq alloc] init];
            //request.openID = appidWXStr;
            request.partnerId = partnerid;
            request.prepayId= prepayid;
            request.package = package;
            request.nonceStr= noncestr;
            request.timeStamp= timestamp.intValue;
            request.sign= sign;
            [WXApi sendReq:request];
            
            
        }else if ([payType isEqualToString:@"ALIPAY"]){
            ///支付宝支付
            NSString *alipayOrderString = entity[@"alipayOrderString"];
//            NSString *amount = entity[@"amount"];
//            NSString *tradeId = entity[@"tradeId"];
//            NSString *tradeTitle = entity[@"tradeTitle"];
            
            [[AlipaySDK defaultService] payOrder:alipayOrderString fromScheme:@"PayManagerAliPay" callback:^(NSDictionary *resultDic) {
                NSLog(@"----resultDic = %@ ",resultDic);
                NSInteger status = [resultDic[@"resultStatus"] integerValue];
                
                
            }];
        }
 
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

///模拟微信支付
+ (void)wxPayTest {
    
    //============================================================
    // V3&V4支付流程实现
    // 注意:参数配置请查看服务器端Demo
    // 更新时间：2015年11月20日
    //============================================================
    NSString *urlString   = @"http://wxpay.wxutil.com/pub_v2/app/app_pay.php?plat=ios";
    //解析服务端返回json数据
    //加载一个NSURL对象
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
           
            if (data) {
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                NSLog(@"--- dic = %@",dict);
                
                if(dict){
                    NSMutableString *stamp  = [dict objectForKey:@"timestamp"];
                    //调起微信支付
                    PayReq* req             = [[PayReq alloc] init];
                    req.partnerId           = [dict objectForKey:@"partnerid"];
                    req.prepayId            = [dict objectForKey:@"prepayid"];
                    req.nonceStr            = [dict objectForKey:@"noncestr"];
                    req.timeStamp           = stamp.intValue;
                    req.package             = [dict objectForKey:@"package"];
                    req.sign                = [dict objectForKey:@"sign"];
                    [WXApi sendReq:req];
                    //日志输出
                    NSLog(@"appid=%@\npartid=%@\nprepayid=%@\nnoncestr=%@\ntimestamp=%ld\npackage=%@\nsign=%@",[dict objectForKey:@"appid"],req.partnerId,req.prepayId,req.nonceStr,(long)req.timeStamp,req.package,req.sign );
                }
            }
         
        });
        
    }];
    [task resume]; 
}

@end
