//
//  ViewController.m
//  pay
//
//  Created by mac on 2018/6/21.
//  Copyright © 2018年 healifeGroup. All rights reserved.
//

#import "ViewController.h"
#import <WXApi.h>
#import <AFNetworking.h>

#import "PayManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(100, 100, 200, 50)];
    btn.backgroundColor = [UIColor orangeColor];
    [btn addTarget:self action:@selector(payBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    
    ///支付结果回调
    [PayManager shareInstance].PayManagerPayResultCallBack = ^(PayManagerPayResultCode resultCode) {
        
        if (resultCode == PayManagerPayResultCodeSuccess) {
            NSLog(@"支付成功");
            
        }else if (resultCode == PayManagerPayResultCodeUserCancel) {
            NSLog(@"用户取消");
            
        }else if (resultCode == PayManagerPayResultCodeFail) {
            NSLog(@"支付失败");
            
        }
        
    } ;
    
}

-(void)payBtnAction:(UIButton *)sender{
    
    if (![WXApi isWXAppInstalled]) {
        NSLog(@"未安装微信客户端");
    }else{
        [PayManager goWxPay];
        //[PayManager goAliPay];
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
