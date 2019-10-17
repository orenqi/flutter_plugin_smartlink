//
//  ViewController.m
//  Demo
//
//  Created by Peter on 15/11/26.
//  Copyright © 2015年 Peter. All rights reserved.
//

#import "ViewController.h"
//#import "smartlinklib_7x.h"
#import "HFSmartLink.h"
#import "HFSmartLinkDeviceInfo.h"
#import <SystemConfiguration/CaptiveNetwork.h>

@interface ViewController ()
{
    HFSmartLink * smtlk;
    BOOL isconnecting;
}

@end

// V 7.2.00 for ipv6 compatible
#define APP_VERSION         @"V 8.0.01"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    smtlk = [HFSmartLink shareInstence];
    smtlk.isConfigOneDevice = true;
    smtlk.waitTimers = 60;
    isconnecting=false;
    
    self.progress.progress = 0.0;
    self.switcher.on = smtlk.isConfigOneDevice;
    
    [self showWifiSsid];
    self.txtPwd.text = [self getspwdByssid:self.txtSSID.text];
    self.txtUserStr.text= @"";
    _txtPwd.delegate=self;
    _txtSSID.delegate=self;
    _lblVersion.text=APP_VERSION;
}

- (IBAction)butPressed:(id)sender {
    NSString * ssidStr= self.txtSSID.text;
    NSString * pswdStr = self.txtPwd.text;
    NSString * userStr= self.txtUserStr.text;
    BOOL v3xSupport= false;
    
    v3xSupport= [_swV3x isOn];
    [self savePswd];
    self.progress.progress = 0.0;
    if(!isconnecting){
        isconnecting = true;
        [smtlk startWithSSID:ssidStr Key:pswdStr UserStr:userStr withV3x:v3xSupport
                processblock: ^(NSInteger pro) {
                    self.progress.progress = (float)(pro)/100.0;
                } successBlock:^(HFSmartLinkDeviceInfo *dev) {
                    [self  showAlertWithMsg:[NSString stringWithFormat:@"%@:%@",dev.mac,dev.ip] title:@"OK"];
                } failBlock:^(NSString *failmsg) {
                    [self  showAlertWithMsg:failmsg title:@"error"];
                } endBlock:^(NSDictionary *deviceDic) {
                    isconnecting  = false;
                    [self.butConnect setTitle:@"connect" forState:UIControlStateNormal];
                }];
        [self.butConnect setTitle:@"connecting" forState:UIControlStateNormal];
    }else{
        [smtlk stopWithBlock:^(NSString *stopMsg, BOOL isOk) {
            if(isOk){
                isconnecting  = false;
                [self.butConnect setTitle:@"1connect" forState:UIControlStateNormal];
                [self showAlertWithMsg:stopMsg title:@"OK"];
            }else{
                [self showAlertWithMsg:stopMsg title:@"error"];
            }
        }];
    }
}

- (IBAction)swPressed:(id)sender {
    if(self.switcher.on){
        smtlk.isConfigOneDevice = true;
    }else{
        smtlk.isConfigOneDevice = false;
    }
}

- (IBAction)swV3Pressed:(id)sender {
}

-(void)showAlertWithMsg:(NSString *)msg
                  title:(NSString*)title{
    UIAlertView * alert = [[UIAlertView alloc]initWithTitle:title message:msg delegate:nil cancelButtonTitle:@"cancel" otherButtonTitles:@"ok", nil];
    [alert show];
}

-(void)savePswd{
    NSUserDefaults * def = [NSUserDefaults standardUserDefaults];
    [def setObject:self.txtPwd.text forKey:self.txtSSID.text];
}
-(NSString *)getspwdByssid:(NSString * )mssid{
    NSUserDefaults * def = [NSUserDefaults standardUserDefaults];
    return [def objectForKey:mssid];
}

- (void)showWifiSsid
{
    BOOL wifiOK= FALSE;
    NSDictionary *ifs;
    NSString *ssid;
    UIAlertView *alert;
    if (!wifiOK)
    {
        ifs = [self fetchSSIDInfo];
        ssid = [ifs objectForKey:@"SSID"];
        if (ssid!= nil)
        {
            wifiOK= TRUE;
            self.txtSSID.text = ssid;
        }
        else
        {
            alert= [[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:@"请连接Wi-Fi"] delegate:self cancelButtonTitle:@"关闭" otherButtonTitles:nil];
            alert.delegate=self;
            [alert show];
        }
    }
}

- (id)fetchSSIDInfo {
    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
    NSLog(@"Supported interfaces: %@", ifs);
    id info = nil;
    for (NSString *ifnam in ifs) {
        info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        NSLog(@"%@ => %@", ifnam, info);
        if (info && [info count]) { break; }
    }
    return info;
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    [theTextField resignFirstResponder];
    return YES;
}

@end
