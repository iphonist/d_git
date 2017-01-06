//
//  MainWebViewController.m
//  DaewoongElectronicApproval
//
//  Created by Ids&Trust on 2014. 12. 4..
//  Copyright (c) 2014년 Ids&Trust. All rights reserved.
//

#import "MainWebViewController.h"
#import "Reachability.h"

@interface MainWebViewController ()

@end

@implementation MainWebViewController





- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if(&UIApplicationWillEnterForegroundNotification) { //needed to run on older devices, otherwise you'll get EXC_BAD_ACCESS
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        [notificationCenter addObserver:self selector:@selector(enteredForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    }
    
    
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies])
    {
        [storage deleteCookie:cookie];
    }

    
#ifdef Daewoong
    self.navigationItem.title = NSLocalizedString(@"str_e_approval", @"str_e_approval");
#elif SmartRunner
    self.navigationItem.title = NSLocalizedString(@"str_smartrunner", @"str_smartrunner");
    
#endif
    
    [self.navigationItem setHidesBackButton:YES];
    [self.navigationItem.rightBarButtonItem setEnabled:YES];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                             initWithTitle: @"Back"
                                             style: UIBarButtonItemStyleBordered
                                             target:self action:@selector(back)];
    
    UIBarButtonItem *logout_btn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"LogoutButton"] style:UIBarButtonItemStyleDone target:self action:@selector(logout:)];
    self.navigationItem.rightBarButtonItem = logout_btn;
    
    
    self.webview.delegate = self;
    self.webview.scalesPageToFit = YES;
    
//    if(![self isNetworkEnable]){
//        
//        [self.navigationController popToRootViewControllerAnimated:YES];
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"str_error", @"str_error")
//                                                        message:NSLocalizedString(@"msg_error_network", @"msg_error_network")
//                                                       delegate:self
//                                              cancelButtonTitle:NSLocalizedString(@"str_OK", @"str_OK")
//                                              otherButtonTitles:nil, nil];
//        [alert show];
//    }
//    NSLog(self.token);
    
    
    [self loadUrl];
    
}

- (void)back
{
    [self.webview goBack];
}

- (void)loadUrl
{
    NSString *loginId = [[NSUserDefaults standardUserDefaults] stringForKey:@"id"];
//    NSString *loginPw = [[NSUserDefaults standardUserDefaults] stringForKey:@"pw"];
    
    NSString *deviceKey = [[NSUserDefaults standardUserDefaults] stringForKey:@"deviceId"];

    
    
    NSString *deviceType = [UIDevice currentDevice].model;
    
    NSString *post = [NSString stringWithFormat: @"userId=%@&code=%@&deviceType=%@&deviceKey=%@", loginId, self.token, deviceType, deviceKey];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init] ;
    [request setURL:[NSURL URLWithString:mainURL]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setTimeoutInterval:20.0];
    [request setHTTPBody:postData];
    
    [self.webview loadRequest: request];

    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];

    NSLog(@"loadURL %@",request);
    
//    if([self.webview canGoBack]){
//        
//        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
//                                                 initWithTitle: @"Back"
//                                                 style: UIBarButtonItemStyleBordered
//                                                 target:self action:@selector(back)];
//    }
//    else{
//        self.navigationItem.leftBarButtonItem = nil;
//    }
}


- (void)enteredForeground:(NSNotification*) noti
{
    //do stuff here
    NSLog(@"enteredForeground");
    
    NSString *loginId = [[NSUserDefaults standardUserDefaults] stringForKey:@"id"];
    NSString *loginPw = [[NSUserDefaults standardUserDefaults] stringForKey:@"pw"];
    
    
    [self login_getCode:loginId :loginPw];
}

-(void)login_getCode : (NSString *)str_id :(NSString *) str_pw
{
    // 1
    NSString *encodeUserName = [self str2unicode: [str_id base64EncodedStringWithWrapWidth:0]];
    NSString *encodePassword = [self str2unicode: [str_pw base64EncodedStringWithWrapWidth:0]];
    
    
    NSString *baseUrl = getcodeURL;
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    
    
    [dic setObject:clientID                         forKey:@"client_id"];
    [dic setObject:@"http://your.domain.com/handle" forKey:@"redirect_uri"];
    [dic setObject:@"code"                          forKey:@"response_type"];
    [dic setObject:@"01011"                         forKey:@"tanentId"];
    [dic setObject:@"read+write+trust"              forKey:@"scope"];
    [dic setObject:encodeUserName                   forKey:@"username"];
    [dic setObject:encodePassword                   forKey:@"password"];
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:baseUrl parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //        NSLog(@"JSON: %@", responseObject);
        NSDictionary *responseDict = responseObject;
        /* do something with responseDict */
        NSString *code = [responseDict objectForKey:@"code"];
        NSLog(@"code : %@",code);
        
        
        [self login_getToken:code];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        
        [self showErrorMsgAndGoLogin :NSLocalizedString(@"msg_error_network", @"msg_error_network")];
        
    }];
    
    
}





