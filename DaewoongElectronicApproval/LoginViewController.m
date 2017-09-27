//
//  LoginViewController.m
//  DaewoongElectronicApproval
//
//  Created by Ids&Trust on 2014. 12. 3..
//  Copyright (c) 2014년 Ids&Trust. All rights reserved.
//

#import "LoginViewController.h"
#import "MainWebViewController.h"



@interface LoginViewController ()

@end


@implementation LoginViewController
{
    NSString *login_ID;
    NSString *login_PW;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};

#ifdef Daewoong
    self.navigationItem.title = NSLocalizedString(@"str_e_approval", @"str_e_approval");
#elif SmartRunner
    self.navigationItem.title = NSLocalizedString(@"str_smartrunner", @"str_smartrunner");
    
#endif
//    [self.id_TextField setText:@"ljw407"];
//    [self.pw_TextField setText:@"dlwlsdn053168"];
    
    NSString *loginId = [[NSUserDefaults standardUserDefaults] stringForKey:@"id"];
    NSString *loginPw = [[NSUserDefaults standardUserDefaults] stringForKey:@"pw"];
    NSLog(@"loginId %@ pw %@",loginId,loginPw);
    
    self.id_TextField.placeholder = @"Email";
    
    if([loginId length]>0 && [loginPw length]>0){
        
        self.id_TextField.text = loginId;
        self.pw_TextField.text = loginPw;
        
        [self login_getCode:loginId pw:loginPw already:YES];
    }
    else{
    [self.loginButton addTarget:self action:@selector(login:) forControlEvents:UIControlEventTouchDown];
    
    
    
    [self.id_TextField setBackgroundColor:[UIColor colorWithRed:(230/255.f) green:(230/255.f) blue:(230/255.f) alpha:1.0f]];
    [self.pw_TextField setBackgroundColor:[UIColor colorWithRed:(230/255.f) green:(230/255.f) blue:(230/255.f) alpha:1.0f]];
    
    [self.id_TextField becomeFirstResponder];
    
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)login:(UIButton *)button{
    //    NSLog(@"login_getCode");
    
    
    login_ID = [self.id_TextField text];
    login_PW = [self.pw_TextField text];
    
    
    if (login_ID == nil || [login_ID isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"str_login", @"str_login")
                                                        message:NSLocalizedString(@"msg_login_id_empty", @"msg_login_id_empty")
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"str_OK", @"str_OK")
                                              otherButtonTitles:nil];
        [alert show];
    }else if(login_PW == nil || [login_PW isEqualToString:@""] ){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"str_login", @"str_login")
                                                        message:NSLocalizedString(@"msg_login_pw_empty", @"msg_login_pw_empty")
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"str_OK", @"str_OK")
                                              otherButtonTitles:nil];
        [alert show];
    }else{
    
        [self login_getCode:login_ID pw:login_PW already:NO];
    }
}

-(void)login_getCode : (NSString *)str_id pw:(NSString *) str_pw already:(BOOL)alreadylogin
{
    
    
    activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    [activityIndicator setCenter:self.view.center];
    [activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityIndicator.color = [UIColor blackColor];
    [self.view addSubview : activityIndicator];
    
    // ProgressBar Start
    activityIndicator.hidden= FALSE;
    [activityIndicator startAnimating];
    
    NSLog(@"id %@, pw %@", str_id, str_pw);
    // 1
    NSString *encodeUserName = [self str2unicode: [str_id base64EncodedStringWithWrapWidth:0]];
    NSString *encodePassword = [self str2unicode: [str_pw base64EncodedStringWithWrapWidth:0]];
    
    NSLog(@"1");
    
    NSString *baseUrl = getcodeURL;
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    
    
    [dic setObject:clientID                  forKey:@"client_id"];
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
        
        
        [self login_getToken:code already:alreadylogin];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        
        [activityIndicator stopAnimating];
        activityIndicator.hidden= TRUE;
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"str_login", @"str_login")
                                                        message:NSLocalizedString(@"msg_login_error", @"msg_login_error")
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"str_OK", @"str_OK")
                                              otherButtonTitles:nil];
        [alert show];
        
    }];

    
}





- (void)login_getToken : (NSString *)code already:(BOOL)alreadylogin
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
        
        
        [activityIndicator stopAnimating];
        activityIndicator.hidden= TRUE;
        
        
        if(alreadylogin){
            
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            MainWebViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"MainWebViewController"];
            viewController.token = access_token;
            
            [self.navigationController pushViewController:viewController animated:NO];
        }
        else{
        
        [[NSUserDefaults standardUserDefaults] setObject:login_ID forKey:@"id"];
        [[NSUserDefaults standardUserDefaults] setObject:login_PW forKey:@"pw"];
        

        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        MainWebViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"MainWebViewController"];
        viewController.token = access_token;
//        [self presentViewController:viewController animated:YES completion:nil];
        
        
        
        [self.navigationController pushViewController:viewController animated:YES];
        }

        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [activityIndicator stopAnimating];
        activityIndicator.hidden= TRUE;
        NSLog(@"Error: %@", error);
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"str_login", @"str_login")
                                                        message:NSLocalizedString(@"msg_login_error", @"msg_login_error")
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"str_OK", @"str_OK")
                                              otherButtonTitles:nil];
        [alert show];

    }];
}




//// Called when the view is about to made visible. Default does nothing
//- (void)viewWillAppear:(BOOL)animated{
//    NSLog(@"viewWillAppear");
//}
//
//
//// Called when the view has been fully transitioned onto the screen. Default does nothing
//- (void)viewDidAppear:(BOOL)animated{
//    NSLog(@"viewDidAppear");
//}
//
//
//// Called when the view is dismissed, covered or otherwise hidden. Default does nothing
//- (void)viewWillDisappear:(BOOL)animated{
//    NSLog(@"viewWillDisappear");
//}
//
//
//// Called after the view was dismissed, covered or otherwise hidden. Default does nothing
//- (void)viewDidDisappear:(BOOL)animated{
//    NSLog(@"viewDidDisappear");
//}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
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


-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    if([textField isEqual:self.id_TextField]) {
        
        [self.pw_TextField becomeFirstResponder];
        
    }
    
    
    return YES;
    
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