- (void)login_getToken : (NSString *)code
{
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:clientID     forKey:@"client_id"];
    [dic setObject:@"sgYrMLRbElLNfL4Q7" forKey:@"client_secret"];
    [dic setObject:code                 forKey:@"code"];
    [dic setObject:@"none"              forKey:@"redirect_uri"];
    [dic setObject:@"read+write+trust"  forKey:@"scope"];
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager POST:gettokenURL parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        
        NSDictionary *responseDict = responseObject;
        NSString *access_token  = [responseDict objectForKey:@"access_token"];
        //        NSString *expires_in    = [responseDict objectForKey:@"expires_in"];
        //        NSString *refresh_token = [responseDict objectForKey:@"refresh_token"];
        //        NSString *scope         = [responseDict objectForKey:@"scope"];
        //        NSString *token_type    = [responseDict objectForKey:@"token_type"];
        
        //        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"로그인"
        //                                                        message:@"로그인 되었습니다"
        //                                                       delegate:self
        //                                              cancelButtonTitle:@"확인"
        //                                              otherButtonTitles:nil];
        //        [alert show];
        
        
        
        //        [self.navigationController pushViewController:viewController animated:YES];
        //        MainWebViewController *viewController = [[MainWebViewController alloc]init];
        
        self.token = access_token;
 
        [self loadUrl];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        
//        [self showErrorMsgAndGoLogin :NSLocalizedString(@"msg_error_network", @"msg_error_network")];
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"Error : %@",error);
//    [self showErrorMsgAndGoLogin :NSLocalizedString(@"msg_error_network", @"msg_error_network")];
}

#pragma mark - Check Network Status
-(BOOL) isNetworkEnable
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    BOOL isConnect = YES;
    
    if ([reachability currentReachabilityStatus] == NotReachable) {
        isConnect = NO;
    }
    
    //    switch ([reachability currentReachabilityStatus]) {
    //        case ReachableViaWWAN:
    //
    //            break;
    //
    //        case ReachableViaWiFi:
    //
    //            break;
    //
    //        case NotReachable:
    //            isConnect = NO;
    //            break;
    //
    //        default:
    //            break;
    //    }
    return isConnect;
}


- (NSString *)str2unicode :(NSString *)str
{
    NSMutableString *output = [NSMutableString string];
    const unsigned char *source = (const unsigned char *)[str UTF8String];
    int sourceLen = strlen((const char *)source);
    for (int i = 0; i < sourceLen; ++i) {
        const unsigned char thisChar = source[i];
        if (thisChar == ' '){
            [output appendString:@"+"];
        } else if (thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' ||
                   (thisChar >= 'a' && thisChar <= 'z') ||
                   (thisChar >= 'A' && thisChar <= 'Z') ||
                   (thisChar >= '0' && thisChar <= '9')) {
            [output appendFormat:@"%c", thisChar];
        } else {
            [output appendFormat:@"%%%02X", thisChar];
        }
    }
    return output;
}


- (void)showErrorMsgAndGoLogin : (NSString *)msg
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"str_error", @"str_error")
                                                    message:msg
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"str_OK", @"str_OK")
                                          otherButtonTitles:nil];
    [alert show];
    
    
    
}

- (void)alertView:(UIAlertView *)alertView
clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    
    if ( [[alertView title] isEqualToString:NSLocalizedString(@"str_error", @"str_error")]){
        
        if (buttonIndex == [alertView cancelButtonIndex]){
            //cancel clicked ...do your action
            
            [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"id"];
            [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"pw"];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }else{
            //reset clicked
        }
        
    }else if( [[alertView title] isEqualToString:NSLocalizedString(@"str_logout", @"str_logout")]){
        
        if (buttonIndex == [alertView cancelButtonIndex]){
            //cancel clicked ...do your action
            NSLog(@"logout cancel clicked");
            
            NSHTTPCookie *cookie;
            NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
            for (cookie in [storage cookies])
            {
                [storage deleteCookie:cookie];
            }
            
            [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"id"];
            [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"pw"];
            
            [self.navigationController popToRootViewControllerAnimated:YES];

        }else{
            //reset clicked
        }
    }
   }
-(IBAction)logout:(id)sender
{
        
    UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"str_logout", @"str_logout")
                                                        message:NSLocalizedString(@"msg_logout", @"msg_logout")
                                                        delegate:self
                                                        cancelButtonTitle:NSLocalizedString(@"str_OK", @"str_OK")
                                                        otherButtonTitles:NSLocalizedString(@"str_No", @"str_No")
                             , nil];
    [theAlert show];
    
//    NSHTTPCookie *cookie;
//    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
//    for (cookie in [storage cookies])
//    {
//        [storage deleteCookie:cookie];
//    }
//    
//    [self.navigationController popToRootViewControllerAnimated:YES];

}
                                                             

                                                                   
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
